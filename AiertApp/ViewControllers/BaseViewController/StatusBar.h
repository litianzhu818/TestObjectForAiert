//
//  LTZStatusBar.h
//
//  Created by 李天柱 on 2/27/13.
//  Copyright afusion. All rights reserved.
//
//  用于在状态栏显示
//

#import <UIKit/UIKit.h>

@interface StatusBar : UIView

+ (void)showWithStatus:(NSString*)status;
+ (void)showErrorWithStatus:(NSString*)status;
+ (void)showSuccessWithStatus:(NSString*)status;
+ (void)dismiss;

@end
