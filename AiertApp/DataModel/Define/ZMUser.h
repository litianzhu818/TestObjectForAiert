

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, LastLoginManner)
{
    LastLoginMannerEmail,
    LastLoginMannerUserName,
    LastLoginMannerPhone,
    LastLoginMannerOther
};

@interface ZMUser : NSObject<NSCoding>
@property (copy, nonatomic, readonly) NSString *userId;
@property (copy, nonatomic) NSString *password;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *email;
@property (copy, nonatomic) NSString *phone;
@property (nonatomic) LastLoginManner lastLoginManner;                // 最后一次登录的方式 0:emai 1:userName 2:other
@property (strong, nonatomic) NSMutableDictionary *devices;
@property (nonatomic) NSTimeInterval lastLoginTime;
- (id)initWithUserId:(NSString *)userId
            password:(NSString *)password
            userName:(NSString *)userName
               email:(NSString *)email
     lastLoginManner:(NSInteger)manner;
@end
