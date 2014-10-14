//
//  AiertUINavigationBar.m
//  AiertApp
//
//  Created by Peter Lee on 14/9/9.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "AiertUINavigationBar.h"

@implementation AiertUINavigationBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)setBackgroundImage:(UIImage *)backgroundImage
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED <= __IPHONE_6_1
    self.backgroundImage = [backgroundImage copy];
    [self setNeedsDisplay];
#else
    [self setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
#endif
}

-(void)drawRect:(CGRect)rect
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED <= __IPHONE_6_1
    if (self.backgroundImage) {
        [self.backgroundImage drawInRect:CGRectMake(0, 0, FRAME_W(self.frame), FRAME_H(self.frame))];
    }
#endif
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
