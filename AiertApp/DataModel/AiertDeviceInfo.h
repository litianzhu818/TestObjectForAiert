//
//  AiertDeviceInfo.h
//  AiertApp
//
//  Created by Peter Lee on 14/9/13.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AiertUserInfo.h"
#import "AiertDeviceCoreDataStorageObject.h"

typedef NS_ENUM(NSInteger, DeviceStatus) {
    DeviceStatusOnline = 0,
    DeviceStatusOffline,
    DeviceStatusConnectTimeout
};

@interface AiertDeviceInfo : NSObject<NSCopying,NSCoding>

@property (strong, nonatomic) NSString *deviceName;
@property (strong, nonatomic) NSString *deviceID;
@property (strong, nonatomic) AiertUserInfo *userInfo;
@property (assign, nonatomic) DeviceStatus deviceStatus;
@property (assign, nonatomic) BOOL isONLine;

//Add Parameters

@property (assign, nonatomic) NSInteger deviceType;//设备类型
@property (strong, nonatomic) NSString *serialNumber;//设备Mac地址32位
@property (strong, nonatomic) NSString *hardWareVersion;//硬件版本
@property (strong, nonatomic) NSString *softWareVersion;//软件版本
@property (assign, nonatomic) NSUInteger videoNum;//视频通道数
@property (assign, nonatomic) NSUInteger audioNum;//音频通道数
@property (assign, nonatomic) NSUInteger alarmInNum;//报警输入
@property (assign, nonatomic) NSUInteger alarmOutNum;//报警输出
@property (assign, nonatomic) NSUInteger supportAudioTalk;//是否支持对讲，1为支持，0为不支持
@property (assign, nonatomic) NSUInteger supportStore;//是否支持本地储存，1为支持，0为不支持
@property (assign, nonatomic) NSUInteger supportWiFi;//是否支持WiFi，1为支持，0为不支持
@property (assign, nonatomic) NSUInteger resver;//是否支持onvif


- (instancetype)initWithDeviceName:(NSString *)device_name deviceID:(NSString *)device_id userInfo:(AiertUserInfo *)userInfo;
- (instancetype)initWithDeviceName:(NSString *)device_name deviceID:(NSString *)device_id deviceStatus:(DeviceStatus)deviceStatus userInfo:(AiertUserInfo *)userInfo;
- (instancetype)initWithDeviceName:(NSString *)device_name deviceID:(NSString *)device_id userName:(NSString *)user_name userPassword:(NSString *)user_password;
- (instancetype)initWithDeviceName:(NSString *)device_name deviceID:(NSString *)device_id userName:(NSString *)user_name userPassword:(NSString *)user_password deviceStatus:(DeviceStatus)deviceStatus;
- (instancetype)initWithDeviceCoraDataObject:(AiertDeviceCoreDataStorageObject *)object;

@end
