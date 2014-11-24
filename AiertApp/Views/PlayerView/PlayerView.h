//
//  PlayerView.h
//  playerView
//
//  Created by Peter Lee on 14/11/20.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DisplayImageView.h"
#import "CMPopTipViewQuality.h"
#import "BasicDefine.h"

@protocol PlayerViewDelegate;

@interface PlayerView : UIView<DisplayImageViewProtocol>
@property (assign, nonatomic) VideoQualityType qualityType;
@property (assign, nonatomic) BOOL isFullScreen;
@property (assign, nonatomic) BOOL hasTimer;
@property (strong, nonatomic) NSTimer *timer;
//@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;

@property (strong, nonatomic) UIView *topBarView;
@property (strong, nonatomic) UIView *bottomBarView;
@property (strong, nonatomic) DisplayImageView *playerView;
@property (strong, nonatomic) CMPopTipViewQuality *popupQualityView;

@property (strong, nonatomic) UILabel *noticeLabel;
@property (strong, nonatomic) UIButton *talkButton;

//buttons
@property (strong, nonatomic) UIButton *closeButton;
@property (strong, nonatomic) UIButton *button1;
@property (strong, nonatomic) UIButton *button2;
@property (strong, nonatomic) UIButton *left_right_btn;
@property (strong, nonatomic) UIButton *up_down_btn;
@property (strong, nonatomic) UIButton *turn_left_right_btn;
@property (strong, nonatomic) UIButton *turn_up_down_btn;
@property (strong, nonatomic) UIButton *button3;
@property (strong, nonatomic) UIButton *button4;

@property (strong, nonatomic) UIButton *button5;
@property (strong, nonatomic) UIButton *button6;
@property (strong, nonatomic) UIButton *button7;
@property (strong, nonatomic) UIButton *button8;
@property (strong, nonatomic) UIButton *button9;

@property (strong, nonatomic) UISlider *volumeSlider;

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;

@property (weak, nonatomic) id<PlayerViewDelegate> delegate;

@end

@protocol PlayerViewDelegate <NSObject>

- (void)playerView:(PlayerView *)playerView touchDownInsideButtonAtIndex:(NSUInteger)index;
- (void)playerView:(PlayerView *)playerView touchUpInsideButtonAtIndex:(NSUInteger)index;
- (void)playerView:(PlayerView *)playerView didSwitchTalkStatus:(BOOL)talking;
- (void)playerView:(PlayerView *)playerView didChangedVolumeWithValue:(float)value;
- (void)playerView:(PlayerView *)playerView didChangedQualityTypeWithValue:(VideoQualityType)newQualityType;

@end
