//
//  AiertUserInfo.m
//  AiertApp
//
//  Created by Peter Lee on 14/9/14.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "AiertUserInfo.h"

@implementation AiertUserInfo

- (instancetype)initWithUserName:(NSString *)user_name userPassword:(NSString *)user_password
{
    self = [super init];
    if (self) {
        self.userName = user_name;
        self.userPassword = user_password;
    }
    return self;
}

- (void)dealloc
{
    self.userPassword = nil;
    self.userName = nil;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"User\n{\nuserName=%@\nuserPassword=%@\n}", self.userName,self.userPassword];
}

#pragma mark -
#pragma mark - NSCopying Methods
- (id)copyWithZone:(NSZone *)zone
{
    AiertUserInfo *newInfo = [[[self class] allocWithZone:zone] init];
    
    [newInfo setUserName:self.userName];
    [newInfo setUserPassword:self.userPassword];
    
    return newInfo;
}

#pragma mark -
#pragma mark - NSCoding Methods
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.userName forKey:@"userName"];
    [aCoder encodeObject:self.userPassword forKey:@"userName"];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        
        self.userName = [aDecoder decodeObjectForKey:@"userName"];
        self.userPassword = [aDecoder decodeObjectForKey:@"userName"];
        
    }
    return  self;
    
}


@end
