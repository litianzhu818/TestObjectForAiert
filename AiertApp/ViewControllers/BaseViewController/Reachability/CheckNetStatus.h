//
//  CheckNetStatus.h
//  FindLocationDemo
//
//  Created by Peter Lee on 14-4-16.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SingletonManager.h"
#import "Reachability.h"
#import "NotificationType.h"

@protocol CheckNetStatusDelegate <NSObject>

@required

@optional
-(void)NoNetWork;
-(void)DisconnectNetWork;
-(void)ConnectNetWork;
@end

@interface CheckNetStatus : NSObject

@property (strong, nonatomic) id<CheckNetStatusDelegate> delegate;

Single_interface(CheckNetStatus);
//验证是否可以联网
-(BOOL)getInitNetworkStatus;
//获取前当前的网络状态
-(NetworkStatus)getNowNetWorkStatus;
@end
