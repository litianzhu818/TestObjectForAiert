//
//  DeviceAddition.h
//  AiertApp
//
//  Created by  李天柱 on 14-10-19.
//  Copyright (c) 2014年 爱尔特电子有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AiertProtocol.h"

@interface DeviceAddition : NSObject<NSCopying, NSCoding>

@property (strong, nonatomic) NSString *IP;//设备ip
@property (assign, nonatomic) NSInteger port;//设备port
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
/**
 *  初始化
 *
 *  @param deviceInfo 局域网搜索后的信息
 *
 *  @return 实例对象
 */
-(instancetype)initWithPingStructObject:(PING_DEVICE_INFO)deviceInfo;
/**
 *  根据ping之后的信息设置设备信息
 *
 *  @param deviceInfo 设备信息的结构体
 */
-(void)setDeviceInfo:(PING_DEVICE_INFO)deviceInfo;
/**
 *  修改设备信息
 *
 *  @param deviceInfo ping之后得到设备信息的结构体
 */
-(void)modifiedDeviceInfoWith:(PING_DEVICE_INFO)deviceInfo;

@end
