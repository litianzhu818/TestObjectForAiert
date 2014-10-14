

#import "ZMUser.h"

#define KEY_USER_ID                   @"UserId"
#define KEY_USER_NAME                 @"UserName"
#define KEY_PASSWORD                  @"Password"
#define KEY_PHONE                     @"Phone"
#define KEY_EMAIL                     @"Email"
#define KEY_LOGIN_MANNER              @"LoginManner"
#define KEY_LAST_LOGINTIME            @"LastLoginTime"
#define KEY_DEVICES                   @"Devices"

@interface ZMUser()
@property (copy, nonatomic) NSString *userId;
@end

@implementation ZMUser

- (id)initWithUserId:(NSString *)userId
            password:(NSString *)password
            userName:(NSString *)userName
               email:(NSString *)email
     lastLoginManner:(NSInteger)manner
{
    if (self = [super init]) {
        self.userId = userId;
        self.name = userName;
        self.password = password;
        self.phone = @"";
        self.email = email;
        self.lastLoginManner = manner;
        self.devices = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (NSUInteger)hash
{
    return self.password.hash^self.name.hash^self.email.hash;
}

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.userId forKey:KEY_USER_ID];
    [aCoder encodeObject:self.password forKey:KEY_PASSWORD];
    [aCoder encodeObject:self.name forKey:KEY_USER_NAME];
    [aCoder encodeObject:self.phone forKey:KEY_PHONE];
    [aCoder encodeObject:self.email forKey:KEY_EMAIL];
    [aCoder encodeInteger:self.lastLoginManner forKey:KEY_LOGIN_MANNER];
    [aCoder encodeFloat:self.lastLoginTime forKey:KEY_LAST_LOGINTIME];
    [aCoder encodeObject:self.devices forKey:KEY_DEVICES];
    
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.userId = [aDecoder decodeObjectForKey:KEY_USER_ID];
        self.password = [aDecoder decodeObjectForKey:KEY_PASSWORD];
        self.name = [aDecoder decodeObjectForKey:KEY_USER_NAME];
        self.phone = [aDecoder decodeObjectForKey:KEY_PHONE];
        self.email = [aDecoder decodeObjectForKey:KEY_EMAIL];
        self.lastLoginManner = [aDecoder decodeIntegerForKey:KEY_LOGIN_MANNER];
        self.lastLoginTime = [aDecoder decodeFloatForKey:KEY_LAST_LOGINTIME];
        self.devices = [aDecoder decodeObjectForKey:KEY_DEVICES];
    }
    return self;
}

@end