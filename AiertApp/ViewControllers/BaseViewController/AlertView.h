//
//  ILSMLAlertView.h
//  MoreLikers
//
//  Created by xiekw on 13-9-9.
//  Copyright (c) 2013年 爱尔特电子有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  AlertViewDelegate;

typedef NS_OPTIONS(NSUInteger, AlertViewStyle) {
    AlertViewStyleDefault = 0,
    AlertViewStyleHorizontally
};

@interface AlertView : UIView

- (id)initWithTitle:(NSString *)title
            message:(NSString *)message
  cancelButtonTitle:(NSString *)cancelButtonTitle
   otherButtonTitle:(NSString *)otherButtonTitle;

- (void)show;

@property (nonatomic, copy) dispatch_block_t leftBlock;
@property (nonatomic, copy) dispatch_block_t rightBlock;
@property (nonatomic, copy) dispatch_block_t dismissBlock;
@property (weak, nonatomic) id<AlertViewDelegate> delegate;
@property (assign, nonatomic) AlertViewStyle alertViewStyle;

@end

@protocol AlertViewDelegate <NSObject>
@optional
- (void)AlertView:(AlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
- (void)AlertViewCancel:(AlertView *)alertView;
- (void)didPresentAlertView:(AlertView *)alertView;  // after animation
- (void)alertView:(AlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;  // after animation
@end


@interface UIImage (colorful)

+ (UIImage *)imageWithColor:(UIColor *)color;

@end