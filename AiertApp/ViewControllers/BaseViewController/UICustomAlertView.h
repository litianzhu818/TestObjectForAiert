//
//  UICustomAlertView.h
//  KISSNAPP
//
//  Created by Peter Lee on 14/6/20.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CancelBtnBlock)(void);
typedef void (^OtherBtnBlock)(void);

@interface UICustomAlertView : UIAlertView<UIAlertViewDelegate>

@property (strong, nonatomic) CancelBtnBlock cancelBlock;
@property (strong, nonatomic) OtherBtnBlock otherBlock;

- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
            cancelButtonTitle:(NSString *)cancelTitle
                  cancleBlock:(void (^)(void))cancleBlock;

- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
            cancelButtonTitle:(NSString *)cancelTitle
                  cancleBlock:(void (^)(void))cancleBlock
             otherButtonTitle:(NSString *)otherButtonTitle
                   otherBlock:(void (^)(void))otherBlock;

@end
