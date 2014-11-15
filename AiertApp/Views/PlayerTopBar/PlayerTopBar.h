//
//  PlayerTopBar.h
//  AiertApp
//
//  Created by Peter Lee on 14/11/10.
//  Copyright (c) 2014年 爱尔特电子有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PlayerTopBarDelegate;
@interface PlayerTopBar : UIView

+ (instancetype)instanceFromNib;

@property (weak, nonatomic) IBOutlet UIButton *allScreenButton;
@property (weak, nonatomic) IBOutlet UIButton *voiceButton;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIButton *videoButton;
@property (weak, nonatomic) IBOutlet UIButton *qualityButton;
@property (weak, nonatomic) IBOutlet UIButton *button1;
@property (weak, nonatomic) IBOutlet UIButton *button2;
@property (weak, nonatomic) IBOutlet UIButton *button3;
@property (weak, nonatomic) IBOutlet UIButton *button4;

@property (weak, nonatomic) IBOutlet UISlider *voiceSlider;

@property (assign, nonatomic) id<PlayerTopBarDelegate> delegate;

- (IBAction)allScreenButtonCliked:(id)sender;
- (IBAction)voiceButtonCliked:(id)sender;
- (IBAction)cameraButtonCliked:(id)sender;
- (IBAction)videoButtonCliked:(id)sender;
- (IBAction)qualityButtonCliked:(id)sender;
- (IBAction)button1Cliked:(id)sender;
- (IBAction)button2Cliked:(id)sender;
- (IBAction)button3Cliked:(id)sender;
- (IBAction)button4Cliked:(id)sender;
- (IBAction)voiceSliderChanged:(id)sender;

@end

@protocol PlayerTopBarDelegate <NSObject>

@required

@optional
- (void)playerTopBar:(PlayerTopBar *)playerTopBar didClikedOnButtonIndex:(NSUInteger)index;
- (void)playerTopBar:(PlayerTopBar *)playerTopBar didChangedVoiceValue:(float)voiceValue;
@end