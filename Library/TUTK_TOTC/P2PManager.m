//
//  P2PManager.m
//  AiertApp
//
//  Created by Peter Lee on 14/10/31.
//  Copyright (c) 2014年 爱尔特电子有限公司. All rights reserved.
//

#import "P2PManager.h"
#import "IOTCAPIs.h"
#import "AVAPIs.h"
#import "AVIOCTRLDEFs.h"
#import "AVFRAMEINFO.h"
#include "G711Convert_HISI.h"
#import "AiertProtocol.h"
#import <sys/time.h>

#define AUDIO_BUF_SIZE	1024
#define VIDEO_BUF_SIZE	65535 + 32

#define DEFAULT_TURN_SPEED 15;


@interface P2PManager ()
{
    dispatch_queue_t p2pManagerQueue;
    void *p2pManagerQueueTag;
    BOOL closeConnection;
    
    int mirrorUpDownTag;
    int mirrorLeftRightTag;
    
    unsigned char turnUpDown;
    unsigned char turnLeftRight;
    
    BOOL isCameraTurning;
}

@property (nonatomic, assign) int avIndex;
@property (nonatomic, assign) int SID;
@property (nonatomic, strong) NSString *deviceID;
@property (nonatomic, assign) unsigned char turnSpeed;

@end

static  P2PManager *sharedInstance = nil ;

@implementation P2PManager
@synthesize avIndex;
@synthesize SID;
@synthesize turnSpeed;
@synthesize deviceID = _deviceID;

+ (P2PManager *)sharedInstance
{
    static  dispatch_once_t onceToken;
    dispatch_once (& onceToken, ^ {
        sharedInstance = [[self alloc] init];
        
    });
    return sharedInstance;
}

/**
 * Standard init method.
 **/
- (id)init
{
    return [self initWithDispatchQueue:NULL];
}

/**
 * Designated initializer.
 **/
- (id)initWithDispatchQueue:(dispatch_queue_t)queue
{
    if ((self = [super init]))
    {
        if (queue)
        {
            p2pManagerQueue = queue;
#if !OS_OBJECT_USE_OBJC
            dispatch_retain(p2pManagerQueue);
#endif
        }
        else
        {
            const char *p2pManagerQueueName = [[self className] UTF8String];
            p2pManagerQueue = dispatch_queue_create(p2pManagerQueueName, NULL);
        }
        
         p2pManagerQueueTag = & p2pManagerQueueTag;
        dispatch_queue_set_specific( p2pManagerQueue,  p2pManagerQueueTag,  p2pManagerQueueTag, NULL);
        closeConnection = NO;
        isCameraTurning = NO;
        SID = -999999;
        avIndex = -999999;
        mirrorUpDownTag = 1;
        mirrorLeftRightTag = 1;
        turnUpDown = 0;
        turnLeftRight = 0;
        self.turnSpeed = DEFAULT_TURN_SPEED;
    }
    return self;
}

- (NSString *)className
{
    // Override me (if needed) to provide a customized module name.
    // This name is used as the name of the dispatch_queue which could aid in debugging.
    
    return NSStringFromClass([self class]);
}

- (void)dealloc
{
#if !OS_OBJECT_USE_OBJC
    dispatch_release(moduleQueue);
#endif
}

- (instancetype)initWithDelegate:(id<P2PManagerDelegate>)delegate;
{
    self  = [super init];
    if (self) {
        
        [self setDelegate:delegate];
        
    }
    return self;
}

- (void)setDelegate:(id<P2PManagerDelegate>)delegate
{
    dispatch_block_t block = ^{
        
        _delegate = delegate;
        
    };
    
    if (dispatch_get_specific(p2pManagerQueueTag))
        block();
    else
        dispatch_async(p2pManagerQueue, block);
}

- (void)removeDelegate
{
    dispatch_block_t block = ^{
        
        [self setDelegate:nil];
        
    };
    
    if (dispatch_get_specific(p2pManagerQueueTag))
        block();
    else
        dispatch_async(p2pManagerQueue, block);
}

- (dispatch_queue_t)p2pManagerQueue
{
    return p2pManagerQueue;
}

- (void *)p2pManagerQueueTag
{
    return p2pManagerQueueTag;
}

- (unsigned char)turnSpeed
{
    __block unsigned char result = DEFAULT_TURN_SPEED;
    dispatch_block_t block = ^{
        
        result = turnSpeed;
        
    };
    
    if (dispatch_get_specific(p2pManagerQueueTag))
        block();
    else
        dispatch_sync(p2pManagerQueue, block);
    
    return result;
}

- (void)setTurnSpeed:(unsigned char)TurnSpeed
{
    dispatch_block_t block = ^{
        
        turnSpeed = TurnSpeed;
        
    };
    
    if (dispatch_get_specific(p2pManagerQueueTag))
        block();
    else
        dispatch_async(p2pManagerQueue, block);
}

- (int)avIndex
{
    __block int result = -1;
    
    dispatch_block_t block = ^{
        
        result = avIndex;
        
    };
    
    if (dispatch_get_specific(p2pManagerQueueTag))
        block();
    else
        dispatch_sync(p2pManagerQueue, block);
    
    return result;
}

- (void)setAvIndex:(int)avindex
{
    dispatch_block_t block = ^{
        
        avIndex = avindex;
        
    };
    
    if (dispatch_get_specific(p2pManagerQueueTag))
        block();
    else
        dispatch_async(p2pManagerQueue, block);
}

- (int)SID
{
    __block int result = 0;
    
    dispatch_block_t block = ^{
        
        result = SID;
        
    };
    
    if (dispatch_get_specific(p2pManagerQueueTag))
        block();
    else
        dispatch_sync(p2pManagerQueue, block);
    
    return result;
}

- (void)setSID:(int)sid
{
    dispatch_block_t block = ^{
        SID = sid;
    };
    
    if (dispatch_get_specific(p2pManagerQueueTag))
        block();
    else
        dispatch_async(p2pManagerQueue, block);
}

- (NSString *)deviceID
{
    __block NSString * result = nil;
    
    dispatch_block_t block = ^{
        
        result = _deviceID;
        
    };
    
    if (dispatch_get_specific(p2pManagerQueueTag))
        block();
    else
        dispatch_sync(p2pManagerQueue, block);
    
    return result;
}

- (void)setDeviceID:(NSString *)deviceID
{
    dispatch_block_t block = ^{
        
        _deviceID = [deviceID copy];
        
    };
    
    if (dispatch_get_specific(p2pManagerQueueTag))
        block();
    else
        dispatch_async(p2pManagerQueue, block);
}


unsigned int _getTickCount() {
    
    struct timeval tv;
    
    if (gettimeofday(&tv, NULL) != 0)
        return 0;
    
    return (tv.tv_sec * 1000 + tv.tv_usec / 1000);
}

- (void)getMediaInfoWithVideoIndex:(int )arg
{
    if (!dispatch_get_specific(p2pManagerQueueTag)) return;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(p2pManager:didStartPlayWithDEviceID:)]) {
        [self.delegate p2pManager:self didStartPlayWithDEviceID:[self.deviceID copy]];
    }
    
    NSLog(@"[thread_ReceiveVideo] Starting...");

//    char *receiveBuff = malloc(VIDEO_BUF_SIZE);
    Byte g711AudioBuff[325];
    Byte pcmAudioBuff[651];
    int videoBuffLength;
    int audioBuffLength;
    unsigned int frmNo;
    int ret;
    int frame1 = 32 * 1024;
    int frame2 = 128 * 1024;
    int frame3 = 240;//240/480/720
    FRAMEINFO_t frameInfo;
    
    while (!closeConnection)
    {
        char *receiveBuff = malloc(VIDEO_BUF_SIZE);
//        ret = avRecvFrameData(arg, receiveBuff, VIDEO_BUF_SIZE, (char *)&frameInfo, sizeof(FRAMEINFO_t), &frmNo);
        ret = avRecvFrameData2(avIndex, receiveBuff, VIDEO_BUF_SIZE, &frame1, &frame2, (char *)&frameInfo, sizeof(FRAMEINFO_t), &frame3, &frmNo);
        if(ret == AV_ER_DATA_NOREADY)
        {
            usleep(30000);
            continue;
        }
        else if(ret == AV_ER_LOSED_THIS_FRAME)
        {
            NSLog(@"Lost video frame NO[%d]", frmNo);
            continue;
        }
        else if(ret == AV_ER_INCOMPLETE_FRAME)
        {
            NSLog(@"Incomplete video frame NO[%d]", frmNo);
            continue;
        }
        else if(ret == AV_ER_SESSION_CLOSE_BY_REMOTE)
        {
            NSLog(@"[thread_ReceiveVideo] AV_ER_SESSION_CLOSE_BY_REMOTE");
            break;
        }
        else if(ret == AV_ER_REMOTE_TIMEOUT_DISCONNECT)
        {
            NSLog(@"[thread_ReceiveVideo] AV_ER_REMOTE_TIMEOUT_DISCONNECT");
            break;
        }
        else if(ret == IOTC_ER_INVALID_SID)
        {
            NSLog(@"[thread_ReceiveVideo] Session cant be used anymore");
            break;
        }
        //这里是帧格式判断
        if(frameInfo.flags == IPC_FRAME_FLAG_IFRAME)
        {
            // got an IFrame, draw it.
        }
        
        if(ret > 0)
        {
            if (0 == memcmp(receiveBuff, "00dc", 4) || 0 == memcmp(receiveBuff, "01dc", 4)) {
                // Video frame
                //把字节buff转化成data
                NSData *videoData = [NSData dataWithBytes:receiveBuff length:VIDEO_BUF_SIZE];
                //获取视频流的长度
                [videoData getBytes:&videoBuffLength range:NSMakeRange(4, 4)];
                //截取视频流，加上头部信息字节32位
                NSData *data = [videoData subdataWithRange:NSMakeRange(0, videoBuffLength + 32)];
                if (self.delegate && [self.delegate respondsToSelector:@selector(p2pManager:didReadVideoData:)]){
                    [self.delegate p2pManager:self didReadVideoData:[data copy]];
                }
                //释放临时变量
                videoData = nil;
                data = nil;
                
            }else if (0 == memcmp(receiveBuff, "01wb", 4)){
                //Audio frame
                //把字节buff转化成data
                NSData *audioData = [NSData dataWithBytes:receiveBuff length:VIDEO_BUF_SIZE];
                //获取音频流的长度
                [audioData getBytes:&audioBuffLength range:NSMakeRange(4, 4)];
                LOG(@"%d",audioData.length);
                LOG(@"length:%d",audioBuffLength);
                //截取音频流，加上头部信息16字节
                NSData *data = [audioData subdataWithRange:NSMakeRange(16, audioData.length - 16)];
                LOG(@"%d",data.length);
                // Decode and play
                [data getBytes:g711AudioBuff length:325];
                
                //将标准的g711数据转换成pcm数据，以320字节分包，得到包的数量
                int packetNum = G711ABuf2PCMBuf_HISI((unsigned char*)pcmAudioBuff,
                                                   651,
                                                   (const unsigned char*)g711AudioBuff,
                                                   325,
                                                   G711_BIG_ENDIAN)/320;
                if (self.delegate && [self.delegate respondsToSelector:@selector(p2pManager:didReadAudioData:)]) {
                    for (int i = 0; i != packetNum; ++i) {
                        [self.delegate p2pManager:self didReadAudioData:[NSData dataWithBytes:pcmAudioBuff+i*320 length:320]];
                    }
                }
                
                //释放临时变量
                audioData = nil;
                data = nil;
            }
        }
        
        free(receiveBuff);
    }
    
//    free(receiveBuff);
    [self stopP2PWithAvIndex:arg];
    avClientStop(arg);
    NSLog(@"avClientStop OK");
    IOTC_Session_Close(self.SID);
    NSLog(@"IOTC_Session_Close OK");
    avDeInitialize();
    IOTC_DeInitialize();
    closeConnection = NO;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(p2pManager:didStopPlayWithDEviceID:)]) {
        [self.delegate p2pManager:self didStopPlayWithDEviceID:[self.deviceID copy]];
    }
    
    [self setDeviceID:nil];
    
    NSLog(@"[thread_ReceiveVideo] thread exit");
}

- (int)start_ipcam_stream:(int)avindex {
    
    if (!dispatch_get_specific(p2pManagerQueueTag)) return 0;
    
    [self setAvIndex:avindex];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(p2pManager:didStartTryToPlayerWithDeviceID:)]) {
        [self.delegate p2pManager:self didStartTryToPlayerWithDeviceID:[self deviceID]];
    }
    
    int ret = 0;
    unsigned short val = 0;
    
    if ((ret = avSendIOCtrl(avIndex, IOTYPE_INNER_SND_DATA_DELAY, (char *)&val, sizeof(unsigned short)) < 0))
    {
        NSLog(@"start_ipcam_stream_failed[%d]", ret);
        
        avClientStop(avIndex);
        NSLog(@"avClientStop OK");
        IOTC_Session_Close(self.SID);
        NSLog(@"IOTC_Session_Close OK");
        avDeInitialize();
        IOTC_DeInitialize();
        closeConnection = NO;
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(p2pManager:didFailedStartPlayWithDeviceID:)])
        {
            [self.delegate p2pManager:self didFailedStartPlayWithDeviceID:self.deviceID];
        }
        return 0;
    }
    
    SMsgAVIoctrlAVStream ioMsg;
    memset(&ioMsg, 0, sizeof(SMsgAVIoctrlAVStream));
    ioMsg.channel = 0;/*QVGA*/
    //ioMsg.channel = 1;/*VGA*/
    //ioMsg.channel = 2;/*720*/
    if ((ret = avSendIOCtrl(avIndex, IOTYPE_USER_IPCAM_START, (char *)&ioMsg, sizeof(SMsgAVIoctrlAVStream)) < 0))
    {
        NSLog(@"start_ipcam_stream_failed[%d]", ret);
        
        avClientStop(avIndex);
        NSLog(@"avClientStop OK");
        IOTC_Session_Close(self.SID);
        NSLog(@"IOTC_Session_Close OK");
        avDeInitialize();
        IOTC_DeInitialize();
        closeConnection = NO;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(p2pManager:didFailedStartPlayWithDeviceID:)]) {
            [self.delegate p2pManager:self didFailedStartPlayWithDeviceID:self.deviceID];
        }
        
        return 0;
    }
    
    if ((ret = avSendIOCtrl(avIndex, IOTYPE_USER_IPCAM_AUDIOSTART, (char *)&ioMsg, sizeof(SMsgAVIoctrlAVStream)) < 0))
    {
        NSLog(@"start_ipcam_stream_failed[%d]", ret);
        
        avClientStop(avIndex);
        NSLog(@"avClientStop OK");
        IOTC_Session_Close(self.SID);
        NSLog(@"IOTC_Session_Close OK");
        avDeInitialize();
        IOTC_DeInitialize();
        closeConnection = NO;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(p2pManager:didFailedStartPlayWithDeviceID:)]) {
            [self.delegate p2pManager:self didFailedStartPlayWithDeviceID:self.deviceID];
        }
        
        return 0;
    }
    
    int ret1;
    SMsgAVIoctrlAVStream ioMsg1;
    memset(&ioMsg1, 0, sizeof(SMsgAVIoctrlAVStream));
    if((ret1 = avSendIOCtrl(avIndex, IOTYPE_USER_IPCAM_AUDIOSTART, (char *)&ioMsg1, sizeof(SMsgAVIoctrlAVStream))) < 0)
    {
        printf("StartVideo failed[%d]\n", ret);
        return -1;
    }
    
    return 1;
}

- (void)startWithSID:(int)sid
{
    [self setSID:sid];
    
    dispatch_block_t block = ^{
        
        @autoreleasepool {
            
            unsigned long srvType;
            self.avIndex = avClientStart(self.SID, "admin", "888888", 20000, &srvType, 0);
            printf("Step 3: call avClientStart(%d).......\n", avIndex);
            
            
            if(self.avIndex < 0){
                printf("avClientStart failed[%d]\n", avIndex);
                
                avClientStop(avIndex);
                NSLog(@"avClientStop OK");
                IOTC_Session_Close(sid);
                NSLog(@"IOTC_Session_Close OK");
                avDeInitialize();
                IOTC_DeInitialize();
                closeConnection = NO;
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(p2pManager:didFailedStartPlayWithDeviceID:)]) {
                    [self.delegate p2pManager:self didFailedStartPlayWithDeviceID:self.deviceID];
                }
                
                return;
            }
            
            if ([self start_ipcam_stream:self.avIndex]){
                [self getMediaInfoWithVideoIndex:self.avIndex];
            }

        }
        
    };
    
    if (dispatch_get_specific(p2pManagerQueueTag))
        block();
    else
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}
/**
 *  停止播放
 *
 *  @param avindex 播放通道
 *
 *  @return 停止成功与否
 */
- (int)stopP2PWithAvIndex:(int)avindex
{
    int ret = 0;
    SMsgAVIoctrlAVStream ioMsg;
    memset(&ioMsg, 0, sizeof(SMsgAVIoctrlAVStream));
    if ((ret = avSendIOCtrl(avindex, IOTYPE_USER_IPCAM_STOP, (char *)&ioMsg, sizeof(SMsgAVIoctrlAVStream)) < 0))
    {
        NSLog(@"stop_ipcam_stream_failed[%d]", ret);
        return 0;
    }
    return 1;
}

- (void)closeConnection
{
    if (!closeConnection) {
        if (SID == -999999) return;
        if (avIndex == -999999) return;
        if (_deviceID == nil)  return;
        
        closeConnection = YES;
    }
}

- (void)checkConnectTypeWithDeviceID:(NSString *)deviceID
{
    dispatch_block_t block = ^{
        
        @autoreleasepool {
            
            int ret;
            
            LOG(@"AVStream Client Start");
            [self setDeviceID:deviceID];
            
            // use which Master base on location, port 0 means to get a random port.
            unsigned short nUdpPort = (unsigned short)(10000 + (_getTickCount() % 10000));
            ret = IOTC_Initialize(nUdpPort, "50.19.254.134", "122.248.234.207", "m4.iotcplatform.com", "m5.iotcplatform.com");
            LOG(@"IOTC_Initialize() ret = %d", ret);
            
            if (ret != IOTC_ER_NoERROR) {
                LOG(@"IOTCAPIs exit...");
                IOTC_DeInitialize();
                return;
            }
            
            // alloc 4 sessions for video and two-way audio
            avInitialize(4);
            
            SID = IOTC_Connect_ByUID((char *)[[deviceID copy] UTF8String]);
            /*
             // use IOTC_Connect_ByUID or IOTC_Connect_ByName to connect with device
             //NSString *aesString = @"your aes key";
             //SID = IOTC_Connect_ByUID2((char *)[UID UTF8String], (char *)[aesString UTF8String], IOTC_SECURE_MODE);
             
             //SID = IOTC_Connect_ByName("AHUA000099DGCEX", "JSW");
             
             printf("Step 2: call IOTC_Connect_ByUID2(%s) ret(%d).......\n", [deviceID UTF8String], SID);
             */
            struct st_SInfo Sinfo;
            ret = IOTC_Session_Check(SID, &Sinfo);
            CONNECT_TYPE connectType;
            //网络情况
            if (ret >= 0){
                if(Sinfo.Mode == 0){
                    connectType = CONNECT_P2P_TYPE;
                    printf("Device is from %s:%d[%s] Mode=P2P\n",Sinfo.RemoteIP, Sinfo.RemotePort, Sinfo.UID);
                }else if (Sinfo.Mode == 1){
                    connectType = CONNECT_RELAY_TYPE;
                    printf("Device is from %s:%d[%s] Mode=RLY\n",Sinfo.RemoteIP, Sinfo.RemotePort, Sinfo.UID);
                }else if (Sinfo.Mode == 2){
                    connectType = CONNECT_LAN_TYPE;
                    printf("Device is from %s:%d[%s] Mode=LAN\n",Sinfo.RemoteIP, Sinfo.RemotePort, Sinfo.UID);
                }
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(p2pManager:didConnectDeviceID:withType:ip:port:sid:)]) {
                    [self.delegate p2pManager:self didConnectDeviceID:[NSString stringWithUTF8String:Sinfo.UID]withType:connectType ip:[NSString stringWithUTF8String:Sinfo.RemoteIP] port:Sinfo.RemotePort sid:SID];
                }
            }else{

                IOTC_Session_Close(SID);
                NSLog(@"IOTC_Session_Close OK");
                avDeInitialize();
                IOTC_DeInitialize();
                closeConnection = NO;
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(p2pManager:didFailedStartPlayWithDeviceID:)]) {
                    [self.delegate p2pManager:self didFailedStartPlayWithDeviceID:self.deviceID];
                }

            }

        }
    };
    
    if (dispatch_get_specific(p2pManagerQueueTag))
        block();
    else
        dispatch_async(p2pManagerQueue, block);
}

- (void)setMirrorUpDown
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        [self _setMirrorUpDown];
        
        }
    };
    
    if (dispatch_get_specific(p2pManagerQueueTag))
        block();
    else
        dispatch_async(p2pManagerQueue, block);
}
- (void)setMirrorLeftRight
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        [self _setMirrorUpDown];
        
    }
    };
    
    if (dispatch_get_specific(p2pManagerQueueTag))
        block();
    else
        dispatch_async(p2pManagerQueue, block);
}

- (void)_setMirrorUpDown
{
    if (!dispatch_get_specific(p2pManagerQueueTag)) return;
    
    int ret = 0;
    int IOTYPE_USER_IPCAM_SETMIRROR = 0x2008;
    if ((ret = avSendIOCtrl([self avIndex], IOTYPE_USER_IPCAM_SETMIRROR, (char *)&mirrorUpDownTag, sizeof(int)) < 0)) {
        LOG(@"set_mirror_failed[%d]", ret);
        return;
    };
    
    if (mirrorUpDownTag == 1) {
        mirrorUpDownTag = 0;
    }else{
        mirrorUpDownTag = 1;
    }
}
- (void)_setMirrorLeftRight
{
    if (!dispatch_get_specific(p2pManagerQueueTag)) return;
    
    int ret = 0;
    int IOTYPE_USER_IPCAM_SETFLIP = 0x2009;
    if ((ret = avSendIOCtrl([self avIndex], IOTYPE_USER_IPCAM_SETFLIP, (char *)&mirrorLeftRightTag, sizeof(int)) < 0)) {
        LOG(@"set_mirror_failed[%d]", ret);
        return;
    };
    
    if (mirrorLeftRightTag == 1) {
        mirrorLeftRightTag = 0;
    }else{
        mirrorLeftRightTag = 1;
    }
}

- (void)stopTurnCamera
{
    [self turnWithSpeed:self.turnSpeed type:CAMERA_TURN_TYPE_STOP];
}

- (void)startTurnCameraWithSpeed:(unsigned char)speed type:(CAMERA_TURN_TYPE)cameraTurnType
{
    [self turnWithSpeed:speed type:cameraTurnType];
}

- (void)turnWithSpeed:(unsigned char)speed type:(CAMERA_TURN_TYPE)cameraTurnType
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        [self _turnWithSpeed:speed type:cameraTurnType];
        
        }
    };
    
    if (dispatch_get_specific(p2pManagerQueueTag))
        block();
    else
        dispatch_async(p2pManagerQueue, block);
}

- (void)_turnWithSpeed:(unsigned char)speed type:(CAMERA_TURN_TYPE)cameraTurnType
{
    if (!dispatch_get_specific(p2pManagerQueueTag)) return;
    
    int ret = 0;
    int IOTYPE_USER_IPCAM_PTZ_COMMAND = 0x1001;
    SMsgAVIoctrlPtzCmd ioMsg;
    memset(&ioMsg, 0, sizeof(SMsgAVIoctrlPtzCmd));
    
    ioMsg.speed = speed;
    ioMsg.control = cameraTurnType;
//    ioMsg.channel = 1;
    
    if (speed <= 0) {
        speed = self.turnSpeed;
    }
    
    if ((ret = avSendIOCtrl([self avIndex], IOTYPE_USER_IPCAM_PTZ_COMMAND, (char *)&ioMsg, sizeof(SMsgAVIoctrlPtzCmd)) < 0))
    {
        NSLog(@"turn_camera_failed[%d]", ret);
        isCameraTurning = NO;
        return;
    }
    
    switch (cameraTurnType) {
        case CAMERA_TURN_TYPE_STOP:
            isCameraTurning = NO;
            break;
            
        default:
            isCameraTurning = YES;
            break;
    }
}
@end
