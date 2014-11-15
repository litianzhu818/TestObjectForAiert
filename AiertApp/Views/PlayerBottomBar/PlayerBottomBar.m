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

- (IBAction)closeAction:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerBottomBar:didClikedOnButtonIndex:)]) {
        [self.delegate playerBottomBar:self didClikedOnButtonIndex:1];
    }
}
- (IBAction)left_rightAction:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerBottomBar:didClikedOnButtonIndex:)]) {
        [self.delegate playerBottomBar:self didClikedOnButtonIndex:2];
    }
}
- (IBAction)up_downAction:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerBottomBar:didClikedOnButtonIndex:)]) {
        [self.delegate playerBottomBar:self didClikedOnButtonIndex:3];
    }
}
- (IBAction)turn_up_downAction:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerBottomBar:didClikedOnButtonIndex:)]) {
        [self.delegate playerBottomBar:self didClikedOnButtonIndex:4];
    }
}
- (IBAction)turn_left_rightAction:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerBottomBar:didClikedOnButtonIndex:)]) {
        [self.delegate playerBottomBar:self didClikedOnButtonIndex:5];
    }
}
@end
