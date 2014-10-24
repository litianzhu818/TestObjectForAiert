//
//  P2PConnection.m
//  爱尔特 Aiert
//
//  Created by Peter Lee on 14/9/13.
//  Copyright (c) 2014年 爱尔特. All rights reserved.
//

#import "P2PConnection.h"
#include "P2PClient_IOS.h"
#import "BasicDefine.h"
#import "AppData.h"

extern "C"{
#include "G711Convert_HISI.h"
}

@interface P2PConnection ()
{
    CP2PClientWarp *_p2pClient;
    Byte recvPcmAudioBuffer[641];

}

@property (copy, nonatomic) NSString *currentDeviceId;
@property (nonatomic) NSInteger currentChannel;
@property (nonatomic) NSInteger currentMediaType;
@end

@implementation P2PConnection

static void OnStatusReport(int iType, int iStatus, const char* pText, void * pCookie)
{
    DLog(@"iType%i,iStatus%i,pText%s", iType, iStatus, pText);
  
	switch (iType)
	{
        case stStream:
		{
			switch (iStatus)
			{
                case ssP2PConnectSucc:
                    NSLog(@"Aiert_ios各阶段运行状态<<======P2P连接成功======》》");
                    [[(__bridge P2PConnection *)pCookie p2pDelegate] didRecvStreamStatus:CameraNetworkStateP2pConnected];
                    break;
                case ssP2PConnectFailed:
                    NSLog(@"Aiert_ios各阶段运行状态<<======P2P连接失败======》》");
                    [[(__bridge P2PConnection *)pCookie p2pDelegate] didRecvStreamStatus:CameraNetworkStateP2pConnectFailed];
                    break;
                case ssP2PDisconnect:
                    NSLog(@"Aiert_ios各阶段运行状态<<======P2P断开连接======》》");
                    break;
                case ssP2PRecvFailed:
                {
                    NSLog(@"Aiert_ios各阶段运行状态<<======P2P接收错误======》》");
                    [[(__bridge P2PConnection *)pCookie p2pDelegate] didRecvStreamStatus:CameraNetworkStateP2pRecvFailed];
                }
                    break;
                case ssDeliverConnectSucc:
                    NSLog(@"Aiert_ios各阶段运行状态<<======中转连接成功======》》");
                    [[(__bridge P2PConnection *)pCookie p2pDelegate] didRecvStreamStatus:CameraNetworkStateTransmitConnected];
                    break;
                case ssDeliverConnectFailed:
                    NSLog(@"Aiert_ios各阶段运行状态<<======中转连接失败======》》");
                    [[(__bridge P2PConnection *)pCookie p2pDelegate] didRecvStreamStatus:CameraNetworkStateTransmitConnectFailed];
                    break;
                case ssDeliverDisconnect:
                    break;
                    
                case ssDeliverRecvFailed:
                    NSLog(@"Aiert_ios各阶段运行状态<<======中转接收错误======》》");
                    [[(__bridge P2PConnection *)pCookie p2pDelegate] didRecvStreamStatus:CameraNetworkStateTransmitRecvFailed];
                    break;
                case ssPlayBackReqSucc:
                    printf("回放请求成功\n");
                    break;
                case ssPlayBackReqFailed:
                    printf("回放请求失败\n");
                    break;
                case ssPlayBackStop:
                    printf("当前回放结束\n");
                    break;
                case ssChangeToQVGA:
                    printf("需要切换码流为QVGA\n");
                    break;
                case ssChangeToVGA:
                    printf("需要切换码流为VGA\n");
                    break;
                case ssOpenSoundSucc:
                    DLog(@"Aiert_ios各阶段运行状态<<======打开音频成功======》》");
                    [[(__bridge P2PConnection *)pCookie p2pDelegate] didRecvStreamStatus:LibCoreEventCodeAudioResponseSuccess];

                    break;
                case ssOpenSoundFailed :
                    DLog(@"Aiert_ios各阶段运行状态<<======打开音频失败======》》");
                    [[(__bridge P2PConnection *)pCookie p2pDelegate] didRecvStreamStatus:LibCoreEventCodeAudioResoponseFailed];

                    break;
                case ssCloseSoundSucc:
                    DLog(@"Aiert_ios各阶段运行状态<<======关闭音频成功======》》");
                    [[(__bridge P2PConnection *)pCookie p2pDelegate] didRecvStreamStatus:LibCoreEventCodeAudioResponseSuccess];

                    break;
                case ssCloseSoundFailed:
                    DLog(@"Aiert_ios各阶段运行状态<<======关闭音频失败======》》");
                    [[(__bridge P2PConnection *)pCookie p2pDelegate] didRecvStreamStatus:LibCoreEventCodeAudioResoponseFailed];

                    break;
                    
                case ssOpenTalkSucc:
                    DLog(@"Aiert_ios各阶段运行状态<<======打开对讲成功======》》");
                    [[(__bridge P2PConnection *)pCookie p2pDelegate] didRecvStreamStatus:LibCoreEventCodeOpenMicSuccess];
                    break;
                case ssOpenTalkFailed:
                    DLog(@"Aiert_ios各阶段运行状态<<======打开对讲失败======》》");
                    [[(__bridge P2PConnection *)pCookie p2pDelegate] didRecvStreamStatus:LibCoreEventCodeMicResponseFailed];
                    break;
                case ssCloseTalkSucc:
                    DLog(@"Aiert_ios各阶段运行状态<<======关闭对讲成功======》》");
                    break;
                case ssCloseTalkFailed:
                    DLog(@"Aiert_ios各阶段运行状态<<======关闭对讲失败======》》");
                    break;
                    
                case ssChangeStreamSucc:
                    DLog(@"Aiert_ios各阶段运行状态<<======关闭或者打开通道成功======》》");
                    break;
                case ssChangeStreamFailed:
                    DLog(@"Aiert_ios各阶段运行状态<<======关闭或者打开通道失败======》》");
                    break;
                    
                case ssUnknownError:
                default:
                    printf("未知错误\n");
                    break;
			}
		}
            break;
        case stNatType :
		{
			printf("调试信息，告知上层打洞类型\n");
		}
            break;
        case stUpnp:
		{
			switch (iStatus)
			{
                case upnpLoginSuper_0:
				{
                    NSLog(@"Aiert_ios各阶段运行状态<<======设备登陆成功======》》");
                    
				}
                    break;
                case upnpLoginNormal_0:
				{
                    NSLog(@"Aiert_ios各阶段运行状态<<======设备登陆成功======》》");
				}
                    break;
                case upnpLoginfalied:
				{
                    NSLog(@"Aiert_ios各阶段运行状态<<======设备登陆失败======》》");
				}
                    break;
                    
                case upnpChangePwdSucc:
				{
                    NSLog(@"Aiert_ios各阶段运行状态<<======修改密码成功======》》");
				}
                    break;
                case upnpChangePwdFailed:
				{
                    NSLog(@"Aiert_ios各阶段运行状态<<======修改密码失败======》》");
				}
                    break;
                case upnpQueryUpnpSucc:
				{
                    NSLog(@"Aiert_ios各阶段运行状态<<======查询设备UPNP信息成功======》》");
                    
                    if (nil == pText) {
                        [[(__bridge P2PConnection *)pCookie p2pDelegate] didGetUPNPSupportInfoWithTag:UpnpQueryFailure
                                                                                                param:nil];
                        return;
                    }
                    NSData *response = [NSData dataWithBytes:pText length:strlen(pText)];
                    
                    // IOS5自带解析类NSJSONSerialization从response中解析出数据放到字典中
                    NSError *error;
                    NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:response
                                                                            options:NSJSONReadingMutableLeaves
                                                                              error:&error];
                    DLog(@"设备信息%@",jsonDic);
                    
                    if (0 == [[jsonDic objectForKey:@"ReplyCode"] intValue]) {
                        NSDictionary *dicQuerRes = [jsonDic objectForKey:@"QueryRes"];
                        
                        if (0 == [[dicQuerRes objectForKey:@"UpnpVideoPort"] intValue]) {       // p2p
                            [[(__bridge P2PConnection *)pCookie p2pDelegate] didGetUPNPSupportInfoWithTag:UpnpQueryResultNotSupport
                                                                                                    param:jsonDic];

                        }else
                        {
                            [[(__bridge P2PConnection *)pCookie p2pDelegate] didGetUPNPSupportInfoWithTag:UpnpQueryResultSupport
                                                                                                    param:jsonDic];
                        }
                    }else
                    {
//                        [[(__bridge P2PConnection *)pCookie p2pDelegate] didGetUPNPSupportInfoWithTag:UpnpQueryFailure param:nil];
                        
                        [[(__bridge P2PConnection *)pCookie p2pDelegate] didGetUPNPSupportInfoWithTag:UpnpQueryResultNotSupport
                                                                                                param:jsonDic];
                    }
                    

				}
                    break;
                case upnpQueryUpnpFailed:
				{
                    NSLog(@"Aiert_ios各阶段运行状态<<======查询设备UPNP信息失败======》》");
                    
                    [[(__bridge P2PConnection *)pCookie p2pDelegate] didGetUPNPSupportInfoWithTag:UpnpQueryFailure
                                                                                            param:nil];
				}
                    break;
			}
		}
            break;
	}
}

static void OnFrameData(int iType, char* pData, int iSize, void * pCookie)
{
    
//    DLog(@"Aiert_ios各阶段运行状态<<======p2p数据======》》");

    if (0 == memcmp(pData, "00dc", 4) || 0 == memcmp(pData, "01dc", 4)) {
        
//        DLog(@"Aiert_ios各阶段运行状态<<======视频数据======》》");
        
        
        [[(__bridge P2PConnection *)pCookie p2pDelegate] didRecvRawData:pData
                                                                   size:32
                                                                    tag:RawDataTagHeader];
        
        [[(__bridge P2PConnection *)pCookie p2pDelegate] didRecvRawData:pData+32
                                                                   size:iSize-32
                                                                    tag:RawDataTagVideoBody];
        
        [[(__bridge P2PConnection *)pCookie p2pDelegate] didRecvVideoFrameData:iType
                                                                    streamData:pData+32
                                                                          size:iSize-32];
    }
    else if(0 == memcmp(pData, "01wb", 4)){
        
        DLog(@"Aiert_ios各阶段运行状态<<======音频数据======》》%d",iSize);

        if (iSize > 641) {
            return;
        }
        
        [[(__bridge P2PConnection *)pCookie p2pDelegate] didRecvRawData:pData
                                                                   size:16
                                                                    tag:RawDataTagHeader];
        
        [[(__bridge P2PConnection *)pCookie p2pDelegate] didRecvRawData:pData+16
                                                                   size:iSize-16
                                                                    tag:RawDataTagAudioBody];
        
        int nPcmLen = G711ABuf2PCMBuf_HISI((unsigned char*)((__bridge P2PConnection *)pCookie)->recvPcmAudioBuffer,
                                           641,
                                           (const unsigned char*)pData+16,
                                           iSize-16,
                                           G711_BIG_ENDIAN);
        int packetNum = nPcmLen/320;
        for (int i=0; i!=packetNum; ++i) {
            [[(__bridge P2PConnection *)pCookie p2pDelegate] didRecvAudioFrameData:(char *)((__bridge P2PConnection *)pCookie)->recvPcmAudioBuffer+i*320
                                                                              size:320];

        }
        
    }
}

- (void)dealloc
{
    delete _p2pClient;
    
}

- (id)initWithDelegate:(id<P2pConnectionDelegate>)delegate;
{
    if (self = [super init]) {
        
        _p2pClient = new CP2PClientWarp;
        _p2pClient->Init(OnStatusReport, OnFrameData);
        self.p2pDelegate = delegate;
        
    }
    return self;
}


- (BOOL)isUPNPSupport:(NSString *)strDevice
{
    NSLog(@"Aiert_ios各阶段运行状态<<======开始查询UPNP设备信息=====》》");
    
    [AppData setConnectionState:CameraNetworkStateUpnpQuerying];
    
    bool bupnpInfo = _p2pClient->IsUPNPSupport(strDevice.UTF8String,(__bridge void *)self);
    
    if (!bupnpInfo) {
        [self.p2pDelegate didGetUPNPSupportInfoWithTag:UpnpQueryFailure param:nil];
    }

    DLog(@"IsUPNPSupport接口是否调用成功 : __________________________________%@",bupnpInfo ? @"YES" : @"NO");
    return YES;
}

- (BOOL)login:(NSString *)strUserName password:(NSString *)strPassword
{
    NSLog(@"Aiert_ios各阶段运行状态<<======p2p或者中转开始验证登陆设备信息strUserName-%@ strPassword-%@=====》》",strUserName, strPassword);
    
    BOOL bLogin = _p2pClient->LoginUPNP(strUserName.UTF8String, strPassword.UTF8String);
    DLog(@"LoginUPNP接口是否调用成功 : __________________________________%@",bLogin ? @"YES" : @"NO");
    return YES;
    
}
- (BOOL)changePwd:(NSString *)strUserName password:(NSString *)strPassword
{
    NSLog(@"Aiert_ios各阶段运行状态<<======p2p或者中转开始修改设备密码strUserName-%@ strPassword-%@=====》》",strUserName, strPassword);
    BOOL bChangePwd = _p2pClient->ChangePwdUPNP(strUserName.UTF8String, strPassword.UTF8String);
    DLog(@"ChangePwdUPNP接口是否调用成功 : __________________________________%@",bChangePwd ? @"YES" : @"NO");
    
    return YES;
    
}

- (BOOL)requestStream:(NSString *)strDeviceID
              channel:(NSInteger)iChannel
           streamType:(NSInteger)stream_type
                isP2p:(BOOL)bP2p
{
    
    self.currentDeviceId = strDeviceID;
    self.currentChannel = iChannel;
    self.currentMediaType = stream_type;
    
    NSLog(@"Aiert_ios各阶段运行状态<<======请求%@链接%d通道，%d码流播放======》》",bP2p? @"P2P" : @"中转",iChannel, stream_type);
    
        bool bRealPlay = _p2pClient->RealPlay(strDeviceID.UTF8String, iChannel, stream_type, bP2p, (__bridge void *)self);
        DLog(@"RealPlay接口是否调用成功 : __________________________________%@",bRealPlay ? @"YES" : @"NO");
        
    return YES;
}

- (BOOL)changeStream:(NSInteger)iChannel
           mediaType:(NSInteger)iNewMediaType
           operation:(NSInteger)operation
{
    NSLog(@"Aiert_ios各阶段运行状态<<======请求切换%d通道，%d码流======》》",iChannel, iNewMediaType);
    
    bool bChangeStream = _p2pClient->ChangeStream(iChannel, iNewMediaType, 0);
    DLog(@"ChangeStream接口是否调用成功==关闭通道 : __________________________________%@",bChangeStream ? @"YES" : @"NO");
    
    return YES;
}
- (void)stopRealPlay
{
    
    NSLog(@"Aiert_ios各阶段运行状态<<======StopRealPlay=====》》");
    
    _p2pClient->StopRealPlay();
        
}

- (BOOL)enableSound:(BOOL)bOpen
{
    DLog(@"Aiert_ios各阶段运行状态<<======请求%@声音======》》",bOpen? @"打开" : @"关闭");
        bool bEnableSound = _p2pClient->EnableSound(bOpen);
        DLog(@"EnableSound接口是否调用成功 : __________________________________%@",bEnableSound ? @"YES" : @"NO");
    return YES;
}
- (BOOL)enableTalk:(BOOL)bTalk
{
    DLog(@"Aiert_ios各阶段运行状态<<======请求%@对讲======》》",bTalk? @"打开" : @"关闭");
        bool bEnableTalk = _p2pClient->EnableTalk(bTalk);
        DLog(@"EnableTalk接口是否调用成功 : __________________________________%@",bEnableTalk ? @"YES" : @"NO");
    return YES;
    
}

- (void)sendTalkData:(BytePtr)pData length:(int)iSize
{
    _p2pClient->SendTalkData((char *)pData, iSize);
    
}
@end
