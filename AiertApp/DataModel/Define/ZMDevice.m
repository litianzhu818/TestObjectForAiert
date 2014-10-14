

#import "ZMDevice.h"

#define KEY_DEVICE_ID                 @"DeviceId"
#define KEY_NAME                      @"Name"
#define KEY_PASSWORD                  @"Password"
#define KEY_IMAGES                    @"Images"
#define KEY_CHANNEL_COUNT             @"ChannelCount"

@interface ZMDevice ()
@property (copy, nonatomic) NSString *deviceId;
@end

@implementation ZMDevice
- (id)initWithDeviceId:(NSString *)deviceId
              password:(NSString *)password
            deviceName:(NSString *)deviceName
          channelCount:(NSInteger)channelCount
{
    if (self = [super init]) {
        self.deviceId = deviceId;
        self.name = deviceName;
        self.password = password;
        self.images = [[NSMutableDictionary alloc] init];
        self.channelCount = channelCount;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (NSUInteger)hash
{
    return self.password.hash^self.name.hash;
}

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.deviceId forKey:KEY_DEVICE_ID];
    [aCoder encodeObject:self.password forKey:KEY_PASSWORD];
    [aCoder encodeObject:self.name forKey:KEY_NAME];
    [aCoder encodeObject:self.images forKey:KEY_IMAGES];
    [aCoder encodeInteger:self.channelCount forKey:KEY_CHANNEL_COUNT];
    
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.deviceId = [aDecoder decodeObjectForKey:KEY_DEVICE_ID];
        self.password = [aDecoder decodeObjectForKey:KEY_PASSWORD];
        self.name = [aDecoder decodeObjectForKey:KEY_NAME];
        self.images = [aDecoder decodeObjectForKey:KEY_IMAGES];
        self.channelCount = [aDecoder decodeIntegerForKey:KEY_CHANNEL_COUNT];
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"{deviceId : %@, deviceName : %@, devicePassword: %@, deviceImages: %@, deviceChannel: %d",
            self.deviceId,
            self.name,
            self.password,
            self.images,
            self.channelCount];
}
@end
