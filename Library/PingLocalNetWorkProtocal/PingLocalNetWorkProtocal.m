//
//  PingLocalNetWorkProtocal.m
//  Aiert
//
//  Created by 钱长存 on 13-3-22.
//  Copyright (c) 2013年 爱尔特电子有限公司. All rights reserved.
//

#import "PingLocalNetWorkProtocal.h"
#import "GCDAsyncUdpSocket.h"
#import "systemparameterdefine.h"
#import "Utilities.h"
#import "LocalNetworkInfo.h"
#import "BasicDefine.h"
#import "DeviceAddition.h"

@interface PingLocalNetWorkProtocal ()
{
    GCDAsyncUdpSocket *udpPingSocket;
    ZXA_HEADER header;
}
@property(nonatomic, strong)NSData *pingData;
@property(nonatomic, strong)NSMutableData *setLocalNetworkData;
@end
@implementation PingLocalNetWorkProtocal
@synthesize pingLocalNetWorkProtocalDelegate;


- (void)dealloc
{
    [self releaseUdpSocket];
}

- (void)releaseUdpSocket
{
    if (udpPingSocket) {
        [udpPingSocket close];
        [udpPingSocket setDelegate:nil];
        udpPingSocket = nil;
    }
}
- (id)initWithDeviceId:(NSString *)aDeviceId;
{
    if (self = [super init]) {
        //        stopSem = dispatch_semaphore_create(0);
        self.deviceId = aDeviceId;
    }
    return self;
}
- (void)composePingPacket
{
    header.head = 0xaaaa5555;//ZXAGEADER=0xaaaa5555
    header.length = 0;
    header.type = 0;
    header.commd = CMD_ID_PING;
    header.channel = 0;//self.deviceDetail.currentChannel;
    
    
    // Add packet header
    self.pingData = [[NSData alloc]initWithBytes:&header length:sizeof(header)];
}
- (void)setLocalNetworkInfoToDevice:(LocalNetworkInfo *)localNetworkInfo
{
    DLog(@"ip : %@",localNetworkInfo.localIp);
    DLog(@"mac: %@",localNetworkInfo.mac);
    DLog(@"gateway : %@",localNetworkInfo.gateWay);
    DLog(@"submask : %@",localNetworkInfo.subMask);
    
    ipaddr_tmp ipaddrTmp;
    size_t ipaddrSize = sizeof(ipaddrTmp);
    memset(&ipaddrTmp, 0, ipaddrSize);
    
    header.head = ZXAHEADER;
    header.length = ipaddrSize;
    header.type = 1;
    header.commd = CMD_PING;
    header.channel = 0;//self.deviceDetail.currentChannel;
    
    memcpy(&ipaddrTmp.ipaddr, [localNetworkInfo.localIp UTF8String], localNetworkInfo.localIp.length);
    memcpy(&ipaddrTmp.geteway, [localNetworkInfo.gateWay UTF8String], localNetworkInfo.gateWay.length);
    memcpy(&ipaddrTmp.submask, [localNetworkInfo.subMask UTF8String], localNetworkInfo.subMask.length);
    memcpy(&ipaddrTmp.mac, [localNetworkInfo.mac UTF8String], localNetworkInfo.mac.length);
    
    DLog(@"%s",ipaddrTmp.ipaddr);
    DLog(@"%s",ipaddrTmp.geteway);
    DLog(@"%s",ipaddrTmp.submask);
    DLog(@"%s",ipaddrTmp.mac);
    
    self.setLocalNetworkData = [[NSMutableData alloc] initWithBytes:&header length:sizeof(header)];
    [self.setLocalNetworkData appendBytes:&ipaddrTmp length:ipaddrSize];
    
    DLog(@"data length : %d",[self.setLocalNetworkData length]);
    if (nil != udpPingSocket) {
        [udpPingSocket sendData:self.setLocalNetworkData toHost:@"255.255.255.255" port:8080 withTimeout:-1 tag:0];
    }
}
- (void)pingLocalDevicesWithBindPort:(NSInteger)port
{
    void(^configUdpBlock)(void) = ^(void){
        NSError *err = nil;
        
        if (![udpPingSocket bindToPort:port error:&err])
        {
            DLog(@"Error binding: %@", [err description]);
            return;
        }
        if (![udpPingSocket beginReceiving:&err])
        {
            DLog(@"Error receiving: %@", [err description]);
            return;
        }
        [udpPingSocket enableBroadcast:YES error:&err];
        if (err != nil)
        {
            DLog(@"Error enableing broadcast: %@", [err description]);
            return;
        }
    };
    if (nil == udpPingSocket) {
        udpPingSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        configUdpBlock();
    }
    
    if ([udpPingSocket isClosed]) {
        configUdpBlock();
    }
    
    [self composePingPacket];
    
    [udpPingSocket sendData:self.pingData toHost:@"255.255.255.255" port:8080 withTimeout:-1 tag:0];
}

-(NSString *)getUUIDString
{
    CFUUIDRef uuidRef =CFUUIDCreate(NULL);
    
    CFStringRef uuidStringRef =CFUUIDCreateString(NULL, uuidRef);
    
    CFRelease(uuidRef);
    
    return (__bridge NSString *)uuidStringRef;
}

#pragma mark -GCDAsyncUdpsocket Delegate
/**
 * Called when the datagram with the given tag has been sent.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    DLog(@"queue %s : %@ : %@ ",dispatch_queue_get_label(dispatch_get_main_queue()),NSStringFromSelector(_cmd),self);
}

/**
 * Called if an error occurs while trying to send a datagram.
 * This could be due to a timeout, or something more serious such as the data being too large to fit in a sigle packet.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    DLog(@"queue %s : %@ : %@ ",dispatch_queue_get_label(dispatch_get_main_queue()),NSStringFromSelector(_cmd),self);
}

/**
 * Called when the socket has received the requested datagram.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
    if (272 != [data length]) {
        return;
    }
    
    PING_DEVICE_INFO deviceInfo;
    [data getBytes:&deviceInfo length:sizeof(deviceInfo)];
//    LOG(@"位数:%ld",sizeof(deviceInfo));
    NSString *deviceID = [NSString stringWithUTF8String:deviceInfo.deviceID];

    if (!deviceID) {
#ifndef TEST
        return;
#else
        deviceID = [self getUUIDString];
#endif
    }
    
    AiertDeviceInfo *device = [[AiertDeviceInfo alloc] initWithDeviceName:[NSString stringWithUTF8String:deviceInfo.typeDeviceInfo.DeviceName] deviceID:deviceID userInfo:nil];
    
    DeviceAddition *deviceAddition = [[DeviceAddition alloc] initWithPingStructObject:deviceInfo];
    [device setDeviceAdditionInfo:deviceAddition];
    
    if (self.pingLocalNetWorkProtocalDelegate && [self.pingLocalNetWorkProtocalDelegate respondsToSelector:@selector(didFindTheDeviceWithInfo:)]) {
        [self.pingLocalNetWorkProtocalDelegate didFindTheDeviceWithInfo:device];
    }
    
#warning The old code here
//    char devId[16];
//    [data getBytes:devId range:NSMakeRange(sizeof(header)+sizeof(ipaddr_tmp)+sizeof(TYPE_DEVICE_INFO)+sizeof(devTypeInfo), 16)];
//    
//    NSString *aDeviceId = [NSString stringWithUTF8String:devId];
//    
//    if (![Utilities checkRegFormat:aDeviceId patternString:kRegDeviceIdFormat]) {
//        return;
//    }
//    
//    if (nil == self.deviceId) {
//        
//        UInt16 localPort;
//        [data getBytes:&localPort range:NSMakeRange(154, 2)];
//        
//        //        char devName[32];
//        //        [data getBytes:devName range:NSMakeRange(16, 32)];
//        //        DLog(@"device Name : %@",[NSString stringWithUTF8String:devName]);
//        
//        char gateway[20];
//        [data getBytes:gateway range:NSMakeRange(180, 20)];
//        NSString *aGateway = [NSString stringWithUTF8String:gateway];
//        
//        char subMask[20];
//        [data getBytes:subMask range:NSMakeRange(200, 20)];
//        NSString *aSubMask = [NSString stringWithUTF8String:subMask];
//        
//        char mac[20];
//        [data getBytes:mac range:NSMakeRange(220, 20)];
//        NSString *aMac = [NSString stringWithUTF8String:mac];
//        
//        char devType;
//        [data getBytes:&devType range:NSMakeRange(14, 1)];
//        DLog(@"%d",devType);
//        
//        char channelCount;
//        [data getBytes:&channelCount range:NSMakeRange(144, 1)];
//        DLog(@"%d",channelCount);
//        
//        char supportWifi;
//        [data getBytes:&supportWifi range:NSMakeRange(150, 1)];
//        DLog(@"%d",supportWifi);
//        
//        char supportAudioTalk;
//        [data getBytes:&supportAudioTalk range:NSMakeRange(148, 1)];
//        DLog(@"%d",supportAudioTalk);
//        
//        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:aDeviceId,kDeviceID,[NSNumber numberWithInt:localPort],kDeviceLocalPort,[GCDAsyncUdpSocket hostFromAddress:address],kDeviceLocalIp,aGateway,kDeviceGateway,aSubMask,kDeviceSubMask,aMac,kDeviceMac,[NSNumber numberWithChar:devType],kDeviceType,[NSNumber numberWithChar:channelCount],kChannelCount,[NSNumber numberWithChar:supportWifi],kSupportWifi, [NSNumber numberWithChar:supportAudioTalk],kSupportAudioTalk,nil];
//        
//        DLog(@"dict : %@",dict);
//        
//        [self.pingLocalNetWorkProtocalDelegate didFindTheDevice:dict];
//    }else
//    {
//        if ([aDeviceId isEqualToString:self.deviceId]) {
//            
//            UInt16 localPort;
//            [data getBytes:&localPort range:NSMakeRange(154, 2)];
//            
//            char gateway[20];
//            [data getBytes:gateway range:NSMakeRange(180, 20)];
//            NSString *aGateway = [NSString stringWithUTF8String:gateway];
//            
//            char subMask[20];
//            [data getBytes:subMask range:NSMakeRange(200, 20)];
//            NSString *aSubMask = [NSString stringWithUTF8String:subMask];
//            
//            char mac[20];
//            [data getBytes:mac range:NSMakeRange(220, 20)];
//            NSString *aMac = [NSString stringWithUTF8String:mac];
//            
//            char devType;
//            [data getBytes:&devType range:NSMakeRange(14, 1)];
//            DLog(@"%d",devType);
//            
//            char channelCount;
//            [data getBytes:&channelCount range:NSMakeRange(144, 1)];
//            DLog(@"%d",channelCount);
//            
//            char supportWifi;
//            [data getBytes:&supportWifi range:NSMakeRange(150, 1)];
//            DLog(@"%d",supportWifi);
//            
//            char supportAudioTalk;
//            [data getBytes:&supportAudioTalk range:NSMakeRange(148, 1)];
//            DLog(@"%d",supportAudioTalk);
//            
//            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:aDeviceId,kDeviceID,[NSNumber numberWithInt:localPort],kDeviceLocalPort,[GCDAsyncUdpSocket hostFromAddress:address],kDeviceLocalIp,aGateway,kDeviceGateway,aSubMask,kDeviceSubMask,aMac,kDeviceMac,[NSNumber numberWithChar:devType],kDeviceType,[NSNumber numberWithChar:channelCount],kChannelCount,[NSNumber numberWithChar:supportWifi],kSupportWifi,[NSNumber numberWithChar:supportAudioTalk],kSupportAudioTalk, nil];
//            
//            DLog(@"dict : %@",dict);
//            
//            [self.pingLocalNetWorkProtocalDelegate didFindTheDevice:dict];
//        }
//    }
}

/**
 * Called when the socket is closed.
 **/
- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error
{
    DLog(@"queue %s : %@ : %@ ",dispatch_queue_get_label(dispatch_get_main_queue()),NSStringFromSelector(_cmd),self);
}

@end
