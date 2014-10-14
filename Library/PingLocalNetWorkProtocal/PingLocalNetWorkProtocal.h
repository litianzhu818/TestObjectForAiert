//
//  PingLocalNetWorkProtocal.h
//  Aiert
//
//  Created by Peter Lee on 14/9/13.
//  Copyright (c) 2013年 爱尔特电子有限公司. All rights reserved.
//
#ifndef DEVICE_INFO_KEY
#define kDeviceID                  @"DeviceID"
#define kDeviceLocalIp             @"DeviceLocalIp"
#define kDeviceLocalPort           @"DeviceLocalPort"
#define kDeviceMac                 @"DeviceMac"
#define kDeviceGateway             @"DeviceGateway"
#define kDeviceSubMask             @"DeviceSubMask"
#define kDeviceType                @"DeviceType"
#define kChannelCount              @"ChannelCount"
#define kSupportWifi               @"SupportWifi"
#define kSupportAudioTalk          @"SupportAudioTalk"
#endif

@class LocalNetworkInfo;
@protocol PingLocalNetWorkProtocalDelegate;
@interface PingLocalNetWorkProtocal : NSObject
@property(weak, nonatomic) id <PingLocalNetWorkProtocalDelegate> pingLocalNetWorkProtocalDelegate;
@property(strong, nonatomic) NSString *deviceId;
- (void)releaseUdpSocket;
- (void)pingLocalDevicesWithBindPort:(NSInteger)port;
- (id)initWithDeviceId:(NSString *)aDeviceId;
- (void)setLocalNetworkInfoToDevice:(LocalNetworkInfo *)localNetworkInfo;
@end
@protocol PingLocalNetWorkProtocalDelegate <NSObject>
// udpsocket delegate
@optional;
- (void)didScanOneDevice:(NSString *)deviceId;
@required;
- (void)didFindTheDevice:(NSDictionary *)devInfoDict;
@end