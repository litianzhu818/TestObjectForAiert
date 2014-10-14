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

- (instancetype)initWithDeviceName:(NSString *)device_name deviceID:(NSString *)device_id userInfo:(AiertUserInfo *)userInfo;
- (instancetype)initWithDeviceName:(NSString *)device_name deviceID:(NSString *)device_id deviceStatus:(DeviceStatus)deviceStatus userInfo:(AiertUserInfo *)userInfo;
- (instancetype)initWithDeviceName:(NSString *)device_name deviceID:(NSString *)device_id userName:(NSString *)user_name userPassword:(NSString *)user_password;
- (instancetype)initWithDeviceName:(NSString *)device_name deviceID:(NSString *)device_id userName:(NSString *)user_name userPassword:(NSString *)user_password deviceStatus:(DeviceStatus)deviceStatus;
- (instancetype)initWithDeviceCoraDataObject:(AiertDeviceCoreDataStorageObject *)object;

@end
