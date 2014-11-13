//
//  PlayerBottomBar.m
//  AiertApp
//
//  Created by Peter Lee on 14/11/10.
//  Copyright (c) 2014年 爱尔特电子有限公司. All rights reserved.
//

#import "PlayerBottomBar.h"

@implementation PlayerBottomBar

+ (instancetype)instanceFromNib
{
    return [[[NSBundle mainBundle] loadNibNamed:@"PlayerBottomBar" owner:self options:nil] lastObject];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initUI];
}

- (void)initUI
{
    self.scrollView.frame = CGRectMake(0, 0, VIEW_W(self), VIEW_H(self));
    self.scrollView.contentSize = self.frame.size;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    self.scrollView.frame = frame;
    self.scrollView.contentSize = self.frame.size;
}

/*
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //your code here
    
    [super touchesBegan:touches withEvent:event];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //your code here
    
    // check touch up inside
    if ([self superview]) {
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:[self superview]];
        //TODO:这里可以将触摸范围扩大，便于操作，例如：
         CGRect validTouchArea = CGRectMake((self.frame.origin.x - 10),
         (self.frame.origin.y - 10),
         (self.frame.size.width + 10),
         (self.frame.size.height + 10));
        if (CGRectContainsPoint(validTouchArea, point)) {
            //your code here
        }
    }
    
    [super touchesEnded:touches withEvent:event];
}
*/

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
