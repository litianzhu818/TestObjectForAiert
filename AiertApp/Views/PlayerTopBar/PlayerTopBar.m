//
//  PlayerTopBar.m
//  AiertApp
//
//  Created by Peter Lee on 14/11/10.
//  Copyright (c) 2014年 爱尔特电子有限公司. All rights reserved.
//

#import "PlayerTopBar.h"

@implementation PlayerTopBar

+ (instancetype)instanceFromNib
{
    return [[[NSBundle mainBundle] loadNibNamed:@"PlayerTopBar" owner:self options:nil] lastObject];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (IBAction)allScreenButtonCliked:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerTopBar:didClikedOnButtonIndex:)]) {
        [self.delegate playerTopBar:self didClikedOnButtonIndex:1];
    }
}
- (IBAction)voiceButtonCliked:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerTopBar:didClikedOnButtonIndex:)]) {
        [self.delegate playerTopBar:self didClikedOnButtonIndex:2];
    }
}
- (IBAction)cameraButtonCliked:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerTopBar:didClikedOnButtonIndex:)]) {
        [self.delegate playerTopBar:self didClikedOnButtonIndex:3];
    }
}
- (IBAction)videoButtonCliked:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerTopBar:didClikedOnButtonIndex:)]) {
        [self.delegate playerTopBar:self didClikedOnButtonIndex:4];
    }
}
- (IBAction)qualityButtonCliked:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerTopBar:didClikedOnButtonIndex:)]) {
        [self.delegate playerTopBar:self didClikedOnButtonIndex:5];
    }
}
- (IBAction)button1Cliked:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerTopBar:didClikedOnButtonIndex:)]) {
        [self.delegate playerTopBar:self didClikedOnButtonIndex:6];
    }
}
- (IBAction)button2Cliked:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerTopBar:didClikedOnButtonIndex:)]) {
        [self.delegate playerTopBar:self didClikedOnButtonIndex:7];
    }
}
- (IBAction)button3Cliked:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerTopBar:didClikedOnButtonIndex:)]) {
        [self.delegate playerTopBar:self didClikedOnButtonIndex:8];
    }
}
- (IBAction)button4Cliked:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerTopBar:didClikedOnButtonIndex:)]) {
        [self.delegate playerTopBar:self didClikedOnButtonIndex:9];
    }
}
- (IBAction)voiceSliderChanged:(id)sender
{
    UISlider *slider = (UISlider *)sender;
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerTopBar:didChangedVoiceValue:)]) {
        [self.delegate playerTopBar:self didChangedVoiceValue:[slider value]];
    }
}
@end
