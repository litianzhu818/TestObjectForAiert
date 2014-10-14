//
//  NoticeAlertView.h
//  FindLocationDemo
//
//  Created by 李天柱 on 14-4-15.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//
//  自定义显示通知的对话框
//

#import <UIKit/UIKit.h>

typedef enum {
    NoticeAlertViewStyleDefault = 0,
    NoticeAlertViewStyleSecureTextInput,
    NoticeAlertViewStylePlainTextInput,
    NoticeAlertViewStyleLoginAndPasswordInput,
} NoticeAlertViewStyle;

typedef enum {
	NoticeAlertViewPresentationStyleNone = 0,
	NoticeAlertViewPresentationStylePop,
	NoticeAlertViewPresentationStyleFade,
	
	NoticeAlertViewPresentationStyleDefault = NoticeAlertViewPresentationStylePop
} NoticeAlertViewPresentationStyle;

typedef enum {
	NoticeAlertViewDismissalStyleNone = 0,
	NoticeAlertViewDismissalStyleZoomDown,
	NoticeAlertViewDismissalStyleZoomOut,
	NoticeAlertViewDismissalStyleFade,
	NoticeAlertViewDismissalStyleTumble,

	NoticeAlertViewDismissalStyleDefault = NoticeAlertViewDismissalStyleFade
} NoticeAlertViewDismissalStyle;

typedef void (^NoticeAlertViewButtonBlock)();

@interface NoticeAlertView : UIView

@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *message;
@property(nonatomic, readonly, assign, getter = isVisible) BOOL visible;
@property(nonatomic, assign) NoticeAlertViewStyle alertViewStyle;
@property(nonatomic, assign) NoticeAlertViewPresentationStyle presentationStyle;
@property(nonatomic, assign) NoticeAlertViewDismissalStyle dismissalStyle;

+ (void)applySystemAlertAppearance;

- (id)initWithTitle:(NSString *)title message:(NSString *)message;
- (id)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle;

- (void)addButtonWithTitle:(NSString *)title block:(NoticeAlertViewButtonBlock)block;
- (void)setDestructiveButtonTitle:(NSString *)title block:(NoticeAlertViewButtonBlock)block;
- (void)setCancelButtonTitle:(NSString *)title block:(NoticeAlertViewButtonBlock)block;

- (void)show;
- (void)showWithStyle:(NoticeAlertViewPresentationStyle)presentationStyle;
- (void)dismiss;
- (void)dismissWithStyle:(NoticeAlertViewDismissalStyle)dismissalStyle;

- (UITextField *)textFieldAtIndex:(NSInteger)textFieldIndex;

@property(nonatomic, strong) UIImage *backgroundImage UI_APPEARANCE_SELECTOR;
@property(nonatomic, assign) UIEdgeInsets contentInsets UI_APPEARANCE_SELECTOR;

@property(nonatomic, copy) NSDictionary *titleTextAttributes UI_APPEARANCE_SELECTOR;
@property(nonatomic, copy) NSDictionary *messageTextAttributes UI_APPEARANCE_SELECTOR;
@property(nonatomic, copy) NSDictionary *buttonTitleTextAttributes UI_APPEARANCE_SELECTOR;

- (void)setButtonBackgroundImage:(UIImage *)backgroundImage forState:(UIControlState)state UI_APPEARANCE_SELECTOR;
- (UIImage *)buttonBackgroundImageForState:(UIControlState)state UI_APPEARANCE_SELECTOR;

- (void)setCancelButtonBackgroundImage:(UIImage *)backgroundImage forState:(UIControlState)state UI_APPEARANCE_SELECTOR;
- (UIImage *)cancelButtonBackgroundImageForState:(UIControlState)state UI_APPEARANCE_SELECTOR;

- (void)setDestructiveButtonBackgroundImage:(UIImage *)backgroundImage forState:(UIControlState)state UI_APPEARANCE_SELECTOR;
- (UIImage *)destructiveButtonBackgroundImageForState:(UIControlState)state UI_APPEARANCE_SELECTOR;

@end
