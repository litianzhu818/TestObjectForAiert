//
//  NSDictionary+WebInterface.h
//  MyAiertWebInterface
//
//  Created by Peter Lee on 14/9/13.
//  Copyright (c) 2013年 爱尔特电子有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

#define WebInterface_Result         @"result"
#define WebInterface_Addition       @"addition"

@interface NSDictionary (WebInterface)

- (NSString *)webInterfaceResult;
- (NSString *)webInterfaceAddition;

@end
