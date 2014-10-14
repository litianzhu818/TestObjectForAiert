//
//  LocalNetworkInfo.h
//  爱尔特 Aiert
//
//  Created by Peter Lee on 14/9/13.
//  Copyright (c) 2013年 爱尔特电子有限公司. All rights reserved.
//

@interface LocalNetworkInfo : NSObject
@property (copy, nonatomic) NSString *deviceId;
@property (copy, nonatomic) NSString *mac;
@property (copy, nonatomic) NSString *localIp;
@property (copy, nonatomic) NSString *gateWay;
@property (copy, nonatomic) NSString *subMask;
@end
