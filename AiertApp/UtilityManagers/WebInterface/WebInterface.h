//
//  WebInterface.h
//  MyAiertWebInterface
//
//  Created by Peter Lee on 14/9/13.
//  Copyright (c) 2013年 爱尔特电子有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NSDictionary+WebInterface.h"
//Url
#define WebInterface_Url_Host                   @"http://106.120.243.22:80"

//Basic
#define WebInterface_Result_Ok                  @"ok"
#define WebInterface_Result_NetworkError        @"network_error"

//Login
#define WebInterface_Result_Login_invalid       @"username or password invalid"

@interface WebInterface : NSObject

//登陆
//NSDictionary *data请使用"NSDictionary+WebInterface.h"解析
+ (void)loginWithUserName:(NSString *)username
                 password:(NSString *)password
                  success:(void (^)(NSDictionary *data))success
                  failure:(void (^)(NSDictionary *data))failure;

//登出
//tokenId在login成功时的[data webInterfaceAddition]给出
//NSDictionary *data请使用"NSDictionary+WebInterface.h"解析
+ (void)logoutWithTokenId:(NSString *)tokenId
                  success:(void (^)(NSDictionary *data))success
                  failure:(void (^)(NSDictionary *data))failure;

//注册用户
+ (void)addUserWithEmail:(NSString *)email
                password:(NSString *)password
                 success:(void (^)(NSDictionary *data))success
                 failure:(void (^)(NSDictionary *data))failure;

//更改密码
+ (void)modifyPasswordWithTokenId:(NSString *)tokenId
                         password:(NSString *)password
                      oldPassword:(NSString *)oldPassword
                          success:(void (^)(NSDictionary *data))success
                          failure:(void (^)(NSDictionary *data))failure;

//更改用户名
+ (void)modifyUserNameWithTokenId:(NSString *)tokenId
                         userName:(NSString *)username
                          success:(void (^)(NSDictionary *data))success
                          failure:(void (^)(NSDictionary *data))failure;

//忘记密码
+ (void)forgetPasswordWithEmail:(NSString *)email
                        success:(void (^)(NSDictionary *data))success
                        failure:(void (^)(NSDictionary *data))failure;

//列出摄像头
+ (void)listDeviceWithTokenId:(NSString *)tokenId
                        start:(int)start
                        count:(int)count
                        success:(void (^)(NSDictionary *data))success
                      failure:(void (^)(NSDictionary *data))failure;

//摄像头报警
+ (void)setAlarmWithTokenId:(NSString *)tokenId
                   deviceId:(NSString *)deviceId
                      alarm:(int)alarm  //0=Off, 1=On
                    success:(void (^)(NSDictionary *data))success
                    failure:(void (^)(NSDictionary *data))failure;

//摄像头闪光
+ (void)setPilotWithTokenId:(NSString *)tokenId
                   deviceId:(NSString *)deviceId
                      pilot:(int)pilot  //0=Off, 1=On
                    success:(void (^)(NSDictionary *data))success
                    failure:(void (^)(NSDictionary *data))failure;

//修改设备名称
+ (void)modifyDeviceNameWithTokenId:(NSString *)tokenId
                           deviceId:(NSString *)deviceId
                               name:(NSString *)name
                            success:(void (^)(NSDictionary *data))success
                            failure:(void (^)(NSDictionary *data))failure;

//Message
//删除信息
+ (void)deleteMessageWithTokenId:(NSString *)tokenId
                       messageId:(NSString *)messageId
                     messageType:(NSString *)messageType
                         success:(void (^)(NSDictionary *data))success
                         failure:(void (^)(NSDictionary *data))failure;

//读取信息
+ (void)readMessageWithTokenId:(NSString *)tokenId
                     messageId:(NSString *)messageId
                       success:(void (^)(NSDictionary *data))success
                       failure:(void (^)(NSDictionary *data))failure;

//列出信息
+ (void)listMessageWithTokenId:(NSString *)tokenId
                   messageType:(int)messageType
                         start:(int)start
                         count:(int)count
                       success:(void (^)(NSDictionary *data))success
                       failure:(void (^)(NSDictionary *data))failure;

//信息数量
+ (void)numberOfMessageWithTokenId:(NSString *)tokenId
                            ifRead:(int)ifRead
                           success:(void (^)(NSDictionary *data))success
                           failure:(void (^)(NSDictionary *data))failure;

//Device
//设备消息数量
+ (void)numberOfDeviceMessageWithTokenId:(NSString *)tokenId
                                deviceId:(NSString *)deviceId
                                  ifRead:(int)ifRead
                                 success:(void (^)(NSDictionary *data))success
                                 failure:(void (^)(NSDictionary *data))failure;

//列出设备记录
+ (void)listDeviceRecordWithTokenId:(NSString *)tokenId
                         physicalId:(NSString *)physicalId
                          channelId:(NSString *)channelId
                        currentTime:(NSString *)currentTime
                               type:(NSString *)type
                            success:(void (^)(NSDictionary *data))success
                            failure:(void (^)(NSDictionary *data))failure;

//列出信息
+ (void)listDeviceMessageWithTokenId:(NSString *)tokenId
                            deviceId:(NSString *)deviceId
                         messageType:(int)messageType
                               start:(int)start
                               count:(int)count
                             success:(void (^)(NSDictionary *data))success
                             failure:(void (^)(NSDictionary *data))failure;

//Notification
//注册通知
+ (void)registerNotificationWithTokenId:(NSString *)tokenId
                            deviceToken:(NSString *)deviceToken
                                success:(void (^)(NSDictionary *data))success
                                failure:(void (^)(NSDictionary *data))failure;

@end
