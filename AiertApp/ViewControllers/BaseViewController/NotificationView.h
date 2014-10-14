//
//  NotificationView.h
//  KISSNAPP
//
//  Created by Peter Lee on 14/6/17.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SingletonManager.h"
#import "GradientView.h"

#define kMPNotificationHeight    40.0f
#define kMPNotificationIPadWidth 480.0f
#define RADIANS(deg) ((deg) * M_PI / 180.0f)

@protocol NotificationViewDelegate;

@interface NotificationView : UIView

@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UILabel *detailTextLabel;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *accessoryButton;
@property (nonatomic, assign) id<NotificationViewDelegate> delegate;
@property (assign, nonatomic) BOOL isLoading;

Single_interface(NotificationView);

- (void)showViewWithText:(NSString*)text
                  detail:(NSString*)detail
                   image:(UIImage*)image;
- (void)dissmissNotificationView;
@end


@protocol NotificationViewDelegate <NSObject>
@optional
- (void)deleteNotificationView;
@end