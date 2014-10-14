//
//  UICustomAlertView.m
//  KISSNAPP
//
//  Created by Peter Lee on 14/6/20.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "UICustomAlertView.h"

@implementation UICustomAlertView

- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
            cancelButtonTitle:(NSString *)cancelTitle
                  cancleBlock:(void (^)(void))cancleBlock
             otherButtonTitle:(NSString *)otherButtonTitle
                   otherBlock:(void (^)(void))otherBlock
{
    self = [super initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelTitle otherButtonTitles:otherButtonTitle, nil];
    if (self) {
        self.delegate = self;
        [self setCancelBlock:cancleBlock];
        [self setOtherBlock:otherBlock];
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
            cancelButtonTitle:(NSString *)cancelTitle
                  cancleBlock:(void (^)(void))cancleBlock
{
    self = [super initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelTitle otherButtonTitles:nil, nil];
    if (self) {
        self.delegate = self;
        [self setCancelBlock:cancleBlock];
    }
    return self;
}



#pragma mark -
#pragma mark - UIAlertViewDelegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            self.cancelBlock();
            break;
        case 1:
            self.otherBlock();
        default:
            break;
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
