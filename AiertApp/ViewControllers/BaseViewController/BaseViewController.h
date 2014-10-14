//
//  SuperViewController.h
//  FindLocationDemo
//
//  Created by 李天柱 on 14-4-15.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//
//  自定义父类，用于从消息中心接收消息通知
//

#import <UIKit/UIKit.h>
#import "NotificationType.h"
#import "StatusBar.h"
#import "CheckNetStatus.h"
#import "NotificationView.h"
#import "UICustomAlertView.h"

@interface BaseViewController : UIViewController<NotificationViewDelegate>
@property (strong, nonatomic) NotificationView *netWorkStatusNotice;
@property (strong, nonatomic) UIImageView *defaultImageView;

-(void)initStatusBar;

-(void)getMessageWithNotification:(NSNotification *)messageNotification;
-(void)getRequestMessageNotification:(NSNotification *)messageNotification;
-(void)getControlMessageNotification:(NSNotification *)messageNotification;

-(void)SendMessage:(NSNotification *)notification;

-(void)showMessage:(NSString *)message
             title:(NSString *)title
 cancelButtonTitle:(NSString *)cancelTitle
       cancleBlock:(void (^)(void))cancleBlock;
-(void)showMessage:(NSString *)message
             title:(NSString *)title
 cancelButtonTitle:(NSString *)cancelTitle
       cancleBlock:(void (^)(void))cancleBlock
  otherButtonTitle:(NSString *)otherButtonTitle
        otherBlock:(void (^)(void))otherBlock;

-(BOOL)shouldAutorotate;
-(NSUInteger)supportedInterfaceOrientations;
//-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation;

@end
