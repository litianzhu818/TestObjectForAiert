//
//  AiertUserInfo.h
//  AiertApp
//
//  Created by Peter Lee on 14/9/14.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AiertUserInfo : NSObject<NSCopying,NSCoding>

@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *userPassword;

- (instancetype)initWithUserName:(NSString *)user_name userPassword:(NSString *)user_password;

@end
