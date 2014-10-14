//
//  UIButtonWithBadge.m
//  MyAiertUI
//
//  Created by Peter Lee on 14/9/13.
//  Copyright (c) 2013年 爱尔特电子有限公司. All rights reserved.
//

#import "UIButtonWithBadge.h"

//Size
#define kUIButtonWithBadgeDefaultCornerRadius  6
#define kUIButtonWithBadgeDefaultBorderWidth   1
#define kMainScreenScale [[UIScreen mainScreen] scale]

//Color
#define kUIButtonWithBadgeDefaultBackgroundColor [UIColor colorWithRed:254/255.0f green:145/255.0f blue:16/255.0f alpha:1.0f]
#define kUIButtonWithBadgeDefaultTextColor [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1.0f]

//Font
#define kUIButtonWithBadgeDefaultFont  @"Helvetica"
#define kUIButtonWithBadgeDefaultFontSize  8.5f
 
@implementation UIButtonWithBadge

@synthesize badgeAlignmentHorizontal;
@synthesize badgeLocationOffset;
@synthesize badgeAlignmentVertical;
@synthesize badgeMessage;

@synthesize badgeBackgroundColor;
@synthesize badgeBorderWidth;
@synthesize badgeFontName;
@synthesize badgeFontSize;
@synthesize badgeRadius;
@synthesize badgeTextColor;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        [self resetDefaultValue];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self resetDefaultValue];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self resetDefaultValue];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self redrawLayer];
}

- (void)setBadgeAlignmentHorizontal:(UIButtonWithBadgeAlignment)aBadgeAlignmentHorizontal
{
    badgeAlignmentHorizontal = aBadgeAlignmentHorizontal;
    [self redrawLayer];
}

- (void)setBadgeAlignmentVertical:(UIButtonWithBadgeAlignment)aBadgeAlignmentVertical
{
    badgeAlignmentVertical = aBadgeAlignmentVertical;
    [self redrawLayer];
}

- (void)setBadgeLocationOffset:(CGPoint)aBadgeLocationOffset
{
    badgeLocationOffset = aBadgeLocationOffset;
    [self redrawLayer];
}

- (void)setBadgeMessage:(NSString *)aBadgeMessage
{
    badgeMessage = aBadgeMessage;
    [self redrawLayer];
}

- (void)setBadgeBorderWidth:(CGFloat)aBadgeBorderWidth
{
    badgeBorderWidth = aBadgeBorderWidth;
    [self redrawLayer];
}

- (void)setBadgeFontName:(NSString *)aBadgeFontName
{
    badgeFontName = aBadgeFontName;
    [self redrawLayer];
}

- (void)setBadgeFontSize:(CGFloat)aBadgeFontSize
{
    badgeFontSize = aBadgeFontSize;
    [self redrawLayer];
}

- (void)setBadgeRadius:(CGFloat)aBadgeRadius
{
    badgeRadius = aBadgeRadius;
    [self redrawLayer];
}

- (void)setBadgeTextColor:(UIColor *)aBadgeTextColor
{
    badgeTextColor = aBadgeTextColor;
    [self redrawLayer];
}

- (void)setBadgeBackgroundColor:(UIColor *)aBadgeBackgroundColor
{
    badgeBackgroundColor = aBadgeBackgroundColor;
    [self redrawLayer];
}

- (void)resetDefaultValue
{
    badgeMessage = @"";
    badgeAlignmentHorizontal = UIButtonWithBadgeAlignmentEnd;
    badgeAlignmentVertical = UIButtonWithBadgeAlignmentStart;
    badgeLocationOffset = CGPointMake(0.0f, 0.0f);
    
    badgeBackgroundColor = kUIButtonWithBadgeDefaultBackgroundColor;
    badgeBorderWidth = kUIButtonWithBadgeDefaultBorderWidth;
    badgeFontName = kUIButtonWithBadgeDefaultFont;
    badgeFontSize = kUIButtonWithBadgeDefaultFontSize;
    badgeRadius = kUIButtonWithBadgeDefaultCornerRadius;
    badgeTextColor = kUIButtonWithBadgeDefaultTextColor;
}

- (void)redrawLayer
{
    if (badgeLayer != nil) {
        [badgeLayer removeFromSuperlayer];
    }
    badgeLayer = [self buildBadgeLayer];
    [self.layer insertSublayer:badgeLayer atIndex:1];
}

- (CALayer *)buildBadgeLayer
{
    CALayer *layer = [CALayer layer];
    layer.contentsScale = kMainScreenScale;
    layer.backgroundColor = [UIColor clearColor].CGColor;
    
    if ([badgeMessage length] > 0) {
        CGSize textSize = [badgeMessage sizeWithFont:[UIFont fontWithName:badgeFontName size:badgeFontSize]
                                         constrainedToSize:CGSizeMake(MAXFLOAT, 30)];
        
        CGSize mainSize = CGSizeMake(
                                     MAX(badgeRadius * 2,
                                         textSize.width + 2 * badgeBorderWidth),
                                     badgeRadius * 2);
        CGFloat x = 0;
        switch (badgeAlignmentHorizontal) {
            case UIButtonWithBadgeAlignmentStart:
                x= 0 + badgeLocationOffset.x;
                break;
            case UIButtonWithBadgeAlignmentMiddle:
                x= self.frame.size.width / 2 + badgeLocationOffset.x;
                break;
            case UIButtonWithBadgeAlignmentEnd:
                x= self.frame.size.width + badgeLocationOffset.x;
                break;
            default:
                break;
        }
        
        CGFloat y = 0;
        switch (badgeAlignmentVertical) {
            case UIButtonWithBadgeAlignmentStart:
                y= 0 + badgeLocationOffset.y;
                break;
            case UIButtonWithBadgeAlignmentMiddle:
                y= self.frame.size.height / 2 + badgeLocationOffset.y;
                break;
            case UIButtonWithBadgeAlignmentEnd:
                y= self.frame.size.height + badgeLocationOffset.y;
                break;
            default:
                break;
        }        
        
        //
        layer.frame = CGRectMake(x - mainSize.width / 2, y - mainSize.height / 2,
                                 mainSize.width, mainSize.height);
        layer.cornerRadius = badgeRadius;
        layer.backgroundColor = badgeBackgroundColor.CGColor;
        layer.borderColor = badgeBackgroundColor.CGColor;
        layer.borderWidth = 1;
        
        CATextLayer *tl = [CATextLayer layer];
        tl.contentsScale = kMainScreenScale;
        tl.font = CFBridgingRetain(badgeFontName);
        tl.fontSize = badgeFontSize;
        tl.backgroundColor = [UIColor clearColor].CGColor;
        tl.foregroundColor = badgeTextColor.CGColor;
        tl.string = badgeMessage;
        tl.frame = CGRectMake((mainSize.width - textSize.width)/2,
                              (mainSize.height - textSize.height)/2,
                              textSize.width * 2, textSize.height * 2);
        [layer addSublayer:tl];
    }
    
    return layer;
}

@end
