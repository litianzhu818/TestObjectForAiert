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
#import <sys/time.h>

#define AUDIO_BUF_SIZE	1024
#define VIDEO_BUF_SIZE	65535 + 32

@interface P2PManager ()
{
    dispatch_queue_t p2pManagerQueue;
    void *p2pManagerQueueTag;
    BOOL closeConnection;
}

@property (nonatomic, assign) int avIndex;
@property (nonatomic, assign) int SID;

@end

static  P2PManager *sharedInstance = nil ;

@implementation P2PManager
@synthesize avIndex;
@synthesize SID;

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
        SID = -999999;
        avIndex = -999999;
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

unsigned int _getTickCount() {
    
    struct timeval tv;
    
    if (gettimeofday(&tv, NULL) != 0)
        return 0;
    
    return (tv.tv_sec * 1000 + tv.tv_usec / 1000);
}

//void *thread_ReceiveAudio(void *arg)
//{
//    NSLog(@"[thread_ReceiveAudio] Starting...");
//    
//    int avIndex = *(int *)arg;
//    char buf[AUDIO_BUF_SIZE];
//    unsigned int frmNo;
//    int ret;
//    FRAMEINFO_t frameInfo;
//    
//    while (1)
//    {
//        ret = avCheckAudioBuf(avIndex);
//        if (ret < 0) break;
//        if (ret < 3) // determined by audio frame rate
//        {
//            usleep(120000);
//            continue;
//        }
//        
//        ret = avRecvAudioData(avIndex, buf, AUDIO_BUF_SIZE, (char *)&frameInfo, sizeof(FRAMEINFO_t), &frmNo);
//        
//        if(ret == AV_ER_SESSION_CLOSE_BY_REMOTE)
//        {
//            NSLog(@"[thread_ReceiveAudio] AV_ER_SESSION_CLOSE_BY_REMOTE");
//            break;
//        }
//        else if(ret == AV_ER_REMOTE_TIMEOUT_DISCONNECT)
//        {
//            NSLog(@"[thread_ReceiveAudio] AV_ER_REMOTE_TIMEOUT_DISCONNECT");
//            break;
//        }
//        else if(ret == IOTC_ER_INVALID_SID)
//        {
//            NSLog(@"[thread_ReceiveAudio] Session cant be used anymore");
//            break;
//        }
//        else if (ret == AV_ER_LOSED_THIS_FRAME)
//        {
//            continue;
//        }
//        
//        // Now the data is ready in audioBuffer[0 ... ret - 1]
//        // Do something here
//    }
//    
//    NSLog(@"[thread_ReceiveAudio] thread exit");
//    return 0;
//}
//
//void *thread_ReceiveVideo(void *arg)
//{
//    NSLog(@"[thread_ReceiveVideo] Starting...");
//    
//    int avIndex = *(int *)arg;
//    char *receiveBuff = malloc(VIDEO_BUF_SIZE + 32);
//    char *videoBuff = malloc(VIDEO_BUF_SIZE);
//    unsigned int frmNo;
//    int ret;
//    FRAMEINFO_t frameInfo;
//    
//    while (1)
//    {
//        ret = avRecvFrameData(avIndex, receiveBuff, VIDEO_BUF_SIZE + 32, (char *)&frameInfo, sizeof(FRAMEINFO_t), &frmNo);
//        
//        if(ret == AV_ER_DATA_NOREADY)
//        {
//            usleep(30000);
//            continue;
//        }
//        else if(ret == AV_ER_LOSED_THIS_FRAME)
//        {
//            NSLog(@"Lost video frame NO[%d]", frmNo);
//            continue;
//        }
//        else if(ret == AV_ER_INCOMPLETE_FRAME)
//        {
//            NSLog(@"Incomplete video frame NO[%d]", frmNo);
//            continue;
//        }
//        else if(ret == AV_ER_SESSION_CLOSE_BY_REMOTE)
//        {
//            NSLog(@"[thread_ReceiveVideo] AV_ER_SESSION_CLOSE_BY_REMOTE");
//            break;
//        }
//        else if(ret == AV_ER_REMOTE_TIMEOUT_DISCONNECT)
//        {
//            NSLog(@"[thread_ReceiveVideo] AV_ER_REMOTE_TIMEOUT_DISCONNECT");
//            break;
//        }
//        else if(ret == IOTC_ER_INVALID_SID)
//        {
//            NSLog(@"[thread_ReceiveVideo] Session cant be used anymore");
//            break;
//        }
//        //这里是帧格式判断
//        if(frameInfo.flags == IPC_FRAME_FLAG_IFRAME)
//        {
//            // got an IFrame, draw it.
//        }
//        
//        if(ret > 0)
//        {
//            memset(videoBuff, 0, VIDEO_BUF_SIZE);
//            memcpy(videoBuff, receiveBuff+32, VIDEO_BUF_SIZE);
//            NSData *videoData = [NSData dataWithBytes:videoBuff length:VIDEO_BUF_SIZE];
//            
//            [[(__bridge P2PManager*)arg delegate] p2pManager:nil didReadVideoData:videoData];
//        }
//    }
//    free(receiveBuff);
//    free(videoBuff);
//    NSLog(@"[thread_ReceiveVideo] thread exit");
//    return 0;
//}



- (void)getMediaInfoWithVideoIndex:(int )arg
{
    if (!dispatch_get_specific(p2pManagerQueueTag)) return;
    
    NSLog(@"[thread_ReceiveVideo] Starting...");

    char *receiveBuff = malloc(VIDEO_BUF_SIZE);
    Byte g711AudioBuff[325];
    Byte pcmAudioBuff[651];
    int videoBuffLength;
    int audioBuffLength;
    unsigned int frmNo;
    int ret;
    FRAMEINFO_t frameInfo;
    
    while (!closeConnection)
    {
        ret = avRecvFrameData(arg, receiveBuff, VIDEO_BUF_SIZE, (char *)&frameInfo, sizeof(FRAMEINFO_t), &frmNo);
        
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
    }
    
    free(receiveBuff);
    
    avClientStop(self.avIndex);
    NSLog(@"avClientStop OK");
    IOTC_Session_Close(self.SID);
    NSLog(@"IOTC_Session_Close OK");
    avDeInitialize();
    IOTC_DeInitialize();
    closeConnection = NO;
    NSLog(@"[thread_ReceiveVideo] thread exit");
}

- (int)start_ipcam_stream:(int)avindex {
    
    if (!dispatch_get_specific(p2pManagerQueueTag)) return 0;
    
    [self setAvIndex:avindex];
    
    int ret = 0;
    unsigned short val = 0;
    
    if ((ret = avSendIOCtrl(avIndex, IOTYPE_INNER_SND_DATA_DELAY, (char *)&val, sizeof(unsigned short)) < 0))
    {
        NSLog(@"start_ipcam_stream_failed[%d]", ret);
        IOTC_DeInitialize();
        return 0;
    }
    
    SMsgAVIoctrlAVStream ioMsg;
    memset(&ioMsg, 0, sizeof(SMsgAVIoctrlAVStream));
    if ((ret = avSendIOCtrl(avIndex, IOTYPE_USER_IPCAM_START, (char *)&ioMsg, sizeof(SMsgAVIoctrlAVStream)) < 0))
    {
        NSLog(@"start_ipcam_stream_failed[%d]", ret);
        return 0;
    }
    
    if ((ret = avSendIOCtrl(avIndex, IOTYPE_USER_IPCAM_AUDIOSTART, (char *)&ioMsg, sizeof(SMsgAVIoctrlAVStream)) < 0))
    {
        NSLog(@"start_ipcam_stream_failed[%d]", ret);
        return 0;
    }
    
    return 1;
}

- (void)startWithDeviceID:(int)sid
{
    [self setSID:sid];
    
    dispatch_block_t block = ^{
        
        @autoreleasepool {
            
            unsigned long srvType;
            self.avIndex = avClientStart(self.SID, "admin", "888888", 20000, &srvType, 0);
            printf("Step 3: call avClientStart(%d).......\n", avIndex);
            
            if(self.avIndex < 0){
                printf("avClientStart failed[%d]\n", avIndex);
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

- (void)closeConnection
{
    if (!closeConnection) {
        if (SID == -999999) return;
        if (avIndex == -999999) return;
        
        closeConnection = YES;
    }
}

- (void)checkConnectTypeWithDeviceID:(NSString *)deviceID
{
    dispatch_block_t block = ^{
        
        @autoreleasepool {
            
            int ret;
            
            LOG(@"AVStream Client Start");
            
            // use which Master base on location, port 0 means to get a random port.
            unsigned short nUdpPort = (unsigned short)(10000 + (_getTickCount() % 10000));
            ret = IOTC_Initialize(nUdpPort, "50.19.254.134", "122.248.234.207", "m4.iotcplatform.com", "m5.iotcplatform.com");
            LOG(@"IOTC_Initialize() ret = %d", ret);
            
            if (ret != IOTC_ER_NoERROR) {
                LOG(@"IOTCAPIs exit...");
                //return;
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
            }

        }
    };
    
    if (dispatch_get_specific(p2pManagerQueueTag))
        block();
    else
        dispatch_async(p2pManagerQueue, block);
}

//- (void)start:(NSString *)UID {
//    
//    dispatch_block_t block = ^{
//        
//        @autoreleasepool {
//            
//            int ret, SID;
//            NSLog(@"AVStream Client Start");
//            
//            // use which Master base on location, port 0 means to get a random port.
//            unsigned short nUdpPort = (unsigned short)(10000 + (_getTickCount() % 10000));
//            ret = IOTC_Initialize(nUdpPort, "50.19.254.134", "122.248.234.207", "m4.iotcplatform.com", "m5.iotcplatform.com");
//            NSLog(@"IOTC_Initialize() ret = %d", ret);
//            
//            if (ret != IOTC_ER_NoERROR) {
//                NSLog(@"IOTCAPIs exit...");
//                return;
//            }
//            
//            // alloc 4 sessions for video and two-way audio
//            avInitialize(4);
//            
//            SID = IOTC_Connect_ByUID((char *)[UID UTF8String]);
//            
//            printf("Step 2: call IOTC_Connect_ByUID2(%s) ret(%d).......\n", [UID UTF8String], SID);
//            struct st_SInfo Sinfo;
//            ret = IOTC_Session_Check(SID, &Sinfo);
//            
//            if (ret >= 0)
//            {
//                if(Sinfo.Mode == 0)
//                    printf("Device is from %s:%d[%s] Mode=P2P\n",Sinfo.RemoteIP, Sinfo.RemotePort, Sinfo.UID);
//                else if (Sinfo.Mode == 1)
//                    printf("Device is from %s:%d[%s] Mode=RLY\n",Sinfo.RemoteIP, Sinfo.RemotePort, Sinfo.UID);
//                else if (Sinfo.Mode == 2)
//                    printf("Device is from %s:%d[%s] Mode=LAN\n",Sinfo.RemoteIP, Sinfo.RemotePort, Sinfo.UID);
//            }
//
//            
//            unsigned long srvType;
//            int avIndex = avClientStart(SID, "admin", "888888", 20000, &srvType, 0);
//            printf("Step 3: call avClientStart(%d).......\n", avIndex);
//            
//            if(avIndex < 0)
//            {
//                printf("avClientStart failed[%d]\n", avIndex);
//                return;
//            }
//            
//            if ([self start_ipcam_stream:avIndex])
//            {
//                pthread_t ThreadVideo_ID, ThreadAudio_ID;
//                pthread_create(&ThreadVideo_ID, NULL, &thread_ReceiveVideo, (void *)&avIndex);
//                pthread_create(&ThreadAudio_ID, NULL, &thread_ReceiveAudio, (void *)&avIndex);
//                pthread_join(ThreadVideo_ID, NULL);
//                pthread_join(ThreadAudio_ID, NULL);
//            }
//            
//            avClientStop(avIndex);
//            NSLog(@"avClientStop OK");
//            IOTC_Session_Close(SID);
//            NSLog(@"IOTC_Session_Close OK");
//            avDeInitialize();
//            IOTC_DeInitialize();
//            
//            NSLog(@"StreamClient exit...");
//        }
//    };
//    
//    if (dispatch_get_specific(p2pManagerQueueTag))
//        block();
//    else
//        dispatch_async(p2pManagerQueue, block);
//}
@end
