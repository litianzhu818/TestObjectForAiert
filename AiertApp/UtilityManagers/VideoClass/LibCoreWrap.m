

#import "libCoreWrap.h"
#import "BasicDefine.h"
#import "ZMDevice.h"
#import "PingLocalNetWorkProtocal.h"
#import "VideoFrameExtractor.h"
#import "Reachability.h"
#import "AppData.h"
#import "AQRecorderWarp.h"

@interface LibCoreWrap ()
{
    Byte buffer[65535];
    
    dispatch_group_t _group;
    
    dispatch_queue_t _streamQueue;
    dispatch_queue_t _pingQueue;
    dispatch_queue_t _decodeQueue;
    dispatch_queue_t _talkQueue;
    dispatch_queue_t _recordFileQueue;
    
    NSInteger _pingCounter;
    BOOL _bLock;
    __block BOOL _bFindFirstIFrame;
    __block BOOL _bLocalDeviceExists;
    
}
@property (strong, nonatomic) NSMutableSet *streamObersvers;
@property (strong, nonatomic) NSMutableSet *eventObersvers;
@property (strong, nonatomic) P2PConnection *p2pConnection;
@property (strong, nonatomic) ZSPConnection *zspConnection;
@property (copy, nonatomic) NSString *userName;
@property (copy, nonatomic) NSString *password;
@property (copy, nonatomic) NSString *currentDeviceId;
@property (nonatomic) NSInteger currentChannel;
@property (nonatomic) NSInteger currentMediaType;
@property (strong, nonatomic) PingLocalNetWorkProtocal *pingLocalNetWorkProtocal;
@property (strong, nonatomic) VideoFrameExtractor *videoDecoder;
@property (strong, nonatomic) NSData *frameHeader;

@property (weak, nonatomic)NSTimer *pingTimer;

@end

@implementation LibCoreWrap

+ (LibCoreWrap *)sharedCore
{
    static  LibCoreWrap *sharedInstance = nil ;
    static  dispatch_once_t onceToken;
    dispatch_once (& onceToken, ^ {
        sharedInstance = [[self alloc]init];
        
    });
    return sharedInstance;
}


- (id)init
{
    if (self = [super init]) {
        
        _group = dispatch_group_create();
        _streamQueue = dispatch_queue_create("streamQueue", NULL);
        _decodeQueue = dispatch_queue_create("decodeQueue", NULL);
        _talkQueue = dispatch_queue_create("talkQueue", NULL);
        _recordFileQueue = dispatch_queue_create("recordFileQueue", NULL);
        
        self.videoDecoder = [VideoFrameExtractor creatVideoFrameExtractor];
        self.p2pConnection = [[P2PConnection alloc] initWithDelegate:self];
        self.zspConnection = [[ZSPConnection alloc] initWithDelegate:self];
        self.streamObersvers = [[NSMutableSet alloc] init];
        self.eventObersvers = [[NSMutableSet alloc] init];
        
        _bFindFirstIFrame = NO;
        
    }
    return self;
}

- (int)initialize
{
    return 0;
}

- (void)unInitialize
{
    
}

- (void)registerEventObserver:(id)observer
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.eventObersvers addObject:observer];
    });
}

- (void)unRegisterEventObserver:(id)observer
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.eventObersvers removeObject:observer];
    });
    
}

- (void)unRegisterAllEventObservers
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.eventObersvers removeAllObjects];
    });
}

- (int)startRealPlayWithDeviceId:(NSString *)device_id
                         channel:(NSInteger)channel
                       mediaType:(NSInteger)media_type
                        password:(NSString *)password
                         timeout:(NSInteger)timeout
{
    
    [AppData addCameraState:CameraStateActive];
    self.currentDeviceId = device_id;
    self.password = password;
    self.currentChannel = channel;
    self.currentMediaType = media_type;
    
    dispatch_group_async(_group, _streamQueue, ^{
        [self.p2pConnection isUPNPSupport:device_id];
    });
    
    return 0;
}

- (void)changeChannel:(NSInteger)dstChannel
{
    
    NSInteger currentConnectState = [AppData connectionState];
    
    dispatch_group_async(_group, _decodeQueue, ^{
        [VideoFrameExtractor releaseVideoFrameExtractor:self.videoDecoder];
    });
    
    if (CameraNetworkStateTransmitConnected == currentConnectState
        || CameraNetworkStateP2pConnected == currentConnectState) {
        
        dispatch_group_async(_group, _streamQueue, ^{
            
            [self.p2pConnection changeStream:_currentChannel
                                   mediaType:0
                                   operation:0];              // 关闭当前通道
            
            
            [self.p2pConnection changeStream:dstChannel
                                   mediaType:0
                                   operation:1];
        });
        
    }else {
        
        dispatch_group_async(_group, _streamQueue, ^{
            
            [self.zspConnection changeChannel:dstChannel];
            
        });
    }
    
    __weak LibCoreWrap *weakSelf = self;
    
    dispatch_group_async(_group, _decodeQueue, ^{
        weakSelf.videoDecoder = [VideoFrameExtractor creatVideoFrameExtractor];
    });
}

- (void)changeStream:(NSInteger)dstMediaType
{
    
    dispatch_group_async(_group, _decodeQueue, ^{
        [VideoFrameExtractor releaseVideoFrameExtractor:self.videoDecoder];
    });
    
    NSInteger currentConnectState = [AppData connectionState];
    
    if (CameraNetworkStateTransmitConnected == currentConnectState
        || CameraNetworkStateP2pConnected == currentConnectState) {
        
        dispatch_group_async(_group, _streamQueue, ^{
            [self.p2pConnection changeStream:_currentChannel
                                   mediaType:_currentMediaType
                                   operation:0];              // 关闭当前通道
            
            [self.p2pConnection changeStream:_currentChannel
                                   mediaType:dstMediaType
                                   operation:1];
            
            if (CameraStateAudioPlaying&[AppData cameraState]) {
                [self.p2pConnection enableSound:YES];
            }

        });
        
    }else {
        
        dispatch_group_async(_group, _streamQueue, ^{
            [self.zspConnection changeStream:dstMediaType];

            if (CameraStateAudioPlaying&[AppData cameraState]) {
                [self.zspConnection openSound:YES];
            }

            
        });
    }
    
    __weak LibCoreWrap *weakSelf = self;
    
    dispatch_group_async(_group, _decodeQueue, ^{
        weakSelf.videoDecoder = [VideoFrameExtractor creatVideoFrameExtractor];
    });

}

- (void)pauseRealPlayWithDeviceId:(NSString *)device_id
                          channel:(NSInteger)channel
{
    
}

- (void)stopRealPlayWithDeviceId:(NSString *)device_id
                         channel:(NSInteger)channel
{
    
    
    dispatch_group_async(_group, _streamQueue, ^{
        [self.zspConnection stopRealPlay];
        [self.p2pConnection stopRealPlay];
        
    });
    
    dispatch_group_wait(_group, 3.0f);
    
    [self.eventObersvers enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        if ([obj respondsToSelector:@selector(didReceiveEvent:content:deviceId:channel:)]) {
            [obj didReceiveEvent:LibCoreEventCodePlayStoped
                         content:nil
                        deviceId:self.currentDeviceId
                         channel:self.currentChannel];
        }
    }];
    
}

- (int)registerStreamObserverWithDeviceId:(NSString *)device_id
                                  channel:(NSInteger)channel
                           streamObserver:(id) observer
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.streamObersvers addObject:observer];
    });
    return 0;
}

- (int)unRegisterStreamObserverWithDeviceId:(NSString *)device_id
                                    channel:(NSInteger)channel
                             streamObserver:(id) observer
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.streamObersvers removeObject:observer];
    });
    return 0;
}

- (int)unRegisterAllStreamObserverWithDeviceId:(NSString *)device_id
                                       channel:(NSInteger)channel
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.streamObersvers removeAllObjects];
    });
    return 0;
}

- (int)openSoundWithDeviceId:(NSString *)device_id
                     channel:(NSInteger)channel
{
    NSInteger currentConnectState = [AppData connectionState];
    
    if (CameraNetworkStateTransmitConnected == currentConnectState
        || CameraNetworkStateP2pConnected == currentConnectState)
    {
        
        dispatch_group_async(_group, _streamQueue, ^{
            
            [self.p2pConnection enableSound:YES];
        });
        
    }else {
        
        dispatch_group_async(_group, _streamQueue, ^{
            
            [self.zspConnection openSound:YES];
        });
    }

    return 0;
}

- (int)closeSoundWithDeviceId:(NSString *)device_id
                      channel:(NSInteger)channel
{
    NSInteger currentConnectState = [AppData connectionState];
    
    if (CameraNetworkStateTransmitConnected == currentConnectState
        || CameraNetworkStateP2pConnected == currentConnectState)
    {
        
        dispatch_group_async(_group, _streamQueue, ^{
            
            [self.p2pConnection enableSound:NO];
        });
        
    }else {
        
        dispatch_group_async(_group, _streamQueue, ^{
            
            [self.zspConnection openSound:NO];
        });
    }

    return 0;
    
}

- (int)startTalkWithDeviceId:(NSString *)device_id
                     channel:(NSInteger)channel
{
    dispatch_group_async(_group, _talkQueue, ^{
        [AQRecorderWarp stopRecord];
    });
    
    NSInteger currentConnectState = [AppData connectionState];
    
    if (CameraNetworkStateTransmitConnected == currentConnectState
        || CameraNetworkStateP2pConnected == currentConnectState)
    {
        
        dispatch_group_async(_group, _streamQueue, ^{
            
            [self.p2pConnection enableTalk:YES];
        });
        
    }else {
        
        dispatch_group_async(_group, _streamQueue, ^{
            
            [self.zspConnection openMic:YES];
        });
    }

    return 0;
    
}

- (int)stopTalkWithDeviceId:(NSString *)device_id
                    channel:(NSInteger)channel
{
    
    dispatch_group_async(_group, _talkQueue, ^{
        [AQRecorderWarp stopRecord];
    });
    
    NSInteger currentConnectState = [AppData connectionState];
    
    if (CameraNetworkStateTransmitConnected == currentConnectState
        || CameraNetworkStateP2pConnected == currentConnectState)
    {
        
        dispatch_group_async(_group, _streamQueue, ^{
            
            [self.p2pConnection enableTalk:NO];
        });
        
    }else {
        
        dispatch_group_async(_group, _streamQueue, ^{
            
            [self.zspConnection openMic:NO];
        });
    }

    
    return 0;
    
}

- (int)talkSendDataWithDeviceId:(NSString *)device_id
                        channel:(NSInteger)channel
                           data:(BytePtr)pBuffer
                         length:(int)nBufferLen;
{
    NSInteger currentConnectState = [AppData connectionState];
    
    if (CameraNetworkStateTransmitConnected == currentConnectState
        || CameraNetworkStateP2pConnected == currentConnectState)
    {
        
        dispatch_group_async(_group, _streamQueue, ^{
            
            [self.p2pConnection sendTalkData:pBuffer length:nBufferLen];
        });
        
    }else {
        
        dispatch_group_async(_group, _streamQueue, ^{
            
            [self.zspConnection sendMicDataToDevice:pBuffer length:nBufferLen];
        });
    }

    return 0;
}

- (int)loginWithDeviceId:(NSString *)device_id
                 channel:(NSInteger)channel
                userName:(NSString *)username
                password:(NSString *)password
{
    return 0;
    
}

- (int)setPassWordWithDeviceId:(NSString *)device_id
                       channel:(NSInteger)channel
                      userName:(NSString *)username
                      password:(NSString *)password
{
    return 0;
    
}

#pragma mark - P2pConnectionDelegate

- (void)didGetUPNPSupportInfoWithTag:(NSInteger)tag param:(id)param
{
    switch (tag) {
        case UpnpQueryFailure:                                           // LocalNetwork
        {
            [self connetToLocalDevice];
        }
            break;
        case UpnpQueryResultNotSupport:                                  // P2p
        {
            dispatch_group_async(_group, _streamQueue, ^{
                [self.p2pConnection requestStream:self.currentDeviceId
                                          channel:self.currentChannel
                                       streamType:self.currentMediaType
                                            isP2p:YES];
            });
        }
            break;
        case UpnpQueryResultSupport:                                     // Upnp
        {
            NSDictionary *dicQuerRes = [param objectForKey:@"QueryRes"];
            
            dispatch_group_async(_group, _streamQueue, ^{
                
                [self.zspConnection startDisplayWithDeviceIp:[dicQuerRes objectForKey:@"InternetIp"]
                                                        port:[[dicQuerRes objectForKey:@"UpnpVideoPort"] intValue]
                                                     channel:_currentChannel
                                                   mediaType:_currentMediaType
                                               isLocalDevice:NO];
                
            });
            
        }
            break;
    }
}

- (void)didRecvVideoFrameData:(NSInteger)iType streamData:(char *)pData size:(NSInteger)iSize
{
    
//    DLog(@"%@,%@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
    dispatch_group_async(_group, _decodeQueue, ^{
        @autoreleasepool {
            if ([self.videoDecoder stepFrame:(unsigned char *)pData length:iSize]) {
                [self.streamObersvers enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
                    if ([obj respondsToSelector:@selector(didReceiveImageData:)]) {
                        [obj didReceiveImageData:self.videoDecoder.currentFrame];
                    }
                }];
            }
            
        }
    });
}
- (void)didRecvAudioFrameData:(char *)pData size:(NSInteger)iSize
{
    dispatch_group_async(_group, _streamQueue, ^{
        @autoreleasepool {
            [self.streamObersvers enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
                if ([obj respondsToSelector:@selector(didReceiveAudioData:)]) {
                    [obj didReceiveAudioData:[NSData dataWithBytes:pData length:iSize]];
                }
            }];
        }
    });
}
- (void)didRecvRawData:(char *)pData size:(NSInteger)iSize tag:(NSInteger)tag;
{
    if (!(CameraStateRecording&[AppData cameraState])) {
        return;
    }
    
    if (RawDataTagHeader == tag) {
        dispatch_group_async(_group, _recordFileQueue, ^{
            @autoreleasepool {
                self.frameHeader = [NSData dataWithBytes:pData length:iSize];
            }
        });
        
    }else
    {
        dispatch_group_async(_group, _recordFileQueue, ^{
            @autoreleasepool {
                
                NSMutableData *packet = [NSMutableData dataWithData:self.frameHeader];
                [packet appendData:[NSData dataWithBytes:pData length:iSize]];
                
                [self.streamObersvers enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
                    
                    if ([obj respondsToSelector:@selector(didReceiveRawData:tag:)]) {
                        [obj didReceiveRawData:packet tag:tag];
                    }
                }];
            }
            
        });
    }

}

- (void)didRecvStreamStatus:(int)iStatus
{
    switch (iStatus) {
        case CameraNetworkStateP2pConnected:
            [AppData addCameraState:CameraStateConnected];
            [AppData setConnectionState:CameraNetworkStateP2pConnected];
            break;
        case CameraNetworkStateP2pConnectFailed:
        {
            dispatch_group_async(_group, _streamQueue, ^{
                
                [self.p2pConnection stopRealPlay];
                [self.p2pConnection requestStream:self.currentDeviceId
                                          channel:self.currentChannel
                                       streamType:self.currentMediaType
                                            isP2p:NO];
            });

        }
            break;
        case CameraNetworkStateP2pRecvFailed:
        {
            dispatch_group_async(_group, _streamQueue, ^{
                [self.p2pConnection stopRealPlay];
                [self.p2pConnection requestStream:self.currentDeviceId
                                          channel:self.currentChannel
                                       streamType:self.currentMediaType
                                            isP2p:YES];
                
                if ([AppData cameraState]&CameraStateAudioPlaying) {
                    [self.p2pConnection enableSound:YES];
                }
            });

        }
            break;
        case CameraNetworkStateTransmitConnected:
            [AppData addCameraState:CameraStateConnected];
            [AppData setConnectionState:CameraNetworkStateTransmitConnected];
            break;
        case CameraNetworkStateTransmitConnectFailed:
        {
            
            dispatch_group_async(_group, _streamQueue, ^{
                [self.p2pConnection stopRealPlay];
            });

            [AppData setConnectionState:CameraNetworkStateTransmitConnectFailed];
            [self connetToLocalDevice];
        }
            break;
        case CameraNetworkStateTransmitRecvFailed:
        {
            [AppData setConnectionState:CameraNetworkStateTransmitRecvFailed];

            dispatch_group_async(_group, _streamQueue, ^{
                [self.p2pConnection stopRealPlay];
                [self.p2pConnection requestStream:self.currentDeviceId
                                          channel:self.currentChannel
                                       streamType:self.currentMediaType
                                            isP2p:NO];
                
                if ([AppData cameraState]&CameraStateAudioPlaying) {
                    [self.p2pConnection enableSound:YES];
                }

            });
        }
            break;
        case LibCoreEventCodeAudioResoponseFailed:
        case LibCoreEventCodeAudioResponseSuccess:
        case LibCoreEventCodeMicResponseFailed:
        case LibCoreEventCodeOpenMicSuccess:
        {
            dispatch_group_async(_group, _talkQueue, ^{
                [self.streamObersvers enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
                    if ([obj respondsToSelector:@selector(didReceiveEvent:content:deviceId:channel:)]) {
                        [obj didReceiveEvent:iStatus
                                     content:nil
                                    deviceId:self.currentDeviceId
                                     channel:self.currentChannel];
                    }
                }];
            });
        }
            break;
    }
    
    if (LibCoreEventCodeOpenMicSuccess == iStatus) {
        dispatch_group_async(_group, _talkQueue, ^{
            [AQRecorderWarp startRecord];
        });
    }
}

#pragma mark - ZSPConnectionDelegate

- (void)didLoginSuccess
{
    [self.zspConnection closeCommandSocket];
        
    [AppData addCameraState:CameraStateLogin];
}

- (void)didReadAudioResponse:(NSInteger)code
{
    dispatch_group_async(_group, _streamQueue, ^{
        @autoreleasepool {
            [self.streamObersvers enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
                if ([obj respondsToSelector:@selector(didReceiveEvent:content:deviceId:channel:)]) {
                    [obj didReceiveEvent:code
                                 content:nil
                                deviceId:self.currentDeviceId
                                 channel:self.currentChannel];
                }
            }];
        }
    });
}
- (void)didReadMicResponse:(NSInteger)code
{
    dispatch_group_async(_group, _talkQueue, ^{
        [self.streamObersvers enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
            if ([obj respondsToSelector:@selector(didReceiveEvent:content:deviceId:channel:)]) {
                [obj didReceiveEvent:code
                             content:nil
                            deviceId:self.currentDeviceId
                             channel:self.currentChannel];
            }
        }];
    });
    
    if (LibCoreEventCodeOpenMicSuccess == code) {
        dispatch_group_async(_group, _talkQueue, ^{
            [AQRecorderWarp startRecord];
        });
    }

}

- (void)didReadDataTimeOut
{
    
}

- (void)didReadRawData:(NSData *)data tag:(NSInteger)tag;
{
    if (!(CameraStateRecording&[AppData cameraState])) {
        return;
    }
    
    
    if (RawDataTagHeader == tag) {
        self.frameHeader = data;
        
        if (!_bFindFirstIFrame && 0 == memcmp([self.frameHeader bytes], "00dc", 4)) {
            _bFindFirstIFrame = YES;
        }
    
    }else
    {
        
        if (!_bFindFirstIFrame) {
            return;
        }
        
        NSMutableData *packet = [NSMutableData dataWithData:self.frameHeader];
        [packet appendData:data];
        
        dispatch_group_async(_group, _recordFileQueue, ^{
            @autoreleasepool {
                
                if (!(CameraStateRecording&[AppData cameraState])) {
                    return;
                }
                
                [self.streamObersvers enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
                    
                    if ([obj respondsToSelector:@selector(didReceiveRawData:tag:)]) {
                        [obj didReceiveRawData:packet tag:tag];
                    }
                }];
            }
            
        });
    }
}
- (void)didReadAudioData:(NSData *)data
{
    dispatch_group_async(_group, _streamQueue, ^{
        @autoreleasepool {
            [self.streamObersvers enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
                if ([obj respondsToSelector:@selector(didReceiveAudioData:)]) {
                    [obj didReceiveAudioData:data];
                }
            }];
        }
    });
}
- (void)didReadVideoData:(NSData *)data
{
//    DLog(@"Aiert_ios各阶段运行状态<<=====TCP 视频数据======》》");
    dispatch_group_async(_group, _decodeQueue, ^{
        @autoreleasepool {
            int nLen = [data length]-24;
            [data getBytes:buffer range:NSMakeRange(24, nLen)];
            // Decode and display
            
            if (!(CameraStateActive&[AppData cameraState])) {
                
                DLog(@"------------------------------------------------------> 2 stop playing !");
                return;
            }
            
            if ([self.videoDecoder stepFrame:buffer length:[data length]-24]) {
                
                [self.streamObersvers enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
                    if ([obj respondsToSelector:@selector(didReceiveImageData:)]) {
                        [obj didReceiveImageData:self.videoDecoder.currentFrame];
                    }
                }];
            }
        }
    });
}

- (void)didDisconnect
{
    
    NSInteger currentState = [AppData connectionState];
    
    switch (currentState) {
        case CameraNetworkStateUpnpRecvFailed:
        case CameraNetworkStateLocalRecvFailed:
        {
            dispatch_group_async(_group, _streamQueue, ^{
                [self.zspConnection reStartRealPlay];
                
                if ([AppData cameraState]&CameraStateAudioPlaying) {
                    [self.zspConnection openSound:YES];
                }
            });

        }
            break;
        case CameraNetworkStateUpnpConnectFailed:
        {
            dispatch_group_async(_group, _streamQueue, ^{
                [self.p2pConnection requestStream:self.currentDeviceId
                                          channel:self.currentChannel
                                       streamType:self.currentMediaType
                                            isP2p:YES];
            });
        }
            break;
        case CameraNetworkStateLocalConnectFailed:
        {
            
        }
            break;
    }
}
#pragma mark - Connet To Local Device

- (void)connetToLocalDevice
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (ReachableViaWiFi == [[Reachability reachabilityForLocalWiFi] currentReachabilityStatus]) {
            DLog(@"WIFI netWork !");
            _pingCounter = 0;
            _bLock = NO;
            _bLocalDeviceExists = NO;
            double delayInSeconds = 2.0;
            
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 1), ^(void){
                DLog(@"局域网是否找到设备bLocalDeviceExists : __________________________________%@",_bLocalDeviceExists ? @"YES" : @"NO");
                if (!_bLocalDeviceExists) {
                    //                        [self connectFailed:NSLocalizedString(@"Connect Failed", @"Connect Failed")];
                    
                }
            });
            
            self.pingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/10.0
                                                              target:self
                                                            selector:@selector(pingLocalNetWork)
                                                            userInfo:nil
                                                             repeats:YES];
        }
        else{
            //                [self connectFailed:NSLocalizedString(@"Connect Failed", @"Connect Failed")];
        }
        
    });
}

#pragma mark - PingLocalNetWork

- (void)pingLocalNetWork
{
    DLog(@"Aiert_ios各阶段运行状态<<======局域网内搜索设备ping times—— %d======》》",_pingCounter);
    
    do {
        if (!(CameraStateActive&[AppData cameraState])) {
            break;
        }
        
        if (3 == _pingCounter || _bLocalDeviceExists) {
            break;
        }
        
        if (nil == self.pingLocalNetWorkProtocal) {
            self.pingLocalNetWorkProtocal = [[PingLocalNetWorkProtocal alloc] initWithDeviceId:self.currentDeviceId];
            [self.pingLocalNetWorkProtocal setPingLocalNetWorkProtocalDelegate:(id)self];
        }
        
        if (nil == _pingQueue) {
            _pingQueue = dispatch_queue_create("pingQueue", NULL);
        }
        
        dispatch_group_async(_group, _pingQueue, ^{
            [self.pingLocalNetWorkProtocal pingLocalDevicesWithBindPort:2337];
        });
        _pingCounter++;
        
        return;
        
    } while (0);
    
    [self.pingTimer invalidate];
    self.pingTimer = nil;
}

#pragma mark - PingLocalNetwork delegate

- (void)didFindTheDevice:(NSDictionary *)devInfoDict;
{
    do {
        if (!(CameraStateActive&[AppData cameraState])) {
            break;
        }
        
        DLog(@"Aiert_ios各阶段运行状态<<======局域网内找到设备======》》");
        _bLocalDeviceExists = YES;// 找到设备
        
        if (_bLock) {
            break;
        }
        
        _bLock = YES;
        DLog(@"对局域网内找到的设备进行处理，且只处理一次，这个log只能打印一次");
        
        NSLog(@"Aiert_ios各阶段运行状态<<======局域网ZSP播放======》》");
        
        __weak LibCoreWrap *tempSelf = self;
        
        dispatch_group_async(_group, _streamQueue, ^{
            [tempSelf.zspConnection startDisplayWithDeviceIp:[devInfoDict objectForKey:kDeviceLocalIp]
                                                        port:[[devInfoDict objectForKey:kDeviceLocalPort] intValue]
                                                     channel:_currentChannel
                                                   mediaType:_currentMediaType
                                               isLocalDevice:YES];
        });

    } while (0);
    
    [self.pingTimer invalidate];
    self.pingTimer = nil;
}

#pragma mark - currentFrame

- (id)currentFrame
{
    return [self.videoDecoder convertFrameToRGB];
}

@end
