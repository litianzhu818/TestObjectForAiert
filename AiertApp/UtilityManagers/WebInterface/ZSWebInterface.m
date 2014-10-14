

#import "ZSWebInterface.h"
#import "AFNetworking.h"

#define kWebServer @"http://192.241.57.99:80"

//#define kWebServer @"http://106.120.243.22:81"

@interface ZSWebInterface ()
@property (copy, nonatomic)NSString *tokenId;
@end

@implementation ZSWebInterface

+ (ZSWebInterface *)sharedInstance
{
    static  ZSWebInterface *sharedIns = nil ;
    static  dispatch_once_t onceToken;
    dispatch_once (& onceToken, ^ {
        sharedIns = [[self alloc]init];
    });
    return sharedIns;
}

+ (NSString *)tokenId
{
    return [[ZSWebInterface sharedInstance] tokenId];
}

- (void)coreWebInterfaceWithRequest:(NSString *)requestParam
                            success:(void (^)(NSDictionary *))success
                            failure:(void (^)(NSDictionary *))failure
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",kWebServer,requestParam];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[requestUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
    DLog(@"request============> %@",request);
    
    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/html"]];
    
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation
     JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
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

+ (void)loginWithUserName:(NSString *)username
                 password:(NSString *)password
                  success:(void (^)(NSDictionary *))success
                  failure:(void (^)(NSDictionary *))failure
{
    [[ZSWebInterface sharedInstance] coreWebInterfaceWithRequest:[NSString stringWithFormat:@"/user/login?password=%@&username=%@&clienttype=1",
                                                                  password,
                                                                  username]
                                                         success:^(NSDictionary *data) {
                                                             DLog(@"%@",[data objectForKey:@"addition"]);
                                                             if ([data objectForKey:@"addition"]) {
                                                                 [[ZSWebInterface sharedInstance] setTokenId:[data objectForKey:@"addition"]];
                                                             }
                                                             success(data);
                                                         }
                                                         failure:failure];
}

+ (void)logoutWithSuccess:(void (^)(NSDictionary *data))success
                  failure:(void (^)(NSDictionary *data))failure
{
    [[ZSWebInterface sharedInstance] coreWebInterfaceWithRequest:[NSString stringWithFormat:@"/user/logout?tokenid=%@",
                                                                  [ZSWebInterface sharedInstance].tokenId]
                                                         success:success
                                                         failure:failure];
}

+ (void)addUserWithEmail:(NSString *)email
                password:(NSString *)password
                 success:(void (^)(NSDictionary *data))success
                 failure:(void (^)(NSDictionary *data))failure
{
    [[ZSWebInterface sharedInstance] coreWebInterfaceWithRequest:[NSString stringWithFormat:@"/user/add?email=%@&password=%@",
                                                                  email,
                                                                  password]
                                                         success:success
                                                         failure:failure];
}

+ (void)modifyPasswordWithPassword:(NSString *)password
                       oldPassword:(NSString *)oldPassword
                           success:(void (^)(NSDictionary *data))success
                           failure:(void (^)(NSDictionary *data))failure
{
    [[ZSWebInterface sharedInstance] coreWebInterfaceWithRequest:[NSString stringWithFormat:@"/user/modifypwd?tokenid=%@&password=%@&oldpassword=%@",
                                                                  [ZSWebInterface sharedInstance].tokenId,
                                                                  password,
                                                                  oldPassword]
                                                         success:success
                                                         failure:failure];
}

+ (void)modifyUserNameWithUserName:(NSString *)username
                           success:(void (^)(NSDictionary *data))success
                           failure:(void (^)(NSDictionary *data))failure
{
    [[ZSWebInterface sharedInstance] coreWebInterfaceWithRequest:[NSString stringWithFormat:@"/user/modifyname?tokenid=%@&username=%@",
                                                                  [ZSWebInterface sharedInstance].tokenId,
                                                                  username]
                                                         success:success
                                                         failure:failure];
}

+ (void)forgetPasswordWithEmail:(NSString *)email
                        success:(void (^)(NSDictionary *data))success
                        failure:(void (^)(NSDictionary *data))failure
{
    [[ZSWebInterface sharedInstance] coreWebInterfaceWithRequest:[NSString stringWithFormat:@"/user/forgetpwd?email=%@",
                                                                  email]
                                                         success:success
                                                         failure:failure];
}

+ (void)listDeviceWithStart:(int)start
                      count:(int)count
                    success:(void (^)(NSDictionary *data))success
                    failure:(void (^)(NSDictionary *data))failure
{
    [[ZSWebInterface sharedInstance] coreWebInterfaceWithRequest:[NSString stringWithFormat:@"/device/devlist?tokenid=%@&start=%d&count=%d",
                                                                  [ZSWebInterface sharedInstance].tokenId,
                                                                  start,
                                                                  count]
                                                         success:success
                                                         failure:failure];
}

+ (void)addDeviceWithDeviceId:(NSString *)deviceId
                   deviceName:(NSString *)deviceName
                   accessName:(NSString *)accessName
                     password:(NSString *)password
                        scene:(NSInteger)scene
                  description:(NSString *)description
                      success:(void (^)(NSDictionary *data))success
                      failure:(void (^)(NSDictionary *data))failure
{
    [[ZSWebInterface sharedInstance] coreWebInterfaceWithRequest:[NSString stringWithFormat:@"/device/devadd?tokenid=%@&physical_id=%@&device_name=%@&device_scene=%d&device_description=%@&access_name=%@&access_password=%@",
                                                                  [ZSWebInterface sharedInstance].tokenId,
                                                                  deviceId,
                                                                  deviceName,
                                                                  scene,
                                                                  description,
                                                                  accessName,
                                                                  password]
                                                         success:success
                                                         failure:failure];
}

+ (void)setAlarmWithDeviceId:(NSString *)deviceId
                       alarm:(int)alarm  //0=Off, 1=On
                     success:(void (^)(NSDictionary *data))success
                     failure:(void (^)(NSDictionary *data))failure
{
    [[ZSWebInterface sharedInstance] coreWebInterfaceWithRequest:[NSString stringWithFormat:@"/device/setalarm?tokenid=%@&id=%@&device_alarm=%d",
                                                                  [ZSWebInterface sharedInstance].tokenId,
                                                                  deviceId,
                                                                  alarm]
                                                         success:success
                                                         failure:failure];
}

+ (void)setPilotWithDeviceId:(NSString *)deviceId
                       pilot:(int)pilot  //0=Off, 1=On
                     success:(void (^)(NSDictionary *data))success
                     failure:(void (^)(NSDictionary *data))failure
{
    [[ZSWebInterface sharedInstance] coreWebInterfaceWithRequest:[NSString stringWithFormat:@"/device/setpilot?tokenid=%@&id=%@&device_pilot=%d",
                                                                  [ZSWebInterface sharedInstance].tokenId,
                                                                  deviceId,
                                                                  pilot]
                                                         success:success
                                                         failure:failure];
}

+ (void)modifyDeviceNameWithDeviceId:(NSString *)deviceId
                                name:(NSString *)name
                          accessName:(NSString *)accessName
                            password:(NSString *)password
                             success:(void (^)(NSDictionary *data))success
                             failure:(void (^)(NSDictionary *data))failure
{
    [[ZSWebInterface sharedInstance] coreWebInterfaceWithRequest:[NSString stringWithFormat:@"/device/modifyname?tokenid=%@&id=%@&device_name=%@&access_name=%@&access_password=%@",
                                                                  [ZSWebInterface sharedInstance].tokenId,
                                                                  deviceId,
                                                                  name,
                                                                  accessName,
                                                                  password]
                                                         success:success
                                                         failure:failure];
}

+ (void)deleteMessageWithMessageId:(NSString *)messageId
                       messageType:(NSString *)messageType
                           success:(void (^)(NSDictionary *data))success
                           failure:(void (^)(NSDictionary *data))failure
{
    [[ZSWebInterface sharedInstance] coreWebInterfaceWithRequest:[NSString stringWithFormat:@"/message/delete?tokenid=%@&id=%@&message_type=%@",
                                                                  [ZSWebInterface sharedInstance].tokenId,
                                                                  messageId,
                                                                  messageType]
                                                         success:success
                                                         failure:failure];
}

+ (void)readMessageWithMessageId:(NSString *)messageId
                         success:(void (^)(NSDictionary *data))success
                         failure:(void (^)(NSDictionary *data))failure
{
    [[ZSWebInterface sharedInstance] coreWebInterfaceWithRequest:[NSString stringWithFormat:@"/message/read?tokenid=%@&id=%@",
                                                                  [ZSWebInterface sharedInstance].tokenId,
                                                                  messageId]
                                                         success:success
                                                         failure:failure];
}

+ (void)listMessageWithMessageType:(int)messageType
                             start:(int)start
                             count:(int)count
                           success:(void (^)(NSDictionary *data))success
                           failure:(void (^)(NSDictionary *data))failure
{
    [[ZSWebInterface sharedInstance] coreWebInterfaceWithRequest:[NSString stringWithFormat:@"/message/list?tokenid=%@&message_type=%d&start=%d&count=%d",
                                                                  [ZSWebInterface sharedInstance].tokenId,
                                                                  messageType,
                                                                  start,
                                                                  count]
                                                         success:success
                                                         failure:failure];
}

+ (void)numberOfMessageWithIfRead:(int)ifRead
                          success:(void (^)(NSDictionary *data))success
                          failure:(void (^)(NSDictionary *data))failure
{
    [[ZSWebInterface sharedInstance] coreWebInterfaceWithRequest:[NSString stringWithFormat:@"/message/msgnum?tokenid=%@&if_read=%i",
                                                                  [ZSWebInterface sharedInstance].tokenId,
                                                                  ifRead]
                                                         success:success
                                                         failure:failure];
}

+ (void)numberOfDeviceMessageWithDeviceId:(NSString *)deviceId
                                   ifRead:(int)ifRead
                                  success:(void (^)(NSDictionary *data))success
                                  failure:(void (^)(NSDictionary *data))failure
{
    [[ZSWebInterface sharedInstance] coreWebInterfaceWithRequest:[NSString stringWithFormat:@"/device/msgnum?tokenid=%@&id=%@&if_read=%i",
                                                                  [ZSWebInterface sharedInstance].tokenId,
                                                                  deviceId,
                                                                  ifRead]
                                                         success:success
                                                         failure:failure];
}

+ (void)listDeviceRecordWithPhysicalId:(NSString *)physicalId
                             channelId:(NSString *)channelId
                           currentTime:(NSString *)currentTime
                                  type:(NSString *)type
                               success:(void (^)(NSDictionary *data))success
                               failure:(void (^)(NSDictionary *data))failure
{
    [[ZSWebInterface sharedInstance] coreWebInterfaceWithRequest:[NSString stringWithFormat:@"/device/recordlist?tokenid=%@&physical_id=%@&channel_id=%@&cur_time=%@&type=%@",
                                                                  [ZSWebInterface sharedInstance].tokenId,
                                                                  physicalId,
                                                                  channelId,
                                                                  currentTime,
                                                                  type]
                                                         success:success
                                                         failure:failure];
}

+ (void)listDeviceMessageWithDeviceId:(NSString *)deviceId
                          messageType:(int)messageType
                                start:(int)start
                                count:(int)count
                              success:(void (^)(NSDictionary *data))success
                              failure:(void (^)(NSDictionary *data))failure
{
    [[ZSWebInterface sharedInstance] coreWebInterfaceWithRequest:[NSString stringWithFormat:@"/device/msglist?tokenid=%@&id=%@&message_type=%d&start=%i&count=%i",
                                                                  [ZSWebInterface sharedInstance].tokenId,
                                                                  deviceId,
                                                                  messageType,
                                                                  start,
                                                                  count]
                                                         success:success
                                                         failure:failure];
}

+ (void)registerNotificationWithDeviceToken:(NSString *)deviceToken
                                    success:(void (^)(NSDictionary *data))success
                                    failure:(void (^)(NSDictionary *data))failure
{
    [[ZSWebInterface sharedInstance] coreWebInterfaceWithRequest:[NSString stringWithFormat:@"/cache/devicetoken?tokenid=%@&device_token=%@&platform=1",
                                                                  [ZSWebInterface sharedInstance].tokenId,
                                                                  deviceToken]
                                                         success:success
                                                         failure:failure];
}

@end
