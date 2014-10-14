

#import <Foundation/Foundation.h>
#import "ZMUser.h"

@class ZMDevice;
@interface AppData : NSObject

+ (ZMUser *)lastLoginUser;
+ (NSDictionary *)devices;
+ (NSMutableArray *)alarmMessageList;
+ (void)setAlarmMessageList:(NSMutableArray *)alarmList;

+ (NSInteger)cameraState;
+ (void)addCameraState:(NSInteger)state;
+ (void)removeCameraState:(NSInteger)state;
+ (void)resetCameraState;

+ (NSInteger)connectionState;
+ (void)setConnectionState:(NSInteger)state;

+ (NSString *)serverIp;
+ (NSInteger)port;

+ (BOOL)addDevice:(ZMDevice *)device;
+ (BOOL)saveLastLoginUser:(ZMUser *)lastLoginUser;
+ (BOOL)updateImeageToChannel:(NSInteger)channel image:(UIImage *)image;
+ (BOOL)updateDevices:(id)data;
@end
