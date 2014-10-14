

#import <Foundation/Foundation.h>

@interface ZMDevice : NSObject<NSCoding>
@property (copy, nonatomic, readonly) NSString *deviceId;
@property (copy, nonatomic) NSString *password;
@property (copy, nonatomic) NSString *name;
@property (strong, nonatomic) NSMutableDictionary *images;
@property (nonatomic) NSInteger channelCount;

- (id)initWithDeviceId:(NSString *)deviceId
              password:(NSString *)password
            deviceName:(NSString *)deviceName
          channelCount:(NSInteger)channelCount;
@end
