//
//  LocalNetworkInfo.m
//  Aiert
//
//  Created by Peter Lee on 14/9/13.
//  Copyright (c) 2013年 爱尔特电子有限公司. All rights reserved.
//

#import "LocalNetworkInfo.h"

@implementation LocalNetworkInfo
- (id)init
{
    if (self = [super init]) {
        self.deviceId = @"";
        self.mac = @"";
        self.localIp = @"";
        self.subMask = @"";
        self.gateWay = @"";
    }
    return self;
}
@end
