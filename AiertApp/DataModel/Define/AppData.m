
#import "AppData.h"
#import "Utilities.h"
#import "ZMDevice.h"

#define kUser @"user"

@interface AppData ()

@property (nonatomic) NSInteger connectionState;
@property (nonatomic) NSInteger cameraState;

 /*
 @userData:用户数据
 @格式:
 {
 "version":"1.0",
 "user":{}
 }
 @数据量:最多五个
 */
@property (strong, nonatomic) NSMutableDictionary *userData;
@property (copy, nonatomic) NSString *lastUserId;
@property (strong, nonatomic) NSMutableArray *alarmMessageList;
@property (copy, nonatomic) NSString *sipServerIp;
@property (nonatomic) NSInteger port;
@end
@implementation AppData

+ (AppData *)sharedData
{
    static  AppData *sharedInstance = nil ;
    static  dispatch_once_t onceToken;
    dispatch_once (& onceToken, ^ {
        sharedInstance = [[self alloc]init];
        
        sharedInstance.lastUserId = [Utilities persistedInfoFromFolderPath:nil
                                                                  fileName:@"lastLoginUserId.plist"
                                                                       key:@"lastLoginUserId"];
        
        
        
        
        sharedInstance.userData = [Utilities persistedInfoFromFolderPath:sharedInstance.lastUserId
                                                                fileName:[NSString stringWithFormat:@"%@.plist",sharedInstance.lastUserId]
                                                                     key:sharedInstance.lastUserId];
        
        DLog(@"data version : %@  lastUserId : %@ lastUser: %@",
             [sharedInstance.userData objectForKey:@"version"],
             sharedInstance.lastUserId,sharedInstance.userData);
        
        if (!sharedInstance.userData) {
            sharedInstance.userData = [[NSMutableDictionary alloc] init];
            [sharedInstance.userData setObject:@"1.0" forKey:@"version"];
        }
    });
    return sharedInstance;
}

+ (NSString *)serverIp
{
    return [[AppData sharedData] sipServerIp];
}
+ (NSInteger)port
{
    return [[AppData sharedData] port];
}

#pragma mark - State

+ (NSInteger)cameraState
{
    return [[AppData sharedData] cameraState];
}
+ (void)addCameraState:(NSInteger)state
{
    NSInteger currentState = [[AppData sharedData] cameraState];
    currentState |= state;
    [[AppData sharedData] setCameraState:currentState];
}

+ (void)removeCameraState:(NSInteger)state
{
    NSInteger currentState = [[AppData sharedData] cameraState];
    currentState &= ~state;
    [[AppData sharedData] setCameraState:currentState];
}
+ (void)resetCameraState
{
    [[AppData sharedData] setCameraState:0];
}

+ (NSInteger)connectionState
{
    return [[AppData sharedData] connectionState];
}
+ (void)setConnectionState:(NSInteger)state
{
    [[AppData sharedData] setConnectionState:state];
}


#pragma mark - Device

+ (NSDictionary *)devices
{
    
    DLog(@"devices: %@",[[[[AppData sharedData] userData] objectForKey:kUser] devices]);
    
    return [[[[AppData sharedData] userData] objectForKey:kUser] devices];
}

+ (ZMUser *)lastLoginUser
{
    NSMutableDictionary *data = [[AppData sharedData] userData];
    
    DLog(@"lastUser : %@",[data objectForKey:kUser]);
    return [data objectForKey:kUser];
}

+ (NSMutableArray *)alarmMessageList
{
    return [[AppData sharedData] alarmMessageList];
}
+ (void)setAlarmMessageList:(NSMutableArray *)alarmList
{
    [[AppData sharedData] setAlarmMessageList:alarmList];
}

+ (BOOL)addDevice:(ZMDevice *)device
{
    [[[[[AppData sharedData] userData] objectForKey:kUser] devices] setObject:device
                                                                       forKey:device.deviceId];
    
    DLog(@"devices: %@",[[[[AppData sharedData] userData] objectForKey:kUser] devices]);
    
    return [Utilities persistentInfo:[[AppData sharedData] userData]
                          folderPath:[[AppData sharedData] lastUserId]
                            fileName:[NSString stringWithFormat:@"%@.plist",
                                      [AppData sharedData].lastUserId]
                                 key:[AppData sharedData].lastUserId];
    
}

+ (BOOL)saveLastLoginUser:(ZMUser *)lastLoginUser
{
    BOOL success = NO;
    
    do {
        
        ZMUser *localUser = [[Utilities persistedInfoFromFolderPath:[[AppData sharedData] lastUserId]
                                                           fileName:[NSString stringWithFormat:@"%@.plist",lastLoginUser.userId]
                                                                key:lastLoginUser.userId] objectForKey:kUser];
        
        if (localUser) {
            localUser.name = lastLoginUser.name;
            localUser.email = lastLoginUser.email;
            localUser.lastLoginManner = lastLoginUser.lastLoginManner;
            localUser.password = lastLoginUser.password;
            localUser.phone = lastLoginUser.phone;
            localUser.lastLoginTime = [[NSDate date] timeIntervalSince1970];
            
            DLog(@"lastLoginTime : %f",localUser.lastLoginTime);
            
            [[[AppData sharedData] userData] setObject:localUser forKey:kUser];
        }else
        {
            [[[AppData sharedData] userData] setObject:lastLoginUser forKey:kUser];
        }
        
        if (![Utilities persistentInfo:lastLoginUser.userId
                            folderPath:nil
                              fileName:@"lastLoginUserId.plist"
                                   key:@"lastLoginUserId"]){
            break;
        }
        
        if (![Utilities persistentInfo:[[AppData sharedData] userData]
                            folderPath:[[AppData sharedData] lastUserId]
                              fileName:[NSString stringWithFormat:@"%@.plist",
                                        lastLoginUser.userId]
                                   key:lastLoginUser.userId])
        {
            break;
        }
        
        [[AppData sharedData] setLastUserId:lastLoginUser.userId];
        
        success = YES;
        
    } while (0);
    
    return success;
    
}
+ (BOOL)updateImeageToChannel:(NSInteger)channel image:(UIImage *)image
{
    return NO;
    
}
+ (BOOL)updateDevices:(id)data
{
    
    NSMutableDictionary *localDevices = [[[[AppData sharedData] userData] objectForKey:kUser] devices];
    
    DLog(@"devices: %@",[[[[AppData sharedData] userData] objectForKey:kUser] devices]);
    
    NSArray *devData = [data objectForKey:@"data"];
    
    [devData enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        
        NSString *deviceId = [obj objectForKey:@"physical_id"];
        ZMDevice *localDevice = [localDevices objectForKey:deviceId];
        
        NSString * devChannel = [obj objectForKey:@"device_channel"];
        DLog(@"channel count 1: %@",devChannel);
        
        NSInteger channelCount = 1;
        if ([devChannel isEqualToString:@"0"]) {
            channelCount = 1;
        }else
        {
            channelCount = [[obj objectForKey:@"device_channel"] integerValue];
        }
        
        // For test
#if 1
        if ([deviceId isEqualToString:@"1333000134"]) {
            channelCount = 4;
        }
        
#endif
        DLog(@"channel count 2: %d",channelCount);
        
        
        if (localDevice) { // exist
            
            localDevice.channelCount = channelCount;
            localDevice.name = [obj objectForKey:@"device_name"];
        }else
        {
            localDevice = [[ZMDevice alloc] initWithDeviceId:deviceId
                                                    password:@"111111"
                                                  deviceName:[obj objectForKey:@"device_name"]
                                                channelCount:channelCount];
        }
        
        [[[[[AppData sharedData] userData] objectForKey:kUser] devices] setObject:localDevice forKey:deviceId];
    }];
    
    return [Utilities persistentInfo:[[AppData sharedData] userData]
                          folderPath:[[AppData sharedData] lastUserId]
                            fileName:[NSString stringWithFormat:@"%@.plist",
                                      [AppData sharedData].lastUserId]
                                 key:[AppData sharedData].lastUserId];
}
@end
