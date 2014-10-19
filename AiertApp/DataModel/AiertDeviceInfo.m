//
//  AiertDeviceInfo.m
//  AiertApp
//
//  Created by Peter Lee on 14/9/13.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "AiertDeviceInfo.h"

@implementation AiertDeviceInfo

- (instancetype)initWithDeviceName:(NSString *)device_name deviceID:(NSString *)device_id userInfo:(AiertUserInfo *)userInfo
{
    self = [super init];
    if (self) {
        self.deviceID = device_id;
        self.deviceName = device_name;
        self.userInfo = userInfo;
        self.isONLine = NO;
        if (self.isONLine) {
            self.deviceStatus = DeviceStatusOnline;
        }else{
            self.deviceStatus = DeviceStatusOffline;
        }
    }
    return self;
}
- (instancetype)initWithDeviceName:(NSString *)device_name deviceID:(NSString *)device_id deviceStatus:(DeviceStatus)deviceStatus userInfo:(AiertUserInfo *)userInfo
{
    self = [super init];
    if (self) {
        self.deviceID = device_id;
        self.deviceName = device_name;
        self.userInfo = userInfo;
        self.deviceStatus = deviceStatus;
        if (self.deviceStatus == DeviceStatusOnline) {
            self.isONLine = YES;
        }else{
            self.isONLine = NO;
        }
    }
    return self;
}


- (instancetype)initWithDeviceName:(NSString *)device_name deviceID:(NSString *)device_id userName:(NSString *)user_name userPassword:(NSString *)user_password
{
    self = [super init];
    if (self) {
        self.deviceID = device_id;
        self.deviceName = device_name;
        self.userInfo = [[AiertUserInfo alloc] initWithUserName:user_name userPassword:user_password];
        self.isONLine = NO;
        if (self.isONLine) {
            self.deviceStatus = DeviceStatusOnline;
        }else{
            self.deviceStatus = DeviceStatusOffline;
        }
    }
    return self;
}

- (instancetype)initWithDeviceName:(NSString *)device_name deviceID:(NSString *)device_id userName:(NSString *)user_name userPassword:(NSString *)user_password deviceStatus:(DeviceStatus)deviceStatus
{
    self = [super init];
    if (self) {
        self.deviceID = device_id;
        self.deviceName = device_name;
        self.userInfo = [[AiertUserInfo alloc] initWithUserName:user_name userPassword:user_password];
        self.deviceStatus = deviceStatus;
        if (self.deviceStatus == DeviceStatusOnline) {
            self.isONLine = YES;
        }else{
            self.isONLine = NO;
        }
    }
    return self;
}

- (instancetype)initWithDeviceCoraDataObject:(AiertDeviceCoreDataStorageObject *)object
{
    self = [super init];
    if (self) {
        self.deviceID = object.deviceID;
        self.deviceName = object.deviceName;
        self.deviceStatus = [[object deviceStatus] intValue];
        self.userInfo = [[AiertUserInfo alloc] initWithUserName:object.userName userPassword:object.userPassword];
        if (self.deviceStatus == DeviceStatusOnline) {
            self.isONLine = YES;
        }else{
            self.isONLine = NO;
        }
    }
    return self;
}


- (void)dealloc
{
    self.deviceName = nil;
    self.deviceID = nil;
    self.userInfo = nil;
    self.deviceAdditionInfo = nil;
}
- (NSString *)description
{
    return [NSString stringWithFormat:@"Device={\n\tdeviceName=%@\n\tdeviceID=%@\n\tuserInfo=%@\n\tisOnLine=%@\n\tdeviceStatus=%@\n\t%@\n}", self.deviceName,self.deviceID,self.userInfo.description,(self.isONLine ? @"YES":@"NO"),((self.deviceStatus == 1)? @"DeviceStatusOffline":(self.deviceStatus == 0) ? @"DeviceStatusOnline":@"DeviceStatusConnectTimeout"),self.deviceAdditionInfo.description];
}

#pragma mark -
#pragma mark - NSCopying Methods
- (id)copyWithZone:(NSZone *)zone
{
    AiertDeviceInfo *newInfo = [[[self class] allocWithZone:zone] init];
    
    [newInfo setDeviceID:self.deviceID];
    [newInfo setDeviceName:self.deviceName];
    [newInfo setUserInfo:self.userInfo];
    [newInfo setIsONLine:self.isONLine];
    [newInfo setDeviceStatus:self.deviceStatus];
    [newInfo setDeviceAdditionInfo:self.deviceAdditionInfo];
    
    return newInfo;
}

#pragma mark -
#pragma mark - NSCoding Methods
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.deviceName forKey:@"deviceName"];
    [aCoder encodeObject:self.deviceID forKey:@"deviceID"];
    [aCoder encodeObject:self.userInfo forKey:@"userInfo"];
    [aCoder encodeObject:(self.isONLine ? @"YES":@"NO") forKey:@"isONLine"];
    [aCoder encodeObject:((self.deviceStatus == 1)? @"DeviceStatusOffline":(self.deviceStatus == 0) ? @"DeviceStatusOnline":@"DeviceStatusConnectTimeout") forKey:@"deviceStatus"];
    [aCoder encodeObject:self.deviceAdditionInfo forKey:@"deviceAdditionInfo"];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        
        self.deviceID = [aDecoder decodeObjectForKey:@"deviceID"];
        self.deviceName = [aDecoder decodeObjectForKey:@"deviceName"];
        self.userInfo = [aDecoder decodeObjectForKey:@"userInfo"];
        self.isONLine = ([[aDecoder decodeObjectForKey:@"isONLine"] isEqualToString:@"YES"] ? YES:NO);
        self.deviceStatus = ([[aDecoder decodeObjectForKey:@"deviceStatus"] isEqualToString:@"DeviceStatusOnline"] ? 0:([[aDecoder decodeObjectForKey:@"deviceStatus"] isEqualToString:@"DeviceStatusOffline"] ? 1:2));
        self.deviceAdditionInfo = [aDecoder decodeObjectForKey:@"deviceAdditionInfo"];
        
    }
    return  self;

}
@end
