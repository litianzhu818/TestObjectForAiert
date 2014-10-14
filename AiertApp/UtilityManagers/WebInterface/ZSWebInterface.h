

#import <Foundation/Foundation.h>

#import "NSDictionary+WebInterface.h"

//Basic
#define WebInterface_Result_Ok                  @"ok"
#define WebInterface_Result_NetworkError        @"network_error"

//Login
#define WebInterface_Result_Login_invalid       @"username or password invalid"

@interface ZSWebInterface : NSObject

+ (NSString *)tokenId;

//登陆
//NSDictionary *data请使用"NSDictionary+WebInterface.h"解析
+ (void)loginWithUserName:(NSString *)username
                 password:(NSString *)password
                  success:(void (^)(NSDictionary *data))success
                  failure:(void (^)(NSDictionary *data))failure;

//登出
//tokenId在login成功时的[data webInterfaceAddition]给出
//NSDictionary *data请使用"NSDictionary+WebInterface.h"解析
+ (void)logoutWithSuccess:(void (^)(NSDictionary *data))success
                  failure:(void (^)(NSDictionary *data))failure;

//注册用户
+ (void)addUserWithEmail:(NSString *)email
                password:(NSString *)password
                 success:(void (^)(NSDictionary *data))success
                 failure:(void (^)(NSDictionary *data))failure;

//更改密码
+ (void)modifyPasswordWithPassword:(NSString *)password
                       oldPassword:(NSString *)oldPassword
                           success:(void (^)(NSDictionary *data))success
                           failure:(void (^)(NSDictionary *data))failure;

//更改用户名
+ (void)modifyUserNameWithUserName:(NSString *)username
                           success:(void (^)(NSDictionary *data))success
                           failure:(void (^)(NSDictionary *data))failure;

//忘记密码
+ (void)forgetPasswordWithEmail:(NSString *)email
                        success:(void (^)(NSDictionary *data))success
                        failure:(void (^)(NSDictionary *data))failure;

//列出摄像头
+ (void)listDeviceWithStart:(int)start
                      count:(int)count
                    success:(void (^)(NSDictionary *data))success
                    failure:(void (^)(NSDictionary *data))failure;

// 添加摄像头
+ (void)addDeviceWithDeviceId:(NSString *)deviceId
                   deviceName:(NSString *)deviceName
                   accessName:(NSString *)accessName
                     password:(NSString *)password
                        scene:(NSInteger)scene
                  description:(NSString *)description
                      success:(void (^)(NSDictionary *data))success
                      failure:(void (^)(NSDictionary *data))failure;


//摄像头报警
+ (void)setAlarmWithDeviceId:(NSString *)deviceId
                       alarm:(int)alarm  //0=Off, 1=On
                     success:(void (^)(NSDictionary *data))success
                     failure:(void (^)(NSDictionary *data))failure;

//摄像头闪光
+ (void)setPilotWithDeviceId:(NSString *)deviceId
                       pilot:(int)pilot  //0=Off, 1=On
                     success:(void (^)(NSDictionary *data))success
                     failure:(void (^)(NSDictionary *data))failure;

//修改设备名称
+ (void)modifyDeviceNameWithDeviceId:(NSString *)deviceId
                                name:(NSString *)name
                          accessName:(NSString *)accessName
                            password:(NSString *)password
                             success:(void (^)(NSDictionary *data))success
                             failure:(void (^)(NSDictionary *data))failure;

//Message
//删除信息
+ (void)deleteMessageWithMessageId:(NSString *)messageId
                       messageType:(NSString *)messageType
                           success:(void (^)(NSDictionary *data))success
                           failure:(void (^)(NSDictionary *data))failure;

//读取信息
+ (void)readMessageWithMessageId:(NSString *)messageId
                         success:(void (^)(NSDictionary *data))success
                         failure:(void (^)(NSDictionary *data))failure;

//列出信息
+ (void)listMessageWithMessageType:(int)messageType
                             start:(int)start
                             count:(int)count
                           success:(void (^)(NSDictionary *data))success
                           failure:(void (^)(NSDictionary *data))failure;

//信息数量
+ (void)numberOfMessageWithIfRead:(int)ifRead
                          success:(void (^)(NSDictionary *data))success
                          failure:(void (^)(NSDictionary *data))failure;

//Device
//设备消息数量
+ (void)numberOfDeviceMessageWithDeviceId:(NSString *)deviceId
                                   ifRead:(int)ifRead
                                  success:(void (^)(NSDictionary *data))success
                                  failure:(void (^)(NSDictionary *data))failure;

//列出设备记录
+ (void)listDeviceRecordWithPhysicalId:(NSString *)physicalId
                             channelId:(NSString *)channelId
                           currentTime:(NSString *)currentTime
                                  type:(NSString *)type
                               success:(void (^)(NSDictionary *data))success
                               failure:(void (^)(NSDictionary *data))failure;

//列出信息
+ (void)listDeviceMessageWithDeviceId:(NSString *)deviceId
                          messageType:(int)messageType
                                start:(int)start
                                count:(int)count
                              success:(void (^)(NSDictionary *data))success
                              failure:(void (^)(NSDictionary *data))failure;

//Notification
//注册通知
+ (void)registerNotificationWithDeviceToken:(NSString *)deviceToken
                                    success:(void (^)(NSDictionary *data))success
                                    failure:(void (^)(NSDictionary *data))failure;

@end
