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

#define DEFAULT_TURN_SPEED 15

#define G711_AUDIO_DATA_LENGTH 164
#define PCM_AUDIO_DATA_LENGTH (2*(G711_AUDIO_DATA_LENGTH -4))
#define STANDARD_PCM_AUDIO_DATA_LENGTH 320

typedef struct
{
    int brightness;// 亮度 0~255 默认128
    int contrast;//对比度0~255 默认128
    int saturation;//饱和度0~255 默认128
}AnaLog;


@interface P2PManager ()
{
    //视频播放的队列
    dispatch_queue_t p2pVideoPlayManagerQueue;
    //P2PManager类属性设置的队列
    dispatch_queue_t p2pSettingManagerQueue;
    //声音操作的队列
    dispatch_queue_t p2pAudioPlayManagerQueue;
    //关闭和打开连接的队列
    dispatch_queue_t p2pPlayStopManagerQueue;
    //简单的请求操作队列。例如调整视频清晰度，对比度，转动摄像机等
    dispatch_queue_t p2pSampleRequestManagerQueue;
    //发送声音的队列，主要用对讲
    dispatch_queue_t p2pSendAudioDataManagerQueue;
    //开启或者关闭对讲时，本地做服务器的队列，因为本地做服务器需要等待摄像机来连接，所以需要单独开启线程
    dispatch_queue_t p2pStartStopSeverManagerQueue;
    //转动摄像机的操作队列，转动命令不能实时，需要单开线程
    dispatch_queue_t p2pTurnCameraManagerQueue;
    
    void *p2pVideoPlayManagerQueueTag;
    void *p2pSettingManagerQueueTag;
    void *p2pAudioPlayManagerQueueTag;
    void *p2pPlayStopManagerQueueTag;
    void *p2pSampleRequestManagerQueueTag;
    void *p2pSendAudioDataManagerQueueTag;
    void *p2pStartStopSeverManagerQueueTag;
    void *p2pTurnCameraManagerQueueTag;
    
    BOOL closeConnection;
    
    int mirrorUpDownTag;
    int mirrorLeftRightTag;
    
    unsigned char turnUpDown;
    unsigned char turnLeftRight;
    
    BOOL isCameraTurning;
    BOOL isAvServerStart;
}

@property (nonatomic, assign) int avIndex;
@property (nonatomic, assign) int SID;
@property (nonatomic, strong) NSString *deviceID;
@property (nonatomic, assign) unsigned char turnSpeed;
@property (nonatomic, assign) NSInteger brightness;
@property (nonatomic, assign) NSInteger contrast;
@property (nonatomic, assign) NSInteger saturation;

@end

static  P2PManager *sharedInstance = nil ;

@implementation P2PManager
@synthesize avIndex;
@synthesize SID;
@synthesize turnSpeed;
@synthesize brightness;
@synthesize contrast;
@synthesize saturation;
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
            p2pVideoPlayManagerQueue = queue;
            p2pSettingManagerQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
#if !OS_OBJECT_USE_OBJC
            dispatch_retain(p2pManagerQueue);
#endif
        }
        else
        {
            const char *p2pVideoPlayManagerQueueName = [[self className] UTF8String];
            const char *p2pSettingManagerQueueName = [@"P2P_IO_CONTROL_QUEUE" UTF8String];
            const char *p2pAudioPlayManagerQueueName = [@"P2P_IO_AUDIO_PLAY_QUEUE" UTF8String];
            const char *p2pPlayStopManagerQueueName = [@"P2P_PLAT_STOP_QUEUE" UTF8String];
            const char *p2pSampleRequestManagerQueueName = [@"P2P_SAMOLE_REQUEST_QUEUE" UTF8String];
            const char *p2pSendAudioDataManagerQueueName = [@"P2P_SEND_AUDIO_DATA_QUEUE" UTF8String];
            const char *p2pStartStopSeverManagerQueueName = [@"P2P_START_STOP_SERVER_QUEUE" UTF8String];
            const char *p2pTurnCameraManagerQueueName = [@"P2P_TURN_CAMERA_QUEUE" UTF8String];
            
            p2pVideoPlayManagerQueue = /*dispatch_queue_create(p2pVideoPlayManagerQueueName, NULL)*/dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            p2pSettingManagerQueue = dispatch_queue_create(p2pSettingManagerQueueName, NULL);
            p2pAudioPlayManagerQueue = dispatch_queue_create(p2pAudioPlayManagerQueueName, NULL);
            p2pPlayStopManagerQueue = dispatch_queue_create(p2pPlayStopManagerQueueName, NULL);
            p2pSampleRequestManagerQueue = dispatch_queue_create(p2pSampleRequestManagerQueueName, NULL);
            p2pSendAudioDataManagerQueue = dispatch_queue_create(p2pSendAudioDataManagerQueueName, NULL);
            p2pStartStopSeverManagerQueue = dispatch_queue_create(p2pStartStopSeverManagerQueueName, NULL);
            p2pTurnCameraManagerQueue = dispatch_queue_create(p2pTurnCameraManagerQueueName, NULL);
        }
        
        p2pVideoPlayManagerQueueTag = & p2pVideoPlayManagerQueueTag;
        p2pSettingManagerQueueTag = & p2pSettingManagerQueueTag;
        p2pPlayStopManagerQueueTag = & p2pPlayStopManagerQueueTag;
        p2pAudioPlayManagerQueueTag = & p2pAudioPlayManagerQueueTag;
        p2pSampleRequestManagerQueueTag = & p2pSampleRequestManagerQueueTag;
        p2pSendAudioDataManagerQueueTag = & p2pSendAudioDataManagerQueueTag;
        p2pStartStopSeverManagerQueueTag = & p2pStartStopSeverManagerQueueTag;
        p2pTurnCameraManagerQueueTag = & p2pTurnCameraManagerQueueTag;
        
        dispatch_queue_set_specific( p2pVideoPlayManagerQueue,  p2pVideoPlayManagerQueueTag,  p2pVideoPlayManagerQueueTag, NULL);
        dispatch_queue_set_specific( p2pSettingManagerQueue,  p2pSettingManagerQueueTag,  p2pSettingManagerQueueTag, NULL);
        dispatch_queue_set_specific( p2pAudioPlayManagerQueue,  p2pAudioPlayManagerQueueTag,  p2pAudioPlayManagerQueueTag, NULL);
        dispatch_queue_set_specific( p2pPlayStopManagerQueue,   p2pPlayStopManagerQueueTag,  p2pPlayStopManagerQueueTag, NULL);
        dispatch_queue_set_specific( p2pSampleRequestManagerQueue,  p2pSampleRequestManagerQueueTag,  p2pSampleRequestManagerQueueTag, NULL);
        dispatch_queue_set_specific( p2pSendAudioDataManagerQueue,  p2pSendAudioDataManagerQueueTag,  p2pSendAudioDataManagerQueueTag, NULL);
        dispatch_queue_set_specific( p2pStartStopSeverManagerQueue,  p2pStartStopSeverManagerQueueTag,  p2pStartStopSeverManagerQueueTag, NULL);
        dispatch_queue_set_specific( p2pTurnCameraManagerQueue,  p2pTurnCameraManagerQueueTag,  p2pTurnCameraManagerQueueTag, NULL);
        
        closeConnection = NO;
        isCameraTurning = NO;
        isAvServerStart = NO;
        SID = -999999;
        avIndex = -999999;
        mirrorUpDownTag = 4;
        mirrorLeftRightTag = 4;
        turnUpDown = 0;
        turnLeftRight = 0;
        self.turnSpeed = DEFAULT_TURN_SPEED;
        self.brightness = DEFAULT_SETTING_VALUE;
        self.contrast = DEFAULT_SETTING_VALUE;
        self.saturation = DEFAULT_SETTING_VALUE;
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
    
    if (dispatch_get_specific(p2pSettingManagerQueueTag))
        block();
    else
        dispatch_async(p2pSettingManagerQueue, block);
}

- (void)removeDelegate
{
    dispatch_block_t block = ^{
        
        [self setDelegate:nil];
        
    };
    
    if (dispatch_get_specific(p2pSettingManagerQueueTag))
        block();
    else
        dispatch_async(p2pSettingManagerQueue, block);
}

- (dispatch_queue_t)p2pVideoPlayManagerQueue
{
    return p2pVideoPlayManagerQueue;
}

- (void *)p2pVideoPlayManagerQueueTag
{
    return p2pVideoPlayManagerQueueTag;
}

- (unsigned char)turnSpeed
{
    __block unsigned char result = DEFAULT_TURN_SPEED;
    
    dispatch_block_t block = ^{
        
        result = turnSpeed;
        
    };
    
    if (dispatch_get_specific(p2pSettingManagerQueueTag))
        block();
    else
        dispatch_sync(p2pSettingManagerQueue, block);
    
    return result;
}

- (void)setTurnSpeed:(unsigned char)TurnSpeed
{
    dispatch_block_t block = ^{
        
        turnSpeed = TurnSpeed;
        
    };
    
    if (dispatch_get_specific(p2pSettingManagerQueueTag))
        block();
    else
        dispatch_async(p2pSettingManagerQueue, block);
}

- (int)avIndex
{
    __block int result = -1;
    
    dispatch_block_t block = ^{
        
        result = avIndex;
        
    };
    
    if (dispatch_get_specific(p2pSettingManagerQueueTag))
        block();
    else
        dispatch_sync(p2pSettingManagerQueue, block);
    return result;
}

- (void)setAvIndex:(int)avindex
{
    dispatch_block_t block = ^{
        
        avIndex = avindex;
        
    };
    
    if (dispatch_get_specific(p2pSettingManagerQueueTag))
        block();
    else
        dispatch_async(p2pSettingManagerQueue, block);
}

- (int)SID
{
    __block int result = 0;
    
    dispatch_block_t block = ^{
        
        result = SID;
        
    };
    
    if (dispatch_get_specific(p2pSettingManagerQueueTag))
        block();
    else
        dispatch_sync(p2pSettingManagerQueue, block);
    
    return result;
}

- (void)setSID:(int)sid
{
    dispatch_block_t block = ^{
        SID = sid;
    };
    
    if (dispatch_get_specific(p2pSettingManagerQueueTag))
        block();
    else
        dispatch_async(p2pSettingManagerQueue, block);
}

- (NSString *)deviceID
{
    __block NSString * result = nil;
    
    dispatch_block_t block = ^{
        
        result = _deviceID;
        
    };
    
    if (dispatch_get_specific(p2pSettingManagerQueueTag))
        block();
    else
        dispatch_sync(p2pSettingManagerQueue, block);
    
    return result;
}

- (void)setDeviceID:(NSString *)deviceID
{
    dispatch_block_t block = ^{
        
        _deviceID = [deviceID copy];
        
    };
    
    if (dispatch_get_specific(p2pSettingManagerQueueTag))
        block();
    else
        dispatch_async(p2pSettingManagerQueue, block);
}

- (NSInteger)brightness
{
    __block NSInteger result = DEFAULT_SETTING_VALUE;
    
    dispatch_block_t block = ^{
        
        result = brightness;
        
    };
    
    if (dispatch_get_specific(p2pSettingManagerQueueTag))
        block();
    else
        dispatch_sync(p2pSettingManagerQueue, block);
    
    return result;
}

- (void)setBrightness:(NSInteger)_brightness
{
    dispatch_block_t block = ^{
        
        brightness = _brightness;
        
    };
    
    if (dispatch_get_specific(p2pSettingManagerQueueTag))
        block();
    else
        dispatch_async(p2pSettingManagerQueue, block);
}

- (NSInteger)contrast
{
    __block NSInteger result = DEFAULT_SETTING_VALUE;
    
    dispatch_block_t block = ^{
        
        result = contrast;
        
    };
    
    if (dispatch_get_specific(p2pSettingManagerQueueTag))
        block();
    else
        dispatch_sync(p2pSettingManagerQueue, block);
    
    return result;
}

- (void)setContrast:(NSInteger)_contrast
{
    dispatch_block_t block = ^{
        
        contrast = _contrast;
        
    };
    
    if (dispatch_get_specific(p2pSettingManagerQueueTag))
        block();
    else
        dispatch_async(p2pSettingManagerQueue, block);
}

- (NSInteger)saturation
{
    __block NSInteger result = DEFAULT_SETTING_VALUE;
    
    dispatch_block_t block = ^{
        
        result = saturation;
        
    };
    
    if (dispatch_get_specific(p2pSettingManagerQueueTag))
        block();
    else
        dispatch_sync(p2pSettingManagerQueue, block);
    
    return result;
}

- (void)setSaturation:(NSInteger)_saturation
{
    dispatch_block_t block = ^{
        
        saturation = _saturation;
        
    };
    
    if (dispatch_get_specific(p2pSettingManagerQueueTag))
        block();
    else
        dispatch_async(p2pSettingManagerQueue, block);
}

unsigned int _getTickCount() {
    
    struct timeval tv;
    
    if (gettimeofday(&tv, NULL) != 0)
        return 0;
    
    return (tv.tv_sec * 1000 + tv.tv_usec / 1000);
}

- (void)sendTalkData:(BytePtr)pBuffer length:(int)nBufferLen
{
    
    //LOG(@"PCM语音包大小：%d",nBufferLen);
    __block BytePtr newBuffer = pBuffer;
    
    dispatch_block_t block = ^{@autoreleasepool{
        
        if (closeConnection) return;
        
        //数组的前四位是固定的，分别为0x0,0x01,0x50,0x00
        Byte sendG711AudioBuffer[G711_AUDIO_DATA_LENGTH];
        FRAMEINFO_t frameInfo;
        
        memset(&frameInfo, 0, sizeof(frameInfo));
        frameInfo.codec_id = MEDIA_CODEC_AUDIO_ADPCM;
        frameInfo.flags = (AUDIO_SAMPLE_8K << 2) | (AUDIO_DATABITS_16 << 1) | AUDIO_CHANNEL_MONO;
        
        for (int i=0; i<nBufferLen/PCM_AUDIO_DATA_LENGTH; ++i) {
            //将标准的pcm数据转换成hisi数据
            
            /**把PCM数据编码成海思标准格式的G711数据
             *转换后g711数据数据至少是原始g711数据的1/2
             *返回编码后的数据长度
             *blflag :大端、小端标示，默认取BIG_ENDIAN
             */
            /*int PCMBuf2G711ABuf_HISI(unsigned char* g711Buf,int g711BufLen,const unsigned char* pcmBuf,int pcmBufLen,int blflag);*/
            
            //该方法实际是从sendG711AudioBuffer的第五位开始使用的，将320的PCM转成160的G711数据包（该数据包已经有了前四位，所以还是164位）
            int nHisiLen = PCMBuf2G711ABuf_HISI(sendG711AudioBuffer, G711_AUDIO_DATA_LENGTH, (const unsigned char*)newBuffer, PCM_AUDIO_DATA_LENGTH, G711_BIG_ENDIAN);
            
            int ret;

            ret = avSendAudioData(avIndex, (char *)sendG711AudioBuffer, nHisiLen, &frameInfo, 16);
            if(ret == AV_ER_NoERROR)
            {
                LOG(@"send audio data succeed!");
            }else if (ret < 0){
                LOG(@"send audio data error!");
            }
            
            newBuffer += PCM_AUDIO_DATA_LENGTH;
        }
        
    }};
    
    if (dispatch_get_specific(p2pSendAudioDataManagerQueueTag))
        block();
    else
        dispatch_async(p2pSendAudioDataManagerQueue, block);
}


- (void)getMediaInfoWithVideoIndex:(int )arg
{
    if (!dispatch_get_specific(p2pVideoPlayManagerQueueTag)) return;
    if (closeConnection) return;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(p2pManager:didStartPlayWithDEviceID:)]) {
        [self.delegate p2pManager:self didStartPlayWithDEviceID:[self.deviceID copy]];
    }
    
    NSLog(@"[thread_ReceiveVideo] Starting...");
    
    char receiveBuff[VIDEO_BUF_SIZE] = {0};
    Byte g711AudioBuff[G711_AUDIO_DATA_LENGTH];
    Byte pcmAudioBuff[PCM_AUDIO_DATA_LENGTH];
    //Byte cabFrameInfo[16];

    
    int videoBuffLength;
    int audioBuffLength;
    unsigned int frmNo;
    int ret;
    /*
    int frame1 = 32 * 1024;
    int frame2 = 128 * 1024;
    int frame3 = 240;//240/480/720
    ret = avRecvFrameData2(avIndex, receiveBuff, VIDEO_BUF_SIZE, &frame1, &frame2, (char *)cabFrameInfo, 16, &frame3, &frmNo);
     */
    FRAMEINFO_t frameInfo;
    
    int outBufSize = 0;
    int outFrmSize = 0;
    int outFrmInfoSize = 0;
   
    while (!closeConnection)
    {
        //char *receiveBuff = malloc(VIDEO_BUF_SIZE);
#if 0
        ret = ret = avRecvFrameData(arg, receiveBuff, VIDEO_BUF_SIZE, (char *)&frameInfo, sizeof(FRAMEINFO_t), &frmNo);
#else
        ret = avRecvFrameData2(avIndex, receiveBuff, VIDEO_BUF_SIZE, &outBufSize, &outFrmSize, (char *)&frameInfo, sizeof(FRAMEINFO_t), &outFrmInfoSize, &frmNo);
#endif
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
#if 0
            if (frameInfo.codec_id == MEDIA_CODEC_VIDEO_H264)) {
#else
            if (0 == memcmp(receiveBuff, "00dc", 4) || 0 == memcmp(receiveBuff, "01dc", 4)) {
#endif
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
                //videoData = nil;
                //data = nil;
#if 0
            }else{
#else
            }else if (0 == memcmp(receiveBuff, "01wb", 4)){
#endif
                //Audio frame
                //把字节buff转化成data
                NSData *audioData = [NSData dataWithBytes:receiveBuff length:AUDIO_BUF_SIZE];
                //获取音频流的长度
                [audioData getBytes:&audioBuffLength range:NSMakeRange(4, 4)];
                
                /*
                LOG(@"%d",audioData.length);
                LOG(@"length:%d",audioBuffLength);
                 */
                
                //截取音频流，加上头部信息16字节
                NSData *data = [audioData subdataWithRange:NSMakeRange(16, audioBuffLength)];
                //LOG(@"%d",data.length);
                // Decode and play
                [data getBytes:g711AudioBuff length:164];
                
                //将标准的g711数据转换成pcm数据，以320字节分包，得到包的数量
                int packetNum = G711ABuf2PCMBuf_HISI((unsigned char*)pcmAudioBuff,
                                                   PCM_AUDIO_DATA_LENGTH,
                                                   (const unsigned char*)g711AudioBuff,
                                                   G711_AUDIO_DATA_LENGTH,
                                                   G711_BIG_ENDIAN)/STANDARD_PCM_AUDIO_DATA_LENGTH;
                if (self.delegate && [self.delegate respondsToSelector:@selector(p2pManager:didReadAudioData:)]) {
                    for (int i = 0; i < packetNum; ++i) {
                        [self.delegate p2pManager:self didReadAudioData:[NSData dataWithBytes:pcmAudioBuff + i*320 length:320]];
                    }
                }
                
                //释放临时变量
                //audioData = nil;
                //data = nil;
            }
        }
        
        //free(receiveBuff);
    }
    
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

- (void)startIpcamStream:(int)avindex withPlayType:(CAMERA_PLAY_TYPE)playType
{
    dispatch_block_t block = ^{
        
        [self start_ipcam_stream:avIndex withPlayType:playType];
    };
    
    if (dispatch_get_specific(p2pVideoPlayManagerQueueTag))
        block();
    else
        dispatch_async(p2pVideoPlayManagerQueue, block);
}


- (void)setAudioStart:(BOOL)start
{
    dispatch_block_t block = ^{
        
        [self _setAudioStart:start avIndex:self.avIndex];
    };
    
    if (dispatch_get_specific(p2pAudioPlayManagerQueueTag))
        block();
    else
        dispatch_async(p2pAudioPlayManagerQueue, block);
}

- (void)_setAudioStart:(BOOL)start avIndex:(int)avindex
{
    
    if (!dispatch_get_specific(p2pAudioPlayManagerQueueTag)) return;
    if (closeConnection) return;
    
    int ret = 0;
    int IOTYPE_USER_IPCAM_AUDIOSTART;
    
    SMsgAVIoctrlAVStream ioMsg;
    memset(&ioMsg, 0, sizeof(SMsgAVIoctrlAVStream));
    IOTYPE_USER_IPCAM_AUDIOSTART = start ? 0x300:0x301;
    
    if((ret = avSendIOCtrl(avindex, IOTYPE_USER_IPCAM_AUDIOSTART, (char *)&ioMsg, sizeof(SMsgAVIoctrlAVStream))) < 0){
        LOG(@"set_audio_start_failed[%d]", ret);
        return;
    }
    
    //请求对讲打开或者关闭
    int ret1;
    SMsgAVIoctrlAVStream ioMsg1;
    memset(&ioMsg1, 0, sizeof(SMsgAVIoctrlAVStream));
    
    if((ret1 = avSendIOCtrl(avIndex, (start ? IOTYPE_USER_IPCAM_SPEAKERSTART:IOTYPE_USER_IPCAM_SPEAKERSTOP), (char *)&ioMsg1, sizeof(SMsgAVIoctrlAVStream))) < 0)
    {
        printf("StartSpeaker failed[%d]\n", ret1);
    }

    //开启本地服务或者关闭本地服务
    [self startAvServer:start];
}
    
- (void)startAvServer:(BOOL)start
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        //开启本地服务或者关闭本地服务
        if (start) {
            
            SMsgAVIoctrlAVStream ioMsg1;
            memset(&ioMsg1, 0, sizeof(SMsgAVIoctrlAVStream));
            ioMsg1.channel = 5;
            
            int avServerStart = avServStart(SID, NULL, NULL, 10, 0, 5);
            if(avServerStart < 0){
                isAvServerStart = NO;
                printf("avServerStart failed[%d]\n", avServerStart);
            }else{
                isAvServerStart = YES;
            }
            
        }else{
            if (isAvServerStart) {
                
                avServStop(avIndex);
                isAvServerStart = NO;
            }
        }
        
    }
    };
    
    if (dispatch_get_specific(p2pStartStopSeverManagerQueueTag))
        block();
    else
        dispatch_async(p2pStartStopSeverManagerQueue, block);
}


- (int)start_ipcam_stream:(int)avindex withPlayType:(CAMERA_PLAY_TYPE)playType
{
    
    if (!dispatch_get_specific(p2pVideoPlayManagerQueueTag)) return 0;
    
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
    //ioMsg.channel = 0;/*QVGA*/
    //ioMsg.channel = 1;/*VGA*/
    ioMsg.channel = playType;/*720*/
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
    
    if (isAvServerStart) {
        [self startAvServer:!isAvServerStart];
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
            
            if ([self start_ipcam_stream:self.avIndex withPlayType:CAMERA_PLAY_TYPE_QVGA]){
                [self getMediaInfoWithVideoIndex:self.avIndex];
            }

        }
        
    };
    
    if (dispatch_get_specific(p2pVideoPlayManagerQueueTag))
        block();
    else
        dispatch_async(p2pVideoPlayManagerQueue, block);
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
    __block int result = 0;
    
    dispatch_block_t block = ^{
        
        if (closeConnection) return ;
        
        int ret = 0;
        SMsgAVIoctrlAVStream ioMsg;
        memset(&ioMsg, 0, sizeof(SMsgAVIoctrlAVStream));
        if ((ret = avSendIOCtrl(avindex, IOTYPE_USER_IPCAM_STOP, (char *)&ioMsg, sizeof(SMsgAVIoctrlAVStream)) < 0))
        {
            NSLog(@"stop_ipcam_stream_failed[%d]", ret);
            result =  0;
        }
        result =  1;
    };
    
    
    if (dispatch_get_specific(p2pPlayStopManagerQueueTag))
        block();
    else
        dispatch_async(p2pPlayStopManagerQueue, block);
    
    return result;
}

- (void)closeConnection
{
    if (!closeConnection) {
        if (SID == -999999) return;
        if (avIndex == -999999) return;
        if (_deviceID == nil)  return;
        
        closeConnection = YES;
        isAvServerStart = NO;
        isCameraTurning = NO;

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
    
    if (dispatch_get_specific(p2pVideoPlayManagerQueueTag))
        block();
    else
        dispatch_async(p2pVideoPlayManagerQueue, block);
}

- (void)setMirrorUpDown
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        [self _setMirrorUpDown];
        
        }
    };
    
    if (dispatch_get_specific(p2pSampleRequestManagerQueueTag))
        block();
    else
        dispatch_async(p2pSampleRequestManagerQueue, block);
}
- (void)setMirrorLeftRight
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        [self _setMirrorUpDown];
        
    }
    };
    
    if (dispatch_get_specific(p2pSampleRequestManagerQueueTag))
        block();
    else
        dispatch_async(p2pSampleRequestManagerQueue, block);
}

- (void)_setMirrorUpDown
{
    if (!dispatch_get_specific(p2pSampleRequestManagerQueueTag)) return;
    if (closeConnection) return;
    
    if (mirrorUpDownTag == 4) {
        mirrorUpDownTag = 2;
    }else{
        mirrorUpDownTag = 4;
    }
    
    int ret = 0;
    int IOTYPE_USER_IPCAM_SETMIRROR = 0x2008;
    if ((ret = avSendIOCtrl([self avIndex], IOTYPE_USER_IPCAM_SETMIRROR, (char *)&mirrorUpDownTag, sizeof(int)) < 0)) {
        LOG(@"set_mirror_failed[%d]", ret);
        return;
    };
}
- (void)_setMirrorLeftRight
{
    if (!dispatch_get_specific(p2pSampleRequestManagerQueueTag)) return;
    if (closeConnection) return;
    
    if (mirrorLeftRightTag == 4) {
        mirrorLeftRightTag = 1;
    }else{
        mirrorLeftRightTag = 4;
    }
    
    int ret = 0;
    int IOTYPE_USER_IPCAM_SETFLIP = 0x2008;
    if ((ret = avSendIOCtrl([self avIndex], IOTYPE_USER_IPCAM_SETFLIP, (char *)&mirrorLeftRightTag, sizeof(int)) < 0)) {
        LOG(@"set_mirror_failed[%d]", ret);
        return;
    };
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
    
    if (dispatch_get_specific(p2pTurnCameraManagerQueueTag))
        block();
    else
        dispatch_async(p2pTurnCameraManagerQueue, block);
}

- (void)_turnWithSpeed:(unsigned char)speed type:(CAMERA_TURN_TYPE)cameraTurnType
{
    if (!dispatch_get_specific(p2pTurnCameraManagerQueueTag)) return;
    if (closeConnection) return;
    
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

- (void)setCameraBrightness:(NSInteger)Brightness
{
    [self setBrightness:Brightness];
    [self setBrightness:self.brightness contrast:self.contrast saturation:self.saturation];
}

- (void)setCameraContrast:(NSInteger)Contrast
{
    [self setContrast:Contrast];
    [self setBrightness:self.brightness contrast:self.contrast saturation:self.saturation];
}

- (void)setCameraSaturation:(NSInteger)Saturation
{
    [self setSaturation:Saturation];
    [self setBrightness:self.brightness contrast:self.contrast saturation:self.saturation];
}

- (void)setCameraDefauleValue
{
    [self setBrightness:DEFAULT_SETTING_VALUE];
    [self setContrast:DEFAULT_SETTING_VALUE];
    [self setSaturation:DEFAULT_SETTING_VALUE];
    [self setBrightness:self.brightness contrast:self.contrast saturation:self.saturation];
}

- (void)setBrightness:(NSInteger)Brightness contrast:(NSInteger)Contrast saturation:(NSInteger)Saturation
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        [self _setBrightness:Brightness contrast:Contrast saturation:Saturation];
        
    }};
    
    if (dispatch_get_specific(p2pSampleRequestManagerQueueTag))
        block();
    else
        dispatch_async(p2pSampleRequestManagerQueue, block);
}

-(void)_setBrightness:(NSInteger)Brightness contrast:(NSInteger)Contrast saturation:(NSInteger)Saturation
{
    if (!dispatch_get_specific(p2pSampleRequestManagerQueueTag)) return;
    if (closeConnection) return;
    
    int ret = 0;
    int IOTYPE_USER_IPCAM_SETANLOG = 0x200C;
    
    AnaLog anaLog;
    memset(&anaLog, 0, sizeof(AnaLog));
    
    anaLog.brightness = Brightness;
    anaLog.contrast = Contrast;
    anaLog.saturation = Saturation;
    
    if ((ret = avSendIOCtrl([self avIndex], IOTYPE_USER_IPCAM_SETANLOG, (char *)&anaLog, sizeof(AnaLog)) < 0))
    {
        NSLog(@"setting_camera_brightness_contrast_saturation_failed:[%d]", ret);
        isCameraTurning = NO;
        return;
    }
    
}


@end
