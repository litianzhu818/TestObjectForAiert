//
//  AiertHeaderView.m
//  AiertApp
//
//  Created by Peter Lee on 14/9/11.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "AiertHeaderView.h"

@interface AiertHeaderView ()

@property (nonatomic, strong) CABasicAnimation *animation;

@end

@implementation AiertHeaderView

-(void)drawRect:(CGRect)rect
{
    self.layer.cornerRadius = 6.0f;
    self.layer.borderWidth = 0.2f;
    self.layer.borderColor = [self backgroundColor].CGColor;
    self.layer.masksToBounds = YES;
    
    [self.cameraImageView setImage:PNG_NAME(@"5")];
    [self.imageView setImage:PNG_NAME(@"1")];
    [self.refreshButton setTintColor:[UIColor clearColor]];
    [self.refreshButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.refreshButton setBackgroundImage:PNG_NAME(@"refresh_btn") forState:UIControlStateNormal];
    [self.refreshButton setTitle:@"刷新" forState:UIControlStateNormal];
    [self.refreshButton setContentMode:UIViewContentModeCenter];
    
    [self iniAanimation];
}

-(void)iniAanimation
{
    _animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    _animation.fromValue = @(0);
    _animation.toValue = @(2*M_PI);
    _animation.duration = .8f;
    _animation.repeatCount = HUGE_VALF;
    _animation.removedOnCompletion = NO;
}

-(IBAction)clikedOnRefreshButton:(id)sender
{
    [self.refreshButton setHidden:YES];
    [self.imageView setHidden:NO];
    
    
    [self.imageView.layer addAnimation:self.animation forKey:@"keyFrameAnimation"];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(clikedRefreshButtonOnAiertHeaderView:)]) {
        [self.delegate clikedRefreshButtonOnAiertHeaderView:self];
    }
}

-(void)stopRefreshing
{
    [self.imageView.layer removeAllAnimations];
    
    [self.imageView setHidden:YES];
    [self.refreshButton setHidden:NO];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.alpha = 0.5f;
    [super touchesBegan:touches withEvent:event];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // check touch up inside
    if ([self superview]) {
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:[self superview]];
        
        CGRect validTouchArea = CGRectMake((self.frame.origin.x - MARGIN_WIDTH),
                                           (self.frame.origin.y - MARGIN_WIDTH),
                                           (self.frame.size.width + MARGIN_WIDTH),
                                           (self.frame.size.height + MARGIN_WIDTH));
        if (CGRectContainsPoint(validTouchArea, point)) {
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(clikedOnAiertHeaderView:)]) {
                [self.delegate clikedOnAiertHeaderView:self];
            }
        }
    }
    self.alpha = 1.0f;
    [super touchesEnded:touches withEvent:event];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
