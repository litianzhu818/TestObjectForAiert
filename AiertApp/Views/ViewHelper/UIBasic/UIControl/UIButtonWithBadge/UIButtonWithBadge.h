//
//  UIButtonWithBadge.h
//  MyAiertUI
//
//  Created by Peter Lee on 14/9/13.
//  Copyright (c) 2013年 爱尔特电子有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//Badge Alignment Type
typedef NS_ENUM(NSInteger, UIButtonWithBadgeAlignment) {
    UIButtonWithBadgeAlignmentMiddle = 0,
    UIButtonWithBadgeAlignmentStart,
    UIButtonWithBadgeAlignmentEnd
};

@interface UIButtonWithBadge : UIButton
{
    NSString *badgeMessage;
    UIButtonWithBadgeAlignment badgeAlignmentHorizontal;
    UIButtonWithBadgeAlignment badgeAlignmentVertical;
    CGPoint badgeLocationOffset;
    
    CGFloat badgeRadius;
    CGFloat badgeBorderWidth;
    
    NSString *badgeFontName;
    CGFloat badgeFontSize;
    
    UIColor *badgeBackgroundColor;
    UIColor *badgeTextColor;
    
    //Inner
    CALayer *badgeLayer;
}

@property (nonatomic, strong) NSString *badgeMessage;       //Default "", Hide badge by setting ""
@property (nonatomic) UIButtonWithBadgeAlignment badgeAlignmentHorizontal;  //Default End
@property (nonatomic) UIButtonWithBadgeAlignment badgeAlignmentVertical;    //Default Start
@property (nonatomic) CGPoint badgeLocationOffset;          //Default (0,0)

@property (nonatomic) CGFloat badgeRadius;              //R of Circle in px, Default 10
@property (nonatomic) CGFloat badgeBorderWidth;         //Border between Circle and text in px, Default 3

@property (nonatomic, strong) NSString *badgeFontName;  //Font name, default @"Helvetica"
@property (nonatomic) CGFloat badgeFontSize;            //Font size, default 12.0f

@property (nonatomic, strong) UIColor *badgeBackgroundColor;    //
@property (nonatomic, strong) UIColor *badgeTextColor;          //

@end
