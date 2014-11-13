//
//  PlayerTopBar.h
//  AiertApp
//
//  Created by Peter Lee on 14/11/10.
//  Copyright (c) 2014年 爱尔特电子有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayerTopBar : UIView

+ (instancetype)instanceFromNib;

@property (weak, nonatomic) UIButton *allScreenButton;
@property (weak, nonatomic) UIButton *voiceButton;
@property (weak, nonatomic) UIButton *cameraButton;
@property (weak, nonatomic) UIButton *videoButton;
@property (weak, nonatomic) UIButton *qualityButton;
@property (weak, nonatomic) UIButton *button1;
@property (weak, nonatomic) UIButton *button2;
@property (weak, nonatomic) UIButton *button3;
@property (weak, nonatomic) UIButton *button4;

@property (weak, nonatomic) UISlider *voiceSlider;

@end
