//
//  NSDictionary+WebInterface.m
//  MyAiertWebInterface
//
//  Created by Peter Lee on 14/9/13.
//  Copyright (c) 2013年 爱尔特电子有限公司. All rights reserved.
//

#import "NSDictionary+WebInterface.h"

@implementation NSDictionary (WebInterface)

- (NSString *)webInterfaceResult
{
    return [self objectForKey:WebInterface_Result];
}

- (NSString *)webInterfaceAddition
{
    return [self objectForKey:WebInterface_Addition];
}

@end
