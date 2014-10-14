//
//  WebInterface.m
//  MyAiertWebInterface
//
//  Created by Peter Lee on 14/9/13.
//  Copyright (c) 2013年 爱尔特电子有限公司. All rights reserved.
//

#import "WebInterface.h"

#import "AFNetworking.h" //使用AFNetworking

@implementation WebInterface

//================================================================================================
//Core Request
+ (void)coreWebInterfaceWithRequest:(NSString *)requestParam
                            success:(void (^)(NSDictionary *))success
                            failure:(void (^)(NSDictionary *))failure
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",@"http://106.120.243.22:80",requestParam];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[requestUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
    //AFNetworking
    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/html"]];
    //
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation
     JSONRequestOperationWithRequest: request
     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
         //RealZYC Add
         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
         
         NSDictionary *data = (NSDictionary *)JSON;
         NSString *result = [data webInterfaceResult];
         
         if ([result isEqualToString:WebInterface_Result_Ok]) {
             if (success) {
                 success(data);
             }
         }
         else {
             if (failure) {
                 failure(data);
             }
         }
     }
     failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
         //RealZYC Add
         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
         
         NSDictionary *data = [[NSDictionary alloc]
                               initWithObjects:[NSArray arrayWithObject:WebInterface_Result_NetworkError]
                               forKeys:[NSArray arrayWithObject:WebInterface_Result]];
         if (failure) {
             failure(data);
         }
     }];
    
    [operation start];

}
//================================================================================================

//Login
+ (void)loginWithUserName:(NSString *)username
                 password:(NSString *)password
                  success:(void (^)(NSDictionary *))success
                  failure:(void (^)(NSDictionary *))failure
{
    [WebInterface coreWebInterfaceWithRequest:[NSString stringWithFormat:@"/user/login?password=%@&username=%@",
                                               password,
                                               username]
                                      success:success
                                      failure:failure];
}

//Logout
+ (void)logoutWithTokenId:(NSString *)tokenId
                  success:(void (^)(NSDictionary *))success
                  failure:(void (^)(NSDictionary *))failure
{
    [WebInterface coreWebInterfaceWithRequest:[NSString stringWithFormat:@"/user/logout?tokenid=%@",
                                               tokenId]
                                      success:success
                                      failure:failure];
}

//Add User
+ (void)addUserWithEmail:(NSString *)email
                password:(NSString *)password
                 success:(void (^)(NSDictionary *data))success
                 failure:(void (^)(NSDictionary *data))failure
{
    [WebInterface coreWebInterfaceWithRequest:[NSString stringWithFormat:@"/user/add?email=%@&password=%@",
                                               email,
                                               password]
                                      success:success
                                      failure:failure];
}

//Modify Password
+ (void)modifyPasswordWithTokenId:(NSString *)tokenId
                         password:(NSString *)password
                      oldPassword:(NSString *)oldPassword
                          success:(void (^)(NSDictionary *data))success
                          failure:(void (^)(NSDictionary *data))failure
{
    [WebInterface coreWebInterfaceWithRequest:[NSString stringWithFormat:@"/user/modifypwd?tokenid=%@&password=%@&oldpassword=%@",
                                               tokenId,
                                               password,
                                               oldPassword]
                                      success:success
                                      failure:failure];
}

//Modify User Name
+ (void)modifyUserNameWithTokenId:(NSString *)tokenId
                         userName:(NSString *)username
                          success:(void (^)(NSDictionary *data))success
                          failure:(void (^)(NSDictionary *data))failure
{
    [WebInterface coreWebInterfaceWithRequest:[NSString stringWithFormat:@"/user/modifyname?tokenid=%@&username=%@",
                                               tokenId,
                                               username]
                                      success:success
                                      failure:failure];
}

//Forget Password
+ (void)forgetPasswordWithEmail:(NSString *)email
                        success:(void (^)(NSDictionary *data))success
                        failure:(void (^)(NSDictionary *data))failure
{
    [WebInterface coreWebInterfaceWithRequest:[NSString stringWithFormat:@"/user/forgetpwd?email=%@",
                                               email]
                                      success:success
                                      failure:failure];
}

//List Device
+ (void)listDeviceWithTokenId:(NSString *)tokenId
                        start:(int)start
                        count:(int)count
                      success:(void (^)(NSDictionary *data))success
                      failure:(void (^)(NSDictionary *data))failure
{
    [WebInterface coreWebInterfaceWithRequest:[NSString stringWithFormat:@"/device/list?tokenid=%@&start=%d&count=%d",
                                               tokenId,
                                               start,
                                               count]
                                      success:success
                                      failure:failure];
}

//Set Device Alarm
+ (void)setAlarmWithTokenId:(NSString *)tokenId
                   deviceId:(NSString *)deviceId
                      alarm:(int)alarm  //0=Off, 1=On
                    success:(void (^)(NSDictionary *data))success
                    failure:(void (^)(NSDictionary *data))failure
{
    [WebInterface coreWebInterfaceWithRequest:[NSString stringWithFormat:@"/device/setalarm?tokenid=%@&id=%@&device_alarm=%d",
                                               tokenId,
                                               deviceId,
                                               alarm]
                                      success:success
                                      failure:failure];
}

//Set Device Pilot
+ (void)setPilotWithTokenId:(NSString *)tokenId
                   deviceId:(NSString *)deviceId
                      pilot:(int)pilot  //0=Off, 1=On
                    success:(void (^)(NSDictionary *data))success
                    failure:(void (^)(NSDictionary *data))failure
{
    [WebInterface coreWebInterfaceWithRequest:[NSString stringWithFormat:@"/device/setpilot?tokenid=%@&id=%@&device_pilot=%d",
                                               tokenId,
                                               deviceId,
                                               pilot]
                                      success:success
                                      failure:failure];
}

//Modify Device Name
+ (void)modifyDeviceNameWithTokenId:(NSString *)tokenId
                           deviceId:(NSString *)deviceId
                               name:(NSString *)name
                            success:(void (^)(NSDictionary *data))success
                            failure:(void (^)(NSDictionary *data))failure
{
    [WebInterface coreWebInterfaceWithRequest:[NSString stringWithFormat:@"/device/modifyname?tokenid=%@&id=%@&device_name=%@",
                                               tokenId,
                                               deviceId,
                                               name]
                                      success:success
                                      failure:failure];
}

//Message
//Delete Message
+ (void)deleteMessageWithTokenId:(NSString *)tokenId
                       messageId:(NSString *)messageId
                     messageType:(NSString *)messageType
                         success:(void (^)(NSDictionary *data))success
                         failure:(void (^)(NSDictionary *data))failure
{
    [WebInterface coreWebInterfaceWithRequest:[NSString stringWithFormat:@"/message/delete?tokenid=%@&id=%@&message_type=%@",
                                               tokenId,
                                               messageId,
                                               messageType]
                                      success:success
                                      failure:failure];
}

//读取信息
+ (void)readMessageWithTokenId:(NSString *)tokenId
                     messageId:(NSString *)messageId
                       success:(void (^)(NSDictionary *data))success
                       failure:(void (^)(NSDictionary *data))failure
{
    [WebInterface coreWebInterfaceWithRequest:[NSString stringWithFormat:@"/message/read?tokenid=%@&id=%@",
                                               tokenId,
                                               messageId]
                                      success:success
                                      failure:failure];
}

//列出信息
+ (void)listMessageWithTokenId:(NSString *)tokenId
                   messageType:(int)messageType
                         start:(int)start
                         count:(int)count
                       success:(void (^)(NSDictionary *data))success
                       failure:(void (^)(NSDictionary *data))failure
{
    [WebInterface coreWebInterfaceWithRequest:[NSString stringWithFormat:@"/message/list?tokenid=%@&message_type=%d&start=%d&count=%d",
                                               tokenId,
                                               messageType,
                                               start,
                                               count]
                                      success:success
                                      failure:failure];
}

//信息数量
+ (void)numberOfMessageWithTokenId:(NSString *)tokenId
                            ifRead:(int)ifRead
                           success:(void (^)(NSDictionary *data))success
                           failure:(void (^)(NSDictionary *data))failure
{
    [WebInterface coreWebInterfaceWithRequest:[NSString stringWithFormat:@"/message/msgnum?tokenid=%@&if_read=%i",
                                               tokenId,
                                               ifRead]
                                      success:success
                                      failure:failure];
}

//Device
//设备消息数量
+ (void)numberOfDeviceMessageWithTokenId:(NSString *)tokenId
                                deviceId:(NSString *)deviceId
                                  ifRead:(int)ifRead
                                 success:(void (^)(NSDictionary *data))success
                                 failure:(void (^)(NSDictionary *data))failure
{
    [WebInterface coreWebInterfaceWithRequest:[NSString stringWithFormat:@"/device/msgnum?tokenid=%@&id=%@&if_read=%i",
                                               tokenId,
                                               deviceId,
                                               ifRead]
                                      success:success
                                      failure:failure];
}

//列出设备记录
+ (void)listDeviceRecordWithTokenId:(NSString *)tokenId
                         physicalId:(NSString *)physicalId
                          channelId:(NSString *)channelId
                        currentTime:(NSString *)currentTime
                               type:(NSString *)type
                            success:(void (^)(NSDictionary *data))success
                            failure:(void (^)(NSDictionary *data))failure
{
    [WebInterface coreWebInterfaceWithRequest:[NSString stringWithFormat:@"/device/recordlist?tokenid=%@&physical_id=%@&channel_id=%@&cur_time=%@&type=%@",
                                               tokenId,
                                               physicalId,
                                               channelId,
                                               currentTime,
                                               type]
                                      success:success
                                      failure:failure];
}

//列出信息
+ (void)listDeviceMessageWithTokenId:(NSString *)tokenId
                            deviceId:(NSString *)deviceId
                         messageType:(int)messageType
                               start:(int)start
                               count:(int)count
                             success:(void (^)(NSDictionary *data))success
                             failure:(void (^)(NSDictionary *data))failure
{
    [WebInterface coreWebInterfaceWithRequest:[NSString stringWithFormat:@"/device/msglist?tokenid=%@&id=%@&message_type=%d&start=%i&count=%i",
                                               tokenId,
                                               deviceId,
                                               messageType,
                                               start,
                                               count]
                                      success:success
                                      failure:failure];
}

//Notification
//注册通知
+ (void)registerNotificationWithTokenId:(NSString *)tokenId
                            deviceToken:(NSString *)deviceToken
                                success:(void (^)(NSDictionary *data))success
                                failure:(void (^)(NSDictionary *data))failure
{
    [WebInterface coreWebInterfaceWithRequest:[NSString stringWithFormat:@"/cache/devicetoken?tokenid=%@&device_token=%@",
                                               tokenId,
                                               deviceToken]
                                      success:success
                                      failure:failure];
}

@end
