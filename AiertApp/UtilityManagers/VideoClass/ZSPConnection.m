

#import "ZSPConnection.h"
#import "GCDAsyncSocket.h"
#include "systemparameterdefine.h"
#import "AiertProtocol.h"
#include "G711Convert_HISI.h"
#import "AppData.h"
#import "BasicDefine.h"

#define TAG_VIDEO_HEADER                       1
#define TAG_FRAME_HEADER                       2
#define TAG_VIDEOFRAME_BODY                    3
#define TAG_LOGIN_RESPONSE                     4
#define TAG_READ_DEVLARGEPARAM_RESPONSE_HEADER 5
#define TAG_READ_DEVLARGEPARAM_RESPONSE_BODY   6
#define TAG_GET_WIFI_AP_LIST_HEADER            7
#define TAG_GET_WIFI_AP_LIST_BODY              8
#define TAG_SET_WIFI_AP_RESPONSE               9
#define TAG_SET_WIFI_PARAM_RESPONSE            10
#define TAG_SET_WIFI_STATUS_RESPONSE           11
#define TAG_SET_USER_PASSWORD_RESPONSE         12

// Audio
#define TAG_AUDIOFRAME_BODY             13
#define TAG_AUDIO_RESPONSE              14
#define TAG_TALK_ON_RESPONSE            15
#define TAG_R_DEVICEINFO                16

#define TAG_DVRTALK_ON_RESPONSE         17

#define READ_DATA_TIMEOUT_INTERVAL      10
#define CONNECT_TIMEOUT_INTERVAL        10
#define TAG_READ_VIDEO_TIMOUT_INTERVAL  20


typedef struct LOGIN_INFO
{
    char userName[16];
    char passWord[16];
}Login_Info;

@interface ZSPConnection ()
{
    GCDAsyncSocket *_asyncSocket;
    GCDAsyncSocket *_commandSocket; // 1.0.9 wifiSocket
    GCDAsyncSocket *_talkSocket;
    
    Byte sendG711AudioBuffer[325];
    Byte sendPcmAudioBuffer[641];
    Byte recvAudioBuffer[325];
    Byte recvPcmAudioBuffer[641];
    
    ZXA_HEADER _header;
    SYSTEM_PARAMETER _sysParam;
    NSUInteger _currentMediaType;
    Byte magicBuff[4];
    int _audioPacketSize;
    
    BOOL _bLocalConnection;
}

@property (copy, nonatomic) NSString *userName;
@property (copy, nonatomic) NSString *password;
@property (copy, nonatomic) NSString *deviceIp;
@property (nonatomic) NSInteger port;

@property (strong, nonatomic) NSMutableData *wifiLoginData;
@property (strong, nonatomic) NSMutableData *wifiParamData;
@property (strong, nonatomic) NSMutableData *headData;

@property NSInteger currentChannel;
@end

@implementation ZSPConnection

- (void)dealloc
{
}
- (void)closeCommandSocket
{
    if (_commandSocket) {
        [_commandSocket setDelegate:nil];
        [_commandSocket disconnect];
        _commandSocket = nil;
    }
}
- (void)closeTalkSocket
{
    if (_talkSocket) {
        [_talkSocket setDelegate:nil];
        [_talkSocket disconnect];
        _talkSocket = nil;
    }
}

- (id)initWithDelegate:(id<ZSPConnectionDelegate>)delegate
{
    if (self = [super init]) {
        self.zspConnectionDelegate = delegate;
    }
    return self;
}
- (void)composeRequestPacketWithCommand:(unsigned short)aCommand type:(NSInteger)type body:(NSData *)bodyData
{
    
    @synchronized (self)
	{
        NSInteger bodyLen = [bodyData length];
        
        _header.head = ZXAHEADER;
        _header.length = bodyLen;
        _header.type = type;
        _header.commd = aCommand;
        _header.channel = 0;//self.currentChannel;//self.deviceDetail.currentChannel;
        
        // Add packet header
        self.headData = [[NSMutableData alloc]initWithBytes:&_header length:sizeof(_header)];
        
        if (0 != bodyLen) {
            [self.headData appendData:bodyData];
        }
	}
}
- (void)composeHeadPacketWithCommand:(unsigned short)aCommand
{
    DLog(@"current channel : %d",self.currentChannel);
    [self composeRequestPacketWithCommand:aCommand type:0 body:nil];
}


#pragma mark- Request Video
- (void)composeLoginPacket
{
    Login_Info loginInfo;
    
    DLog(@"%@",self.userName);
    DLog(@"%@",self.password);
    
    memcpy(&loginInfo.userName, self.userName.UTF8String, 16);
    memcpy(&loginInfo.passWord, self.password.UTF8String, 16);
    
    [self composeRequestPacketWithCommand:CMD_REQ_LOGIN type:0 body:[NSData dataWithBytes:&loginInfo length:sizeof(loginInfo)]];
    
    //    DLog(@"login data : %@",self.loginData);
}
- (void)stopRealPlay
{
    
    DLog(@"stopDisplay !");
    
    if (_asyncSocket) {
        [_asyncSocket setDelegate:nil];
        [_asyncSocket disconnect];
        _asyncSocket = nil;
    }
}

- (void)reStartRealPlay
{
    [self stopRealPlay];
    
    [self startDisplayWithDeviceIp:self.deviceIp
                              port:self.port
                           channel:_currentChannel
                         mediaType:_currentMediaType
                     isLocalDevice:_bLocalConnection];
}

- (void)changeChannel:(NSInteger)destChannel
{
    DLog(@"channel Changed !");
    DLog(@"channel num: %d",destChannel);
    [self stopRealPlay];
    self.currentChannel = destChannel;
    
    [self startDisplayWithDeviceIp:self.deviceIp
                              port:self.port
                           channel:_currentChannel
                         mediaType:_currentMediaType
                     isLocalDevice:_bLocalConnection];
}

- (void)changeStream:(NSInteger)destMediaType
{
    [self stopRealPlay];
    
    _currentMediaType = destMediaType;
    
    [self startDisplayWithDeviceIp:self.deviceIp
                              port:self.port
                           channel:_currentChannel
                         mediaType:destMediaType
                     isLocalDevice:_bLocalConnection];
    
}

- (void)startDisplayWithLocalchannel:(NSInteger)channel
                           mediaType:(NSInteger)mediaType
                       isLocalDevice:(BOOL)bLocal
{
  
    _currentMediaType = mediaType;
    self.currentChannel = channel;
    _bLocalConnection = bLocal;
    
    DLog(@"startDisplay !");
    
    _asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_current_queue()];
    
    NSError *err = nil;
    
    if (!self.deviceIp || self.port == 0) {
        return;
    }
    
    if (![_asyncSocket connectToHost:self.deviceIp
                              onPort:self.port
                         withTimeout:CONNECT_TIMEOUT_INTERVAL
                               error:&err]) // Asynchronous!
    {
        // If there was an error, it's likely something like "already connected" or "no delegate set"
        DLog(@"erro");
    }
    
    if (VideoQualityTypeLD == mediaType) {
        [self composeHeadPacketWithCommand:CMD_START_SUBVIDEO];//流畅视频
    }else if (VideoQualityTypeSD == mediaType)
    {
        [self composeHeadPacketWithCommand:CMD_START_VIDEO];
    }else if (VideoQualityTypeHD == mediaType)
    {
        [self composeHeadPacketWithCommand:CMD_START_720P];
    }
    
    
    // Send connect info
    [_asyncSocket writeData:self.headData withTimeout:-1 tag:2];
    
    // receive header packet
    [_asyncSocket readDataToLength:16 withTimeout:TAG_READ_VIDEO_TIMOUT_INTERVAL tag:TAG_VIDEO_HEADER];
}


- (void)startDisplayWithDeviceIp:(NSString *)deviceIp
                            port:(NSInteger)port
                         channel:(NSInteger)channel
                       mediaType:(NSInteger)mediaType
                   isLocalDevice:(BOOL)bLocal
{
    _currentMediaType = mediaType;
    self.currentChannel = channel;
    self.deviceIp = deviceIp;
    self.port = port;
    _bLocalConnection = bLocal;
    
    DLog(@"startDisplay !");
    
    _asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_current_queue()];
    
    NSError *err = nil;
    
    DLog(@"ip : %@",self.deviceIp);
    DLog(@"port : %d",self.port);
    
    if (![_asyncSocket connectToHost:self.deviceIp
                             onPort:self.port
                        withTimeout:CONNECT_TIMEOUT_INTERVAL
                              error:&err]) // Asynchronous!
    {
        // If there was an error, it's likely something like "already connected" or "no delegate set"
        DLog(@"erro");
    }
    
    if (VideoQualityTypeLD == mediaType) {
        [self composeHeadPacketWithCommand:CMD_START_SUBVIDEO];//流畅视频
    }else if (VideoQualityTypeSD == mediaType)
    {
        [self composeHeadPacketWithCommand:CMD_START_VIDEO];
    }else if (VideoQualityTypeHD == mediaType)
    {
        [self composeHeadPacketWithCommand:CMD_START_720P];
    }
    
    
    // Send connect info
    [_asyncSocket writeData:self.headData withTimeout:-1 tag:2];
    
    // receive header packet
    [_asyncSocket readDataToLength:16 withTimeout:TAG_READ_VIDEO_TIMOUT_INTERVAL tag:TAG_VIDEO_HEADER];
}
//MARK:这里是登录方法
//TODO:找到问题
- (void)loginWithUserName:(NSString *)userName
                 password:(NSString *)password
                 deviceIP:(NSString *)ip
               devicePort:(NSUInteger)port
{
//    _currentMediaType = 1;
//    self.currentChannel = 1;
    self.deviceIp = ip;
    self.port = port;
    _bLocalConnection = YES;
    
    self.userName = userName;
    self.password = password;
    
    // connect to device

    _commandSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_current_queue()];
    
    NSError *err = nil;
    
    DLog(@"ip : %@",self.self.deviceIp);
    DLog(@"port : %d",self.self.port);
    
    if (![_commandSocket connectToHost:self.deviceIp onPort:self.port withTimeout:1 error:&err]) // Asynchronous!
    {
        // If there was an error, it's likely something like "already connected" or "no delegate set"
    }
    //   self.currentChannel = 0;
    [self composeLoginPacket];
    
    // Send login info
    [_commandSocket writeData:self.headData withTimeout:-1 tag:1];
    
    // receive header packet
    [_commandSocket readDataToLength:20 withTimeout:READ_DATA_TIMEOUT_INTERVAL tag:TAG_LOGIN_RESPONSE];
}

#pragma mark - Audio Control


- (void)openSound:(BOOL)bOpen
{
    if (_asyncSocket) {
        
        int audioOpen = bOpen ? 1:0;

        [self composeRequestPacketWithCommand:CMD_SET_AUDIOSWITCH type:0 body:[NSData dataWithBytes:&audioOpen length:4]];
        [_asyncSocket writeData:self.headData withTimeout:-1 tag:100];
    }
}

- (void)openMic:(BOOL)bOpen
{
    //    CMD_TALK_ON
    if (nil == _talkSocket) {
        _talkSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_current_queue()];
        
        if (![_talkSocket connectToHost:self.deviceIp onPort:self.port withTimeout:CONNECT_TIMEOUT_INTERVAL error:nil]) // Asynchronous!
        {
            // If there was an error, it's likely something like "already connected" or "no delegate set"
        }
        
    }
    if (bOpen){
        [self composeRequestPacketWithCommand:CMD_TALK_ON type:0 body:nil];
        [_talkSocket writeData:self.headData withTimeout:-1 tag:101];
        
        [_talkSocket readDataToLength:24 withTimeout:-1 tag:TAG_TALK_ON_RESPONSE];
    }
    else{
        [self composeRequestPacketWithCommand:CMD_TALK_OFF type:0 body:nil];
        [_talkSocket writeData:self.headData withTimeout:-1 tag:102];
    }
}

- (void)sendMicDataToDevice:(BytePtr)pBuffer length:(int)nBufferLen
{
    @synchronized (self){
        int nStandPacketLen = 640;
        if (0 != _audioPacketSize && 0 == _audioPacketSize%80) {
            nStandPacketLen = _audioPacketSize*2;
        }
        DLog(@"%d",nStandPacketLen);
        int nHisiLen;
        NSData *tempAudioData;
        for (int i=0; i<nBufferLen/nStandPacketLen; ++i) {
            //将标准的pcm数据转换成hisi数据
            nHisiLen = PCMBuf2G711ABuf_HISI(sendG711AudioBuffer,512,(const unsigned char*)pBuffer, nStandPacketLen,G711_BIG_ENDIAN);
            
            tempAudioData = [NSData dataWithBytes:sendG711AudioBuffer length:nHisiLen];
            
            [self composeRequestPacketWithCommand:CMD_TALK_DATA type:0 body:tempAudioData];
            [_talkSocket writeData:self.headData withTimeout:-1 tag:103];
            
            pBuffer+=nStandPacketLen;
        }
    }
}


#pragma mark -About Device Network Settings
- (void)getDeviceInfo
{
//    [self composeHeadPacketWithCommand:CMD_R_DEV_INFO];
//    
//    commandSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_current_queue()];
//    
//    NSError *err = nil;
//    
//    DLog(@"ip : %@",self.deviceIp);
//    DLog(@"port : %d",self.port);
//    
//    if (![commandSocket connectToHost:self.deviceIp
//                               onPort:self.port
//                          withTimeout:CONNECT_TIMEOUT_INTERVAL
//                                error:&err]) // Asynchronous!
//    {
//        // If there was an error, it's likely something like "already connected" or "no delegate set"
//    }
//    
//    // Send getDevParam info
//    [commandSocket writeData:self.headData withTimeout:-1 tag:105];
//    
//    // receive header packet
//    [commandSocket readDataToLength:152 withTimeout:-1 tag:TAG_R_DEVICEINFO];
}
- (void)getDeviceLargeParam
{
    
//    [self composeHeadPacketWithCommand:CMD_R_DEV_PARA];
//    
//    // connect to device
//    
//    commandSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_current_queue()];
//    
//    NSError *err = nil;
//    
//    DLog(@"ip : %@",self.deviceIp);
//    DLog(@"port : %d",self.port);
//    
//    if (![commandSocket connectToHost:self.deviceIp
//                               onPort:self.port
//                          withTimeout:CONNECT_TIMEOUT_INTERVAL
//                                error:&err]) // Asynchronous!
//    {
//        // If there was an error, it's likely something like "already connected" or "no delegate set"
//    }
//    
//    // Send getDevParam info
//    [commandSocket writeData:self.headData withTimeout:-1 tag:1];
//    
//    // receive header packet
//    [commandSocket readDataToLength:12 withTimeout:-1 tag:TAG_READ_DEVLARGEPARAM_RESPONSE_HEADER];
}
- (void)getWifiApList
{
//    [self composeHeadPacketWithCommand:CMD_G_WIFI_AP];
//    
//    // connect to device
//    
//    commandSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_current_queue()];
//    
//    NSError *err = nil;
//    
//    DLog(@"ip : %@",self.deviceDetail.ip);
//    DLog(@"port : %d",self.deviceDetail.port);
//    
//    if (![commandSocket connectToHost:self.deviceDetail.ip onPort:self.deviceDetail.port withTimeout:CONNECT_TIMEOUT_INTERVAL error:&err]) // Asynchronous!
//    {
//        // If there was an error, it's likely something like "already connected" or "no delegate set"
//    }
//    
//    // Send getDevParam info
//    [commandSocket writeData:self.headData withTimeout:-1 tag:1];
//    
//    // receive header packet
//    [commandSocket readDataToLength:12 withTimeout:-1 tag:TAG_GET_WIFI_AP_LIST_HEADER];
}
- (void)setAWifiToDevice:(NSValue *)aWifi
{
//    DLog(@"queue %s:%@ : %@ ",dispatch_queue_get_label(dispatch_get_current_queue()),NSStringFromSelector(_cmd),self);
//    
//    TYPE_WIFI_LOGIN wifiLogin;
//    _header.head = ZXAHEADER;
//    _header.length = sizeof(wifiLogin);
//    _header.type = 0;
//    _header.commd = CMD_S_WIFI_CONNECT;
//    _header.channel = 0;//self.deviceDetail.currentChannel;
//    
//    [aWifi getValue:&wifiLogin];
//    
//    DLog(@"wifi name: %s",wifiLogin.RouteDeviceName);
//    // Add packet header
//    self.wifiLoginData = [[[NSMutableData alloc]initWithBytes:&_header length:sizeof(_header)] autorelease];
//    [self.wifiLoginData appendBytes:&wifiLogin length:sizeof(wifiLogin)];
//    
//    // connect to device
//    
//    commandSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_current_queue()];
//    
//    NSError *err = nil;
//    
//    DLog(@"ip : %@",self.deviceDetail.ip);
//    DLog(@"port : %d",self.deviceDetail.port);
//    
//    if (![commandSocket connectToHost:self.deviceDetail.ip onPort:self.deviceDetail.port withTimeout:CONNECT_TIMEOUT_INTERVAL error:&err]) // Asynchronous!
//    {
//        // If there was an error, it's likely something like "already connected" or "no delegate set"
//    }
//    
//    // Send getDevParam info
//    [commandSocket writeData:self.wifiLoginData withTimeout:-1 tag:1];
//    
//    // receive header packet
//    [commandSocket readDataToLength:16 withTimeout:-1 tag:TAG_SET_WIFI_AP_RESPONSE];
}
- (void)setWifiStatusToDevice:(BOOL)bWifiOpen
{
//    sysParam.m_NetWork.m_WifiConfig.WifiAddrMode.m_u8Selected = bWifiOpen;
//    sysParam.m_NetWork.m_changeinfo |= (1 << 10);
//    _header.head = ZXAHEADER;
//    _header.length = sizeof(sysParam);
//    _header.type = 0;
//    _header.commd = CMD_S_DEV_PARA;
//    _header.channel = 0;//self.deviceDetail.currentChannel;
//    
//    
//    // Add packet header
//    self.wifiParamData = [[[NSMutableData alloc]initWithBytes:&_header length:sizeof(_header)] autorelease];
//    [self.wifiParamData appendBytes:&sysParam length:sizeof(sysParam)];
//    
//    // connect to device
//    
//    commandSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_current_queue()];
//    
//    NSError *err = nil;
//    
//    DLog(@"ip : %@",self.deviceDetail.ip);
//    DLog(@"port : %d",self.deviceDetail.port);
//    
//    if (![commandSocket connectToHost:self.deviceDetail.ip onPort:self.deviceDetail.port withTimeout:CONNECT_TIMEOUT_INTERVAL error:&err]) // Asynchronous!
//    {
//        // If there was an error, it's likely something like "already connected" or "no delegate set"
//    }
//    
//    // Send getDevParam info
//    [commandSocket writeData:self.wifiParamData withTimeout:-1 tag:1];
//    
//    // receive header packet
//    [commandSocket readDataToLength:16 withTimeout:-1 tag:TAG_SET_WIFI_STATUS_RESPONSE];
}

- (void)setUser:(NSString *)aNewUser password:(NSString *)aNewPassword
{
//    if (nil == aNewPassword) {
//        DLog(@"局域网修改密码aNewPassword = nil");
//        aNewPassword = @"";
//    }
//    
//    char *aNewUserName = (char *)[aNewUser cStringUsingEncoding:NSASCIIStringEncoding];
//    
//    char bNewUserName[16] = "";
//    strcpy(bNewUserName,aNewUserName);
//    ZmdEnCrypt(bNewUserName, CRYPT_KEY);
//    
//    SINGLEUSERSET *pUserSet = sysParam.m_Users.m_UserSet;
//    
//    NSInteger userIndex = -1;
//    for (int i=0; i!=16; ++i) {
//        BOOL bUserExist = YES;
//        char *pTemUser = pUserSet[i].m_cUserName;
//        if (pTemUser[5] == '\0') {
//            for (int j=0; j!=5; ++j) {
//                if (bNewUserName[j] != pTemUser[j]) {
//                    bUserExist = NO;
//                    break;
//                }
//            }
//        }
//        if (bUserExist) {
//            userIndex = i;
//            break;
//        }
//    }
//    if (-1 == userIndex) {
//        DLog(@"User not exists !");
//        //       return;
//    }
//    
//    NSInteger passLen = [aNewPassword length];
//    //    if (passLen > 16) {
//    //        UIAlertView *alert = [[UIAlertView alloc]
//    //                              initWithTitle:NSLocalizedString(@"密码最多为16位", @"密码最多为16位")
//    //                              message:nil
//    //                              delegate:self
//    //                              cancelButtonTitle:NSLocalizedString(@"重新设置", @"重新设置")
//    //                              otherButtonTitles:nil];
//    //        [alert show];
//    //        [alert release];
//    //        return;
//    //    }
//    char *pass = (char *)[aNewPassword cStringUsingEncoding:NSASCIIStringEncoding];
//    // cmz修改
//    char cPass[16] = "";
//    strcpy(cPass,pass);
//    ZmdEnCrypt(cPass, CRYPT_KEY);
//    DLog(@"out pass : %s",cPass);
//    
//    memset(sysParam.m_Users.m_UserSet[userIndex].m_s32Passwd, 0, 16);
//    memcpy(sysParam.m_Users.m_UserSet[userIndex].m_s32Passwd, cPass, passLen);
//    sysParam.m_Users.m_changeinfo |= (1 << userIndex);
//    
//    _header.head = ZXAHEADER;
//    _header.length = sizeof(sysParam);
//    _header.type = 0;
//    _header.commd = CMD_S_DEV_PARA;
//    _header.channel = 0;//self.deviceDetail.currentChannel;
//    
//    
//    // Add packet header
//    self.wifiParamData = [[[NSMutableData alloc]initWithBytes:&_header length:sizeof(_header)] autorelease];
//    [self.wifiParamData appendBytes:&sysParam length:sizeof(sysParam)];
//    
//    // connect to device
//    
//    commandSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_current_queue()];
//    
//    NSError *err = nil;
//    
//    DLog(@"ip : %@",self.deviceDetail.ip);
//    DLog(@"port : %d",self.deviceDetail.port);
//    
//    
//    if (![commandSocket connectToHost:self.bLoginWithLocalIp ? self.deviceDetail.ip : self.deviceDetail.InternetIp onPort:self.bLoginWithLocalIp ? self.deviceDetail.port : self.deviceDetail.UpnpVideoPort withTimeout:CONNECT_TIMEOUT_INTERVAL error:&err]) // Asynchronous!
//    {
//        // If there was an error, it's likely something like "already connected" or "no delegate set"
//    }
//    
//    // Send getDevParam info
//    [commandSocket writeData:self.wifiParamData withTimeout:-1 tag:1];
//    
//    // receive header packet
//    [commandSocket readDataToLength:16 withTimeout:READ_DATA_TIMEOUT_INTERVAL tag:TAG_SET_USER_PASSWORD_RESPONSE];
}

#pragma mark -GCDAsyncsocket Delegate
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    DLog(@"tag : %ld queue %s_________________________________%@ : %@ ,%ld",
         tag,dispatch_queue_get_label(dispatch_get_current_queue()),NSStringFromSelector(_cmd),self,tag);
}

- (void)socket:(GCDAsyncSocket *)sender didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"Aiert_ios各阶段运行状态<<======upnp或者zsp链接成功时间======》》");
    
    [AppData addCameraState:CameraStateConnected];

    [AppData setConnectionState:_bLocalConnection ? CameraNetworkStateLocalConnected : CameraNetworkStateUpnpConnected];
    
}
- (void)socket:(GCDAsyncSocket *)sender didReadData:(NSData *)data withTag:(long)tag
{
    switch (tag) {
        case TAG_FRAME_HEADER:
        {
            LOG(@"%d",data.length);
            // Get body Length
            int nBodyLength;
            [data getBytes:&nBodyLength range:NSMakeRange(4, 4)];
            LOG(@"%d",data.length);
            Byte magicBuffother[4];
            [data getBytes:magicBuffother range:NSMakeRange(4, 4)];
//            DLog(@"______________________________________________didReceive Video header echo: %d",nBodyLength);
            
            if (nBodyLength > 0) {
                [data getBytes:magicBuff range:NSMakeRange(0, 4)];
                
                if (0 == memcmp(magicBuff, "00dc", 4) || 0 == memcmp(magicBuff, "01dc", 4)) {
                    // Video frame
                    
                  //  [self.zspConnectionDelegate didReadRawData:data tag:RawDataTagHeader];

                    [sender readDataToLength:nBodyLength+24 withTimeout:TAG_READ_VIDEO_TIMOUT_INTERVAL tag:TAG_VIDEOFRAME_BODY];
                }
                else if (0 == memcmp(magicBuff, "01wb", 4)){
                    
                    DLog(@"Audio data length : %d",[data length]);
                    
                   // [self.zspConnectionDelegate didReadRawData:data tag:RawDataTagHeader];
                    
                    [sender readDataToLength:nBodyLength+8 withTimeout:TAG_READ_VIDEO_TIMOUT_INTERVAL tag:TAG_AUDIOFRAME_BODY];
                    
                }else{
                    [sender readDataToLength:nBodyLength+4 withTimeout:-1 tag:TAG_AUDIO_RESPONSE];
                }
            }
            
            break;
        }
        case TAG_VIDEOFRAME_BODY:
        {
            [self.zspConnectionDelegate didReadRawData:data tag:RawDataTagVideoBody];
            
            [self.zspConnectionDelegate didReadVideoData:data];
            
            [sender readDataToLength:8 withTimeout:TAG_READ_VIDEO_TIMOUT_INTERVAL tag:TAG_FRAME_HEADER];
            break;
        }
        case TAG_AUDIOFRAME_BODY:
        {
            [self.zspConnectionDelegate didReadRawData:data tag:RawDataTagAudioBody];
            
            int nLen = [data length]-8;
            
            NSData *audioData = [data subdataWithRange:NSMakeRange(8, nLen)];
            
            // Decode and play
            [audioData getBytes:recvAudioBuffer length:325];
            
            //将标准的g711数据转换成pcm数据
            int nPcmLen = G711ABuf2PCMBuf_HISI((unsigned char*)recvPcmAudioBuffer,
                                               641,
                                               (const unsigned char*)recvAudioBuffer,
                                               audioData.length,
                                               G711_BIG_ENDIAN);
            
            int packetNum = nPcmLen/320;
            
            for (int i=0; i!=packetNum; ++i) {
                [self.zspConnectionDelegate didReadAudioData:[NSData dataWithBytes:recvPcmAudioBuffer+i*320 length:320]];
            }
            
            [sender readDataToLength:8 withTimeout:TAG_READ_VIDEO_TIMOUT_INTERVAL tag:TAG_FRAME_HEADER];
            break;
        }
        case TAG_VIDEO_HEADER:
        {
            VIDEO_REQUEST value;
            [data getBytes:&value length:sizeof(value)];
            
            LOG(@"%d",value.request);
            
            if (0 == value.request) {
                [sender readDataToLength:8 withTimeout:TAG_READ_VIDEO_TIMOUT_INTERVAL tag:TAG_FRAME_HEADER];
            }
            break;
        }
        case TAG_LOGIN_RESPONSE:
        {
            // Get echmcmd
            VIDEO_REQUEST value;
            
            [data getBytes:&value length:sizeof(value)];
            switch (value.request) {
                case 0:
                    DLog(@"Login success !");
                    [self.zspConnectionDelegate didLoginSuccess];
                    break;
                case 1:
                case 2:
                    DLog(@"user not exists !");
//                    [self.tlvProtocalDelegate connectFailed:NSLocalizedString(@"Incorrect user Or password.",@"Incorrect user Or password.")];
                    break;
                default:
                    break;
            }
            break;
        }
        case TAG_AUDIO_RESPONSE:
        {
            
            DLog(@"Audio response : %d",[data length]);
            
            int nAudioFlag;
            [data getBytes:&nAudioFlag range:NSMakeRange(4, 4)];
            
            if (0 == nAudioFlag) {
                [self.zspConnectionDelegate didReadAudioResponse:LibCoreEventCodeAudioResponseSuccess];
            }else
            {
                [self.zspConnectionDelegate didReadAudioResponse:LibCoreEventCodeAudioResoponseFailed];
            }
            
            [sender readDataToLength:8 withTimeout:TAG_READ_VIDEO_TIMOUT_INTERVAL tag:TAG_FRAME_HEADER];
            break;
        }
        case TAG_TALK_ON_RESPONSE:
        {
            int nTalkFlag;
            [data getBytes:&nTalkFlag range:NSMakeRange(12, 4)];
            
            _audioPacketSize = 0;
            [data getBytes:&_audioPacketSize range:NSMakeRange(21, 2)];
            DLog(@"%d",_audioPacketSize);
            
            switch (nTalkFlag) {
                case 0:
                    DLog(@"_____________________________________________________________Talk On success !");
                    [self.zspConnectionDelegate didReadMicResponse:LibCoreEventCodeOpenMicSuccess];
                    break;
                case 1:
                    DLog(@"________________________________________________________________________Busy !");
                    [self.zspConnectionDelegate didReadMicResponse:LibCoreEventCodeMicResponseBusy];
                    break;
                case 2:
                    DLog(@"_________________________________________________________________Other error !");
                    [self.zspConnectionDelegate didReadMicResponse:LibCoreEventCodeMicResponseFailed];
                    break;
                default:
                    break;
            }
            break;
        }
        case TAG_READ_DEVLARGEPARAM_RESPONSE_HEADER:
        {
            // Get body Length
            int nBodyLength;
            [data getBytes:&nBodyLength range:NSMakeRange(4, 4)];
            //            DLog(@"TAG_READ_DEVLARGEPARAM_RESPONSE_HEADER : %d",nBodyLength);
            if (nBodyLength > 0) {
                [sender readDataToLength:nBodyLength withTimeout:READ_DATA_TIMEOUT_INTERVAL tag:TAG_READ_DEVLARGEPARAM_RESPONSE_BODY];
            }
            break;
        }
        case TAG_READ_DEVLARGEPARAM_RESPONSE_BODY:
        {
            //            DLog(@"data length : %d",[data length]);
            //           DLog(@"sysParam length : %ld",sizeof(sysParam));
//            [data getBytes:&sysParam length:sizeof(sysParam)];
//            
//            WifiNetworkInfo *wifiNetworkInfo = [[WifiNetworkInfo alloc] init];
//            
//            wifiNetworkInfo.bWifiOpened = sysParam.m_NetWork.m_WifiConfig.WifiAddrMode.m_u8Selected;
//            wifiNetworkInfo.bDHCPEnabled = sysParam.m_NetWork.m_WifiConfig.WifiAddrMode.m_dhcp;
//            
//            unsigned char *wifiIp = sysParam.m_NetWork.m_WifiConfig.WifiAddrMode.m_uLocalIp;
//            wifiNetworkInfo.wifiIp = [NSString stringWithFormat:@"%d.%d.%d.%d",wifiIp[0],wifiIp[1],wifiIp[2],wifiIp[3]];
//            
//            unsigned char *subMask = sysParam.m_NetWork.m_WifiConfig.WifiAddrMode.m_uMask;
//            wifiNetworkInfo.subMask = [NSString stringWithFormat:@"%d.%d.%d.%d",subMask[0],subMask[1],subMask[2],subMask[3]];
//            
//            unsigned char *gateWay = sysParam.m_NetWork.m_WifiConfig.WifiAddrMode.m_uGateWay;
//            wifiNetworkInfo.gateWay = [NSString stringWithFormat:@"%d.%d.%d.%d",gateWay[0],gateWay[1],gateWay[2],gateWay[3]];
//            
//            unsigned char *mac = sysParam.m_NetWork.m_WifiConfig.WifiAddrMode.m_uMac;
//            wifiNetworkInfo.mac = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]];
//            
//            unsigned char *dns1 = sysParam.m_NetWork.m_WifiConfig.WifiAddrMode.m_umDNSIp;
//            wifiNetworkInfo.dns1 = [NSString stringWithFormat:@"%d.%d.%d.%d",dns1[0],dns1[1],dns1[2],dns1[3]];
//            
//            unsigned char *dns2 = sysParam.m_NetWork.m_WifiConfig.WifiAddrMode.m_usDNSIp;
//            wifiNetworkInfo.dns2 = [NSString stringWithFormat:@"%d.%d.%d.%d",dns2[0],dns2[1],dns2[2],dns2[3]];
//            
//            DLog(@"%@",wifiNetworkInfo.wifiIp);
//            DLog(@"%@",wifiNetworkInfo.subMask);
//            DLog(@"%@",wifiNetworkInfo.gateWay);
//            DLog(@"%@",wifiNetworkInfo.mac);
//            DLog(@"%@",wifiNetworkInfo.dns1);
//            DLog(@"%@",wifiNetworkInfo.dns2);
//            
//            [self.tlvProtocalDelegate didReciveLargeParam:wifiNetworkInfo];
//            
//            [wifiNetworkInfo release];
            break;
        }
        case TAG_GET_WIFI_AP_LIST_HEADER:
        {
            // Get body Length
//            int nBodyLength;
//            [data getBytes:&nBodyLength range:NSMakeRange(4, 4)];
//            DLog(@"wifiList body length : %d",nBodyLength);
//            if (nBodyLength > 0) {
//                [sender readDataToLength:nBodyLength withTimeout:READ_DATA_TIMEOUT_INTERVAL tag:TAG_GET_WIFI_AP_LIST_BODY];
//            }else
//                if (0 == nBodyLength) {
//                    [self.tlvProtocalDelegate didReciveWifiApList:nil selectedIndex:0];
//                }
            break;
        }
        case TAG_GET_WIFI_AP_LIST_BODY:
        {
//            DLog(@"%d",[data length]);
//            TYPE_WIFI_LOGIN aWifiAp;
//            size_t lengthofAWifiAp = sizeof(aWifiAp);
//            NSInteger selectedIndex = -1;
//            NSInteger wifiApNumbers = [data length]/lengthofAWifiAp;
//            DLog(@"wifiNumbers : %d",wifiApNumbers);
//            NSMutableArray *wifiList = [[NSMutableArray alloc] init];
//            NSValue *aWifiApValue;
//            
//            for (int i=0; i!=wifiApNumbers; ++i) {
//                [data getBytes:&aWifiAp range:NSMakeRange(i*lengthofAWifiAp, lengthofAWifiAp)];
//                DLog(@" wifi : ______%s",aWifiAp.RouteDeviceName);
//                
//                if (1 == aWifiAp.ConnectStatus) {
//                    selectedIndex = i;
//                    DLog(@"selected wifi : _____________________%s",aWifiAp.RouteDeviceName);
//                }
//                aWifiApValue = [NSValue valueWithBytes:&aWifiAp objCType:@encode(TYPE_WIFI_LOGIN)];
//                [wifiList addObject:aWifiApValue];
//            }
//            [self.tlvProtocalDelegate didReciveWifiApList:wifiList selectedIndex:selectedIndex];
//            [wifiList release];
            
            break;
        }
        case TAG_SET_WIFI_AP_RESPONSE:
        {
            // Get Status
//            int nEchmcmd;
//            [data getBytes:&nEchmcmd range:NSMakeRange(12, 4)];
//            if (0 == nEchmcmd) {
//                DLog(@"select wifi successful !");
//                [self.tlvProtocalDelegate didSetWifiApSuccessful];
//            }
            break;
        }
        case TAG_SET_WIFI_STATUS_RESPONSE:
        {
            // Get Status
//            int nEchmcmd;
//            [data getBytes:&nEchmcmd range:NSMakeRange(12, 4)];
//            if (0 == nEchmcmd) {
//                DLog(@"set wifi status successful !");
//                [self.tlvProtocalDelegate didSetWifiStatusSuccessful];
//            }
            break;
        }
        case TAG_SET_WIFI_PARAM_RESPONSE:
        {
            // Get Status
//            int nEchmcmd;
//            [data getBytes:&nEchmcmd range:NSMakeRange(12, 4)];
//            if (0 == nEchmcmd) {
//                DLog(@"set wifi param successful !");
//                [self.tlvProtocalDelegate didSetWifiInfoSuccessful];
//            }
            break;
        }
        case TAG_SET_USER_PASSWORD_RESPONSE:
        {
            // Get Status
//            int nEchmcmd;
//            [data getBytes:&nEchmcmd range:NSMakeRange(12, 4)];
//            if (0 == nEchmcmd) {
//                DLog(@"set user password successful !");
//                [self.tlvProtocalDelegate didSetUserPasswordSuccessful];
//            }
            break;
        }
        case TAG_R_DEVICEINFO:
        {
            // Get AudioSupport
//            char supportAudio;
//            [data getBytes:&supportAudio range:NSMakeRange(148, 1)];
//            
//            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithChar:supportAudio],kSupportAudioTalk, nil];
//            
//            DLog(@"Get Audio support successful !");
//            [self.tlvProtocalDelegate didReceiveDeviceInfo:dict];
            break;
        }
    }
}
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    DLog(@"%@ , code : %d",NSStringFromSelector(_cmd),[err code]);
    
    if (GCDAsyncSocketConnectTimeoutError == [err code]) {
        [AppData setConnectionState:_bLocalConnection ? CameraNetworkStateLocalConnectFailed : CameraNetworkStateUpnpConnectFailed];
        
    }else if (GCDAsyncSocketReadTimeoutError == [err code] || GCDAsyncSocketClosedError == [err code])
    {
        [AppData setConnectionState:_bLocalConnection ? CameraNetworkStateLocalRecvFailed : CameraNetworkStateUpnpRecvFailed];
    }
    
    [self.zspConnectionDelegate didDisconnect];
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length
{
    DLog(@"video time out : sum of timeInterval : %f!",elapsed);
    
    [AppData setConnectionState:_bLocalConnection ? CameraNetworkStateLocalRecvFailed : CameraNetworkStateUpnpRecvFailed];
    
    [self.zspConnectionDelegate didReadDataTimeOut];
    
    return -1;
}

@end
