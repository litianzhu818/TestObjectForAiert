//
//  CXAlertBackgroundWindow.m
//  CXAlertViewDemo
//
//  Created by Peter Lee on 14/9/13.
//  Copyright (c) 2013年 爱尔特电子有限公司. All rights reserved.
//

#import "CXAlertBackgroundWindow.h"

const UIWindowLevel UIWindowLevelCXAlert = 1999.0;
const UIWindowLevel UIWindowLevelCXAlertBackground = 1998.0;

@implementation CXAlertBackgroundWindow

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.opaque = NO;
        self.windowLevel = UIWindowLevelAlert - 1;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [[UIColor colorWithWhite:0 alpha:0.5] set];
    CGContextFillRect(context, self.bounds);
}

@end
