//
//  UIButton+ImageAndLabel.m
//  MyAiertUI
//
//  Created by Peter Lee on 14/9/13.
//  Copyright (c) 2013年 爱尔特电子有限公司. All rights reserved.
//

#import "UIButton+ImageAndLabel.h"

@implementation UIButton (ImageAndLabel)

- (void) setImage:(UIImage *)image withTitle:(NSString *)title
     withSpacting:(NSInteger)spacing forState:(UIControlState)stateType
{
    CGSize titleSize = [title sizeWithFont:self.titleLabel.font];
    [self.imageView setContentMode:UIViewContentModeCenter];
    [self setImageEdgeInsets:UIEdgeInsetsMake(-titleSize.height - spacing/2,
                                              0.0,
                                              0.0, -titleSize.width)];
    [self setImage:image forState:stateType];
    //
    [self.titleLabel setContentMode:UIViewContentModeCenter];
    [self.titleLabel setBackgroundColor:[UIColor clearColor]];
    [self setTitleEdgeInsets:UIEdgeInsetsMake(image.size.height + spacing/2,
                                              -image.size.width,
                                              0.0,
                                              0.0)];
    [self setTitle:title forState:stateType];
}

@end
