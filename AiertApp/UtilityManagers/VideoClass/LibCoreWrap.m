

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
@property (strong, nonatomic) ZSPConnection *zspConnection;
@property (strong, nonatomic) P2PManager *p2pManager;
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
        self.zspConnection = [[ZSPConnection alloc] initWithDelegate:self];
        self.p2pManager = [P2PManager sharedInstance];
        [self.p2pManager setDelegate:self];
        self.streamObersvers = [[NSMutableSet alloc] init];
        self.eventObersvers = [[NSMutableSet alloc] init];
        
        _bFindFirstIFrame = NO;
        
    }
    return self;
}

- (void)dealloc
{
    [self.p2pManager removeDelegate];
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

#if 1
- (int)startRealPlayWithDeviceId:(NSString *)device_id
                         channel:(NSInteger)channel
                       mediaType:(NSInteger)media_type
                        userName:(NSString *)username
                        password:(NSString *)password
                         timeout:(NSInteger)timeout
{
    
    [AppData addCameraState:CameraStateActive];
    self.userName = username;
    self.currentDeviceId = device_id;
    self.password = password;
    self.currentChannel = channel;
    self.currentMediaType = media_type;
    
    
    dispatch_group_async(_group, _streamQueue, ^{
//        [self connetToLocalDevice];
        [self connectWithDevice:self.currentDeviceId];
    });
    
    return 0;
}

- (void)connectWithDevice:(NSString *)deviceID
{
    [self.p2pManager checkConnectTypeWithDeviceID:self.currentDeviceId];
}

- (void)closeConnection
{
    [self.p2pManager closeConnection];
}

- (void)setMirrorUpDown
{
    [self.p2pManager setMirrorUpDown];
}
- (void)setMirrorLeftRight
{
    [self.p2pManager setMirrorLeftRight];
}

- (void)stopTurnCamera
{
    [self.p2pManager stopTurnCamera];
}
- (void)startTurnCameraWithSpeed:(unsigned char)speed type:(CAMERA_TURN_TYPE)cameraTurnType
{
    [self.p2pManager startTurnCameraWithSpeed:speed type:cameraTurnType];
}

#pragma mark -
#pragma mark - P2PManagerDelegate Methods

- (void)p2pManager:(P2PManager *)p2pManager didConnectDeviceID:(NSString *)deviceID withType:(CONNECT_TYPE)connectType ip:(NSString *)ip port:(NSUInteger)port sid:(int)sid
{
    if ([deviceID isEqualToString:self.currentDeviceId]/* && connectType != CONNECT_LAN_TYPE*/) {
        //P2P播放或者远程连接播放
        [p2pManager startWithSID:sid];
    }
//    else if ([deviceID isEqualToString:self.currentDeviceId] && connectType == CONNECT_LAN_TYPE){
//        
//        [p2pManager closeConnection];
//        
//        //局域网播放
//        dispatch_group_async(_group, _streamQueue, ^{
//            [self connetToLocalDevice];
//        });
//
//    }
}

- (void)p2pManager:(P2PManager *)p2pManager didFailedStartPlayWithDeviceID:(NSString *)deviceID
{
    if ([self.currentDeviceId isEqualToString:deviceID]) {
        dispatch_group_async(_group, _recordFileQueue, ^{
            @autoreleasepool {
                
                [self.streamObersvers enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
                    
                    if ([obj respondsToSelector:@selector(didFailedPlayWithDeviceID:)]) {
                        [obj didFailedPlayWithDeviceID: self.currentDeviceId];
                    }
                }];
            }
            
        });
    }
}

- (void)p2pManager:(P2PManager *)p2pManager didReadVideoData:(NSData *)data
{
    //    DLog(@"Aiert_ios各阶段运行状态<<=====TCP 视频数据======》》");
    dispatch_group_async(_group, _decodeQueue, ^{
        @autoreleasepool {
            int nLen = [data length]-32;
            [data getBytes:buffer range:NSMakeRange(32, nLen)];
            // Decode and display
            
            if (!(CameraStateActive&[AppData cameraState])) {
                
                DLog(@"------------------------------------------------------> 3 stop playing !");
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

- (void)p2pManager:(P2PManager *)p2pManager didReadAudioData:(NSData *)data
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

- (void)p2pManager:(P2PManager *)p2pManager didStartPlayWithDEviceID:(NSString *)deviceID
{
    if ([deviceID isEqualToString:self.currentDeviceId]) {
        //P2P播放开始
        dispatch_group_async(_group, _recordFileQueue, ^{
            @autoreleasepool {
        
                [self.streamObersvers enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
                    
                    if ([obj respondsToSelector:@selector(didStartPlayWithDeviceID:)]) {
                        [obj didStartPlayWithDeviceID:self.currentDeviceId];
                    }
                }];
            }
            
        });

    }
 
}

- (void)p2pManager:(P2PManager *)p2pManager didStopPlayWithDEviceID:(NSString *)deviceID
{
    if ([deviceID isEqualToString:self.currentDeviceId]) {
        //P2P播放关闭
        
        dispatch_group_async(_group, _recordFileQueue, ^{
            @autoreleasepool {
                
                [self.streamObersvers enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
                    
                    if ([obj respondsToSelector:@selector(didStopPlayWithDeviceID:)]) {
                        [obj didStopPlayWithDeviceID:self.currentDeviceId];
                    }
                }];
            }
            
        });
        
    }
}

#else
- (int)startRealPlayWithDeviceId:(NSString *)device_id
                         channel:(NSInteger)channel
                       mediaType:(NSInteger)media_type
                        userName:(NSString *)username
                        password:(NSString *)password
                         timeout:(NSInteger)timeout
{
    
    [AppData addCameraState:CameraStateActive];
    self.userName = username;
    self.currentDeviceId = device_id;
    self.password = password;
    self.currentChannel = channel;
    self.currentMediaType = media_type;
    
    
    dispatch_group_async(_group, _streamQueue, ^{
        [self connetToLocalDevice];
    });
    
    return 0;
}

#endif

//本地播放，需要放在登录的回掉里面
-(void)playWithLocalDevice
{
    __weak LibCoreWrap *tempSelf = self;
    
    dispatch_group_async(_group, _streamQueue, ^{
        
        [tempSelf.zspConnection startDisplayWithLocalchannel:self.currentChannel
                                                   mediaType:self.currentChannel
                                               isLocalDevice:YES];
        
    });
    
    dispatch_group_async(_group, _recordFileQueue, ^{
        @autoreleasepool {
            
            [self.streamObersvers enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
                
                if ([obj respondsToSelector:@selector(didStartPlayWithDeviceID:)]) {
                    [obj didStartPlayWithDeviceID:self.currentDeviceId];
                }
            }];
        }
        
    });
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
            
//            [self.p2pConnection changeStream:_currentChannel
//                                   mediaType:0
//                                   operation:0];              // 关闭当前通道
//            
//            
//            [self.p2pConnection changeStream:dstChannel
//                                   mediaType:0
//                                   operation:1];
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
//            [self.p2pConnection changeStream:_currentChannel
//                                   mediaType:_currentMediaType
//                                   operation:0];              // 关闭当前通道
//            
//            [self.p2pConnection changeStream:_currentChannel
//                                   mediaType:dstMediaType
//                                   operation:1];
//            
//            if (CameraStateAudioPlaying&[AppData cameraState]) {
//                [self.p2pConnection enableSound:YES];
//            }

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
        [self.p2pManager closeConnection];
        
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
            
//            [self.p2pConnection enableSound:YES];
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
            
//            [self.p2pConnection enableSound:NO];
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
            
//            [self.p2pConnection enableTalk:YES];
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
            
//            [self.p2pConnection enableTalk:NO];
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
            
//            [self.p2pConnection sendTalkData:pBuffer length:nBufferLen];
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
                deviceIP:(NSString *)deviceIP
              devicePort:(NSUInteger)port
{
    [self.zspConnection loginWithUserName:username password:password deviceIP:deviceIP devicePort:port];
    return 0;
    
}

- (int)setPassWordWithDeviceId:(NSString *)device_id
                       channel:(NSInteger)channel
                      userName:(NSString *)username
                      password:(NSString *)password
{
    return 0;
    
}


#pragma mark - ZSPConnectionDelegate

- (void)didLoginSuccess
{
    [self.zspConnection closeCommandSocket];
        
    [AppData addCameraState:CameraStateLogin];

    //FIXME:这里的测试方法2需要去掉
    [self playWithLocalDevice];
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
    dispatch_group_async(_group, _recordFileQueue, ^{
        @autoreleasepool {
            
            [self.streamObersvers enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
                
                if ([obj respondsToSelector:@selector(didFailedPlayWithDeviceID:)]) {
                    [obj didFailedPlayWithDeviceID: self.currentDeviceId];
                }
            }];
        }
        
    });

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
//MARK:播放视频数据
- (void)didReadVideoData:(NSData *)data
{
//    DLog(@"Aiert_ios各阶段运行状态<<=====TCP 视频数据======》》");
    dispatch_group_async(_group, _decodeQueue, ^{
        @autoreleasepool {
            int nLen = [data length]-24;
            [data getBytes:buffer range:NSMakeRange(24, nLen)];
            // Decode and display
            
            if (!(CameraStateActive & [AppData cameraState])) {
                
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
    dispatch_group_async(_group, _recordFileQueue, ^{
        @autoreleasepool {
            
            [self.streamObersvers enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
                
                if ([obj respondsToSelector:@selector(didFailedPlayWithDeviceID:)]) {
                    [obj didFailedPlayWithDeviceID: self.currentDeviceId];
                }
            }];
        }
        
    });

    
    NSInteger currentState = [AppData connectionState];
    
    switch (currentState) {
        case CameraNetworkStateUpnpRecvFailed:
        case CameraNetworkStateLocalRecvFailed:
        {
            dispatch_group_async(_group, _streamQueue, ^{
                //MARK:这里是一个bug，需要处理
                //FIXME:需要解决不同情况，重新连接的问题
//                [self.zspConnection reStartRealPlay];
                
                if ([AppData cameraState]&CameraStateAudioPlaying) {
                    [self.zspConnection openSound:YES];
                }
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
- (void)didFindTheDeviceWithInfo:(AiertDeviceInfo *)device
{
    if ([device.deviceID isEqualToString:self.currentDeviceId]) {
         _bLocalDeviceExists = YES;// 找到设备
        
        self.currentDeviceId = device.deviceID;
        self.currentChannel = device.deviceAdditionInfo.videoNum;

        __weak LibCoreWrap *tempSelf = self;
        
        dispatch_group_async(_group, _streamQueue, ^{

            [tempSelf.zspConnection loginWithUserName:self.userName
                                             password:self.password
                                             deviceIP:device.deviceAdditionInfo.IP
                                           devicePort:device.deviceAdditionInfo.port];
        });

    }
    
    [self.pingTimer invalidate];
    self.pingTimer = nil;
}

#pragma mark - currentFrame

- (id)currentFrame
{
    return [self.videoDecoder convertFrameToRGB];
}

@end
