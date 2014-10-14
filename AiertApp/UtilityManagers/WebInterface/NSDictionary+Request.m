

#import "NSDictionary+Request.h"

@implementation NSDictionary (Request)

- (NSString *)strResult
{
    return [self objectForKey:@"result"];
}

- (NSString *)strAddition
{
    return [self objectForKey:@"addition"];
}

- (NSArray *)arrData
{
    return [self objectForKey:@"data"];
}

- (NSDictionary *)dicLoginData
{
    return [self objectForKey:@"data"];
}

- (NSString *)strPhysical_id
{
    return [self objectForKey:@"physical_id"];
}

- (NSString *)strdevice_bind
{
    return [self objectForKey:@"device_bind"];
}

- (NSString *)strdevice_channel
{
    return [self objectForKey:@"device_channel"];
}

- (NSString *)strdevice_model
{
    return [self objectForKey:@"device_model"];
}

- (NSString *)strdevice_name
{
    return [self objectForKey:@"device_name"];
}

- (NSString *)strdevice_online
{
    return [self objectForKey:@"device_online"];
}

- (NSString *)strdevice_public
{
    return [self objectForKey:@"device_public"];
}

- (NSString *)strdevice_scene
{
    return [self objectForKey:@"device_scene"];
}

- (NSString *)strdevice_type
{
    return [self objectForKey:@"device_type"];
}

- (NSString *)strdevice_version
{
    return [self objectForKey:@"device_version"];
}

- (NSString *)strid
{
    return [self objectForKey:@"id"];
}

- (NSString *)struser_id
{
    return [self objectForKey:@"user_id"];
}

- (NSString *)strDevice_Picture
{
    return [self objectForKey:@"device_picture"];
}

- (NSString *)strUser_Name
{
    return [self objectForKey:@"username"];
}

- (NSString *)strdevice_alarm
{
    return [self objectForKey:@"device_alarm"];
}

@end
