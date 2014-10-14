//
//  ILSMLAlertView.m
//  MoreLikers
//
//  Created by Peter Lee on 14/9/13.
//  Copyright (c) 2013年 爱尔特电子有限公司. All rights reserved.
//

#import "AlertView.h"
#import <QuartzCore/QuartzCore.h>


#define AlertWidth 245.0f
#define AlertHeight 160.0f

#define TitleYOffset 15.0f
#define TitleHeight 25.0f

#define ContentOffset 30.0f
#define BetweenLabelOffset 20.0f

#define SingleButtonWidth 160.0f
#define CoupleButtonWidth 107.0f
#define ButtonHeight 40.0f
#define ButtonBottomOffset 10.0f


@interface AlertView ()
{
    BOOL _leftLeave;
}

@property (nonatomic, strong) UILabel *alertTitleLabel;
@property (nonatomic, strong) UILabel *alertContentLabel;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *otherButton;
@property (nonatomic, strong) UIView *backImageView;


@end

@implementation AlertView

+ (CGFloat)alertWidth
{
    return AlertWidth;
}

+ (CGFloat)alertHeight
{
    return AlertHeight;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithTitle:(NSString *)title
            message:(NSString *)message
    cancelButtonTitle:(NSString *)cancelButtonTitle
   otherButtonTitle:(NSString *)otherButtonTitle
{
    if (self = [super init]) {
        self.layer.cornerRadius = 5.0;
        self.backgroundColor = [UIColor whiteColor];
        self.alertTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, TitleYOffset, AlertWidth, TitleHeight)];
        self.alertTitleLabel.font = [UIFont boldSystemFontOfSize:20.0f];
        self.alertTitleLabel.textColor = [UIColor colorWithRed:56.0/255.0 green:64.0/255.0 blue:71.0/255.0 alpha:1];
        [self addSubview:self.alertTitleLabel];
        
        CGFloat contentLabelWidth = AlertWidth - 16;
        self.alertContentLabel = [[UILabel alloc] initWithFrame:CGRectMake((AlertWidth - contentLabelWidth) * 0.5, CGRectGetMaxY(self.alertTitleLabel.frame), contentLabelWidth, 60)];
        self.alertContentLabel.numberOfLines = 0;
        self.alertContentLabel.textAlignment = self.alertTitleLabel.textAlignment = NSTextAlignmentCenter;
        self.alertContentLabel.textColor = [UIColor colorWithRed:127.0/255.0 green:127.0/255.0 blue:127.0/255.0 alpha:1];
        self.alertContentLabel.font = [UIFont systemFontOfSize:15.0f];
        [self addSubview:self.alertContentLabel];
        
        CGRect cancelButtonFrame;
        CGRect otherButtonFrame;
        
        if (!otherButtonTitle) {
            otherButtonFrame = CGRectMake((AlertWidth - 2 * CoupleButtonWidth - ButtonBottomOffset) * 0.5, AlertHeight - ButtonBottomOffset - ButtonHeight, AlertWidth - (AlertWidth - 2 * CoupleButtonWidth - ButtonBottomOffset), ButtonHeight);
            
            self.otherButton = [UIButton buttonWithType:UIButtonTypeCustom];
            self.otherButton.frame = otherButtonFrame;
            
        }else {
            cancelButtonFrame = CGRectMake((AlertWidth - 2 * CoupleButtonWidth - ButtonBottomOffset) * 0.5, AlertHeight - ButtonBottomOffset - ButtonHeight, CoupleButtonWidth, ButtonHeight);
            otherButtonFrame = CGRectMake(CGRectGetMaxX(cancelButtonFrame) + ButtonBottomOffset, AlertHeight - ButtonBottomOffset - ButtonHeight, CoupleButtonWidth, ButtonHeight);
            self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
            self.otherButton = [UIButton buttonWithType:UIButtonTypeCustom];
            self.cancelButton.frame = cancelButtonFrame;
            self.otherButton.frame = otherButtonFrame;
        }
        
        [self.otherButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:87.0/255.0 green:135.0/255.0 blue:173.0/255.0 alpha:1]] forState:UIControlStateNormal];
        [self.cancelButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:227.0/255.0 green:100.0/255.0 blue:83.0/255.0 alpha:1]] forState:UIControlStateNormal];
        [self.otherButton setTitle:cancelButtonTitle forState:UIControlStateNormal];
        [self.cancelButton setTitle:otherButtonTitle forState:UIControlStateNormal];
        self.cancelButton.titleLabel.font = self.otherButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [self.cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.otherButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        [self.cancelButton addTarget:self action:@selector(otherButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.otherButton addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        self.cancelButton.layer.masksToBounds = self.otherButton.layer.masksToBounds = YES;
        self.cancelButton.layer.cornerRadius = self.otherButton.layer.cornerRadius = 3.0;
        if(cancelButtonTitle && ![cancelButtonTitle isEqualToString:@""]){
            [self addSubview:self.cancelButton];
            [self addSubview:self.otherButton];
        }else{
            self.alertContentLabel.frame  = CGRectMake((AlertWidth - contentLabelWidth) * 0.5, CGRectGetMaxY(self.alertTitleLabel.frame), contentLabelWidth, 100);
        }
        
        self.alertTitleLabel.text = title;
        self.alertContentLabel.text = message;
        
        UIButton *xButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [xButton setImage:[UIImage imageNamed:@"btn_close_normal.png"] forState:UIControlStateNormal];
        [xButton setImage:[UIImage imageNamed:@"btn_close_selected.png"] forState:UIControlStateHighlighted];
        xButton.frame = CGRectMake(AlertWidth - 32, 0, 32, 32);
        [self addSubview:xButton];
        [xButton addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        self.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    }
    return self;

}

- (void)cancelButtonClicked:(id)sender
{
    _leftLeave = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(AlertView:clickedButtonAtIndex:)]) {
        [self.delegate AlertView:self clickedButtonAtIndex:0];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(AlertViewCancel:)]) {
        [self.delegate AlertViewCancel:self];
    }
    [self dismissAlertWithButtonId:0];
    if (self.leftBlock) {
        self.leftBlock();
    }
}

- (void)otherButtonClicked:(id)sender
{
    _leftLeave = NO;
    if (self.delegate && [self.delegate respondsToSelector:@selector(AlertView:clickedButtonAtIndex:)]) {
        [self.delegate AlertView:self clickedButtonAtIndex:1];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(AlertViewCancel:)]) {
        [self.delegate AlertViewCancel:self];
    }
    [self dismissAlertWithButtonId:1];
    if (self.rightBlock) {
        self.rightBlock();
    }
}

- (void)show
{
    UIViewController *topVC = [self appRootViewController];
    if (AlertViewStyleHorizontally == _alertViewStyle) {
        self.frame = CGRectMake( - AlertWidth, (CGRectGetHeight(topVC.view.bounds) - AlertHeight) * 0.5, AlertWidth, AlertHeight);
    }else{
        self.frame = CGRectMake((CGRectGetWidth(topVC.view.bounds) - AlertWidth) * 0.5, - AlertHeight - 30, AlertWidth, AlertHeight);
    }
    [topVC.view addSubview:self];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didPresentAlertView:)]) {
        [self.delegate didPresentAlertView:self];
    }
}

- (void)dismissAlertWithButtonId:(NSUInteger)index
{
    [self removeFromSuperview];
    if (self.delegate && [self.delegate respondsToSelector:@selector(alertView:didDismissWithButtonIndex:)]) {
        [self.delegate alertView:self didDismissWithButtonIndex:index];
    }
    if (self.dismissBlock) {
        self.dismissBlock();
    }
}

- (UIViewController *)appRootViewController
{
    UIViewController *appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *topVC = appRootVC;
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    return topVC;
}


- (void)removeFromSuperview
{
    [self.backImageView removeFromSuperview];
    self.backImageView = nil;
    CGRect afterFrame;
    NSTimeInterval delay;
    UIViewController *topVC = [self appRootViewController];
    if (AlertViewStyleHorizontally == _alertViewStyle) {
        delay = 0.2f;
        afterFrame = CGRectMake(CGRectGetWidth(topVC.view.bounds), (CGRectGetHeight(topVC.view.bounds) - AlertHeight) * 0.5, AlertWidth, AlertHeight);
    }else{
        afterFrame = CGRectMake((CGRectGetWidth(topVC.view.bounds) - AlertWidth) * 0.5, CGRectGetHeight(topVC.view.bounds), AlertWidth, AlertHeight);
        delay = 0.35f;
    }
    [UIView animateWithDuration:delay delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.frame = afterFrame;
        if (AlertViewStyleHorizontally != _alertViewStyle) {
            if (_leftLeave) {
                self.transform = CGAffineTransformMakeRotation(-M_1_PI / 1.5);
            }else {
                self.transform = CGAffineTransformMakeRotation(M_1_PI / 1.5);
            }
        }
    } completion:^(BOOL finished) {
        [super removeFromSuperview];
    }];
    
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (newSuperview == nil) {
        return;
    }
    UIViewController *topVC = [self appRootViewController];

    if (!self.backImageView) {
        self.backImageView = [[UIView alloc] initWithFrame:topVC.view.bounds];
        self.backImageView.backgroundColor = [UIColor blackColor];
        self.backImageView.alpha = 0.6f;
        self.backImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    [topVC.view addSubview:self.backImageView];
    CGRect afterFrame;
    NSTimeInterval delay;
    if (AlertViewStyleHorizontally == _alertViewStyle) {
        delay = 0.2f;
        afterFrame = CGRectMake((CGRectGetWidth(topVC.view.bounds) - AlertWidth) * 0.5, (CGRectGetHeight(topVC.view.bounds) - AlertHeight) * 0.5, AlertWidth, AlertHeight);
    }else{
        delay = 0.35f;
        afterFrame = CGRectMake((CGRectGetWidth(topVC.view.bounds) - AlertWidth) * 0.5, (CGRectGetHeight(topVC.view.bounds) - AlertHeight) * 0.5, AlertWidth, AlertHeight);
        self.transform = CGAffineTransformMakeRotation(M_1_PI / 1.5);
    }
    [UIView animateWithDuration:delay delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        if (AlertViewStyleHorizontally != _alertViewStyle) {
            self.transform = CGAffineTransformMakeRotation(0);
        }
        self.frame = afterFrame;
    } completion:^(BOOL finished) {
    }];
    [super willMoveToSuperview:newSuperview];
}

@end

@implementation UIImage (colorful)

+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
