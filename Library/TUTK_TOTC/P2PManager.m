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
#import <sys/time.h>

#define AUDIO_BUF_SIZE	1024
#define VIDEO_BUF_SIZE	128*1024

@implementation P2PManager

- (instancetype)initWithDelegate:(id<P2PManagerDelegate>)delegate;
{
    self  = [super init];
    if (self) {
        
        [self setDelegate:delegate];
        
    }
    return self;
}
- (void)removeDelegate
{
    [self setDelegate:nil];
}

unsigned int _getTickCount() {
    
    struct timeval tv;
    
    if (gettimeofday(&tv, NULL) != 0)
        return 0;
    
    return (tv.tv_sec * 1000 + tv.tv_usec / 1000);
}

void *thread_ReceiveAudio(void *arg)
{
    NSLog(@"[thread_ReceiveAudio] Starting...");
    
    int avIndex = *(int *)arg;
    char buf[AUDIO_BUF_SIZE];
    unsigned int frmNo;
    int ret;
    FRAMEINFO_t frameInfo;
    
    while (1)
    {
        ret = avCheckAudioBuf(avIndex);
        if (ret < 0) break;
        if (ret < 3) // determined by audio frame rate
        {
            usleep(120000);
            continue;
        }
        
        ret = avRecvAudioData(avIndex, buf, AUDIO_BUF_SIZE, (char *)&frameInfo, sizeof(FRAMEINFO_t), &frmNo);
        
        if(ret == AV_ER_SESSION_CLOSE_BY_REMOTE)
        {
            NSLog(@"[thread_ReceiveAudio] AV_ER_SESSION_CLOSE_BY_REMOTE");
            break;
        }
        else if(ret == AV_ER_REMOTE_TIMEOUT_DISCONNECT)
        {
            NSLog(@"[thread_ReceiveAudio] AV_ER_REMOTE_TIMEOUT_DISCONNECT");
            break;
        }
        else if(ret == IOTC_ER_INVALID_SID)
        {
            NSLog(@"[thread_ReceiveAudio] Session cant be used anymore");
            break;
        }
        else if (ret == AV_ER_LOSED_THIS_FRAME)
        {
            continue;
        }
        
        // Now the data is ready in audioBuffer[0 ... ret - 1]
        // Do something here
    }
    
    NSLog(@"[thread_ReceiveAudio] thread exit");
    return 0;
}

void *thread_ReceiveVideo(void *arg)
{
    NSLog(@"[thread_ReceiveVideo] Starting...");
    
    int avIndex = *(int *)arg;
    char *buf = malloc(VIDEO_BUF_SIZE);
    unsigned int frmNo;
    int ret;
    FRAMEINFO_t frameInfo;
    
    while (1)
    {
        ret = avRecvFrameData(avIndex, buf, VIDEO_BUF_SIZE, (char *)&frameInfo, sizeof(FRAMEINFO_t), &frmNo);
        
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
        
        if(frameInfo.flags == IPC_FRAME_FLAG_IFRAME)
        {
            // got an IFrame, draw it.
        }
    }
    free(buf);
    NSLog(@"[thread_ReceiveVideo] thread exit");
    return 0;
}

- (int)start_ipcam_stream:(int)avIndex {
    
    int ret;
    unsigned short val = 0;
    
    if ((ret = avSendIOCtrl(avIndex, IOTYPE_INNER_SND_DATA_DELAY, (char *)&val, sizeof(unsigned short)) < 0))
    {
        NSLog(@"start_ipcam_stream_failed[%d]", ret);
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

- (void)startWithDeviceID:(int)SID
{
    //int SID = IOTC_Connect_ByUID((char *)[deviceID UTF8String]);
    unsigned long srvType;
    int avIndex = avClientStart(SID, "admin", "888888", 20000, &srvType, 0);
    printf("Step 3: call avClientStart(%d).......\n", avIndex);
    
    if(avIndex < 0){
        printf("avClientStart failed[%d]\n", avIndex);
        return;
    }
    
    if ([self start_ipcam_stream:avIndex]){
        pthread_t ThreadVideo_ID, ThreadAudio_ID;
        pthread_create(&ThreadVideo_ID, NULL, &thread_ReceiveVideo, (void *)&avIndex);
        pthread_create(&ThreadAudio_ID, NULL, &thread_ReceiveAudio, (void *)&avIndex);
        pthread_join(ThreadVideo_ID, NULL);
        pthread_join(ThreadAudio_ID, NULL);
    }
    
    avClientStop(avIndex);
    NSLog(@"avClientStop OK");
    IOTC_Session_Close(SID);
    NSLog(@"IOTC_Session_Close OK");
    avDeInitialize();
    IOTC_DeInitialize();
    
    NSLog(@"StreamClient exit...");

}

- (void)checkConnectTypeWithDeviceID:(NSString *)deviceID
{
    int ret, SID;
    
    NSLog(@"AVStream Client Start");
    
    // use which Master base on location, port 0 means to get a random port.
    unsigned short nUdpPort = (unsigned short)(10000 + (_getTickCount() % 10000));
    ret = IOTC_Initialize(nUdpPort, "50.19.254.134", "122.248.234.207", "m4.iotcplatform.com", "m5.iotcplatform.com");
    NSLog(@"IOTC_Initialize() ret = %d", ret);
    
    if (ret != IOTC_ER_NoERROR) {
        NSLog(@"IOTCAPIs exit...");
        return;
    }
    
    // alloc 4 sessions for video and two-way audio
    avInitialize(4);
    
    SID = IOTC_Connect_ByUID((char *)[deviceID UTF8String]);
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

//- (void)start:(NSString *)UID {
//    
//    int ret, SID;
//    
//    NSLog(@"AVStream Client Start");
//    
//    // use which Master base on location, port 0 means to get a random port.
//    unsigned short nUdpPort = (unsigned short)(10000 + (_getTickCount() % 10000));
//    ret = IOTC_Initialize(nUdpPort, "50.19.254.134", "122.248.234.207", "m4.iotcplatform.com", "m5.iotcplatform.com");
//    NSLog(@"IOTC_Initialize() ret = %d", ret);
//    
//    if (ret != IOTC_ER_NoERROR) {
//        NSLog(@"IOTCAPIs exit...");
//        return;
//    }
//    
//    // alloc 4 sessions for video and two-way audio
//    avInitialize(4);
//    
//    // use IOTC_Connect_ByUID or IOTC_Connect_ByName to connect with device
//#if 1
//    
//    NSString *aesString = @"your aes key";
//    
//    SID = IOTC_Connect_ByUID((char *)[UID UTF8String]);
//    //    SID = IOTC_Connect_ByUID2((char *)[UID UTF8String], (char *)[aesString UTF8String], IOTC_SECURE_MODE);
//    
//    //SID = IOTC_Connect_ByName("AHUA000099DGCEX", "JSW");
//    
//    printf("Step 2: call IOTC_Connect_ByUID2(%s) ret(%d).......\n", [UID UTF8String], SID);
//    struct st_SInfo Sinfo;
//    ret = IOTC_Session_Check(SID, &Sinfo);
//    
//    if (ret >= 0)
//    {
//        if(Sinfo.Mode == 0)
//            printf("Device is from %s:%d[%s] Mode=P2P\n",Sinfo.RemoteIP, Sinfo.RemotePort, Sinfo.UID);
//        else if (Sinfo.Mode == 1)
//            printf("Device is from %s:%d[%s] Mode=RLY\n",Sinfo.RemoteIP, Sinfo.RemotePort, Sinfo.UID);
//        else if (Sinfo.Mode == 2)
//            printf("Device is from %s:%d[%s] Mode=LAN\n",Sinfo.RemoteIP, Sinfo.RemotePort, Sinfo.UID);
//    }
//    
//#else
//    
//    char *DeviceName="EF4989RE9YK7TM6PSFY1", *DevicePWD="888888";
//    SID = IOTC_Connect_ByName(DeviceName,DevicePWD);
//    printf("Step 2: call IOTC_Connect_ByName(%s,%s).......\n", DeviceName, DevicePWD);
//    
//#endif
//    
//    unsigned long srvType;
//    int avIndex = avClientStart(SID, "admin", "888888", 20000, &srvType, 0);
//    printf("Step 3: call avClientStart(%d).......\n", avIndex);
//    
//    if(avIndex < 0)
//    {
//        printf("avClientStart failed[%d]\n", avIndex);
//        return;
//    }
//    
//    if ([self start_ipcam_stream:avIndex])
//    {
//        pthread_t ThreadVideo_ID, ThreadAudio_ID;
//        pthread_create(&ThreadVideo_ID, NULL, &thread_ReceiveVideo, (void *)&avIndex);
//        pthread_create(&ThreadAudio_ID, NULL, &thread_ReceiveAudio, (void *)&avIndex);
//        pthread_join(ThreadVideo_ID, NULL);
//        pthread_join(ThreadAudio_ID, NULL);
//    }
//    
//    avClientStop(avIndex);
//    NSLog(@"avClientStop OK");
//    IOTC_Session_Close(SID);
//    NSLog(@"IOTC_Session_Close OK");
//    avDeInitialize();
//    IOTC_DeInitialize();
//    
//    NSLog(@"StreamClient exit...");
//}
@end
