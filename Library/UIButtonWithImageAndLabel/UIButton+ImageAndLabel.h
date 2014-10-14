//
//  UIButton+ImageAndLabel.h
//  MyAiertUI
//
//  Created by Peter Lee on 14/9/13.
//  CCopyright (c) 2013年 爱尔特电子有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (ImageAndLabel)

- (void) setImage:(UIImage *)image withTitle:(NSString *)title
     withSpacting:(NSInteger)spacing forState:(UIControlState)stateType;

@end
