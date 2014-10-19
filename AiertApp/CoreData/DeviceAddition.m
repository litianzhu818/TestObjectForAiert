//
//  DeviceAddition.m
//  AiertApp
//
//  Created by  李天柱 on 14-10-19.
//  Copyright (c) 2014年 爱尔特电子有限公司. All rights reserved.
//

#import "DeviceAddition.h"

@implementation DeviceAddition

-(NSString *)description
{
    //Add your code here
    //Such as the code here
    return [NSString stringWithFormat:@"\nDeviceAddition={\n\t \
            deviceType=%d\n\t               \
            serialNumber=%@\n\t             \
            hardWareVersion=%@\n\t          \
            softWareVersion=%@\n\t          \
            videoNum=%d\n\t                 \
            audioNum=%d\n\t                 \
            alarmInNum=%d\n\t               \
            alarmOutNum=%d\n\t              \
            supportAudioTalk=%@\n\t         \
            supportStore=%@\n\t             \
            supportWiFi=%@\n\t              \
            resver=%@\n}",
            self.deviceType,self.serialNumber,self.hardWareVersion,self.softWareVersion,self.videoNum,self.audioNum,self.alarmInNum,self.alarmOutNum,((self.supportAudioTalk > 0) ? @"YES":@"NO"),((self.supportStore > 0) ? @"YES":@"NO"),((self.supportWiFi > 0) ? @"YES":@"NO"),((self.resver > 0) ? @"YES":@"NO")];
}


#pragma mark -
#pragma mark NSCopying Methods
- (id)copyWithZone:(NSZone *)zone
{
    DeviceAddition *newObject = [[[self class] allocWithZone:zone] init];
    //Here is a sample for using the NScoding method
    //Add your code here
    [newObject setDeviceType:self.deviceType];
    [newObject setSerialNumber:self.serialNumber];
    [newObject setHardWareVersion:self.hardWareVersion];
    [newObject setSoftWareVersion:self.softWareVersion];
    [newObject setVideoNum:self.videoNum];
    [newObject setAudioNum:self.audioNum];
    [newObject setAlarmInNum:self.alarmInNum];
    [newObject setAlarmOutNum:self.alarmOutNum];
    [newObject setSupportAudioTalk:self.supportAudioTalk];
    [newObject setSupportStore:self.supportStore];
    [newObject setSupportWiFi:self.supportWiFi];
    [newObject setResver:self.resver];
    
    return newObject;
}

#pragma mark -
#pragma mark NSCoding Methods
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    //Here is a sample for using the NScoding method
    //Add your code here
    [aCoder encodeObject:[NSNumber numberWithInteger:self.deviceType] forKey:@"deviceType"];
    [aCoder encodeObject:self.serialNumber forKey:@"serialNumber"];
    [aCoder encodeObject:[NSNumber numberWithInteger:self.hardWareVersion] forKey:@"hardWareVersion"];
    [aCoder encodeObject:[NSNumber numberWithInteger:self.softWareVersion] forKey:@"softWareVersion"];
    [aCoder encodeObject:[NSNumber numberWithInteger:self.videoNum] forKey:@"videoNum"];
    [aCoder encodeObject:[NSNumber numberWithInteger:self.audioNum] forKey:@"audioNum"];
    [aCoder encodeObject:[NSNumber numberWithInteger:self.alarmInNum] forKey:@"alarmInNum"];
    [aCoder encodeObject:[NSNumber numberWithInteger:self.alarmOutNum] forKey:@"alarmOutNum"];
    [aCoder encodeObject:[NSNumber numberWithInteger:self.supportAudioTalk] forKey:@"supportAudioTalk"];
    [aCoder encodeObject:[NSNumber numberWithInteger:self.supportStore] forKey:@"supportStore"];
    [aCoder encodeObject:[NSNumber numberWithInteger:self.supportWiFi] forKey:@"supportWiFi"];
    [aCoder encodeObject:[NSNumber numberWithInteger:self.resver] forKey:@"resver"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        //Here is a sample for using the NScoding method
        //Add your code here
        self.deviceType = [((NSNumber *)[aDecoder decodeObjectForKey:@"deviceType"]) integerValue];
        self.serialNumber = [aDecoder decodeObjectForKey:@"serialNumber"];
        self.hardWareVersion = [aDecoder decodeObjectForKey:@"hardWareVersion"];
        self.softWareVersion = [aDecoder decodeObjectForKey:@"softWareVersion"];
        self.videoNum = [((NSNumber *)[aDecoder decodeObjectForKey:@"videoNum"]) integerValue];
        self.audioNum = [((NSNumber *)[aDecoder decodeObjectForKey:@"audioNum"]) integerValue];
        self.alarmInNum = [((NSNumber *)[aDecoder decodeObjectForKey:@"alarmInNum"]) integerValue];
        self.alarmOutNum = [((NSNumber *)[aDecoder decodeObjectForKey:@"alarmOutNum"]) integerValue];
        self.supportAudioTalk = [((NSNumber *)[aDecoder decodeObjectForKey:@"supportAudioTalk"]) integerValue];
        self.supportStore = [((NSNumber *)[aDecoder decodeObjectForKey:@"supportStore"]) integerValue];
        self.supportWiFi = [((NSNumber *)[aDecoder decodeObjectForKey:@"supportWiFi"]) integerValue];
        self.resver = [((NSNumber *)[aDecoder decodeObjectForKey:@"resver"]) integerValue];
        
    }
    return  self;
}



@end
