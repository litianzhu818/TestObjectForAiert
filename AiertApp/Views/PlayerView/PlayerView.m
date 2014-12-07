//
//  PlayerView.m
//  playerView
//
//  Created by Peter Lee on 14/11/20.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "PlayerView.h"

#define VIEW_END_X(View) (View.frame.origin.x + View.frame.size.width)
#define VIEW_END_Y(View) (View.frame.origin.y + View.frame.size.height)

#define STATUS_HEIGHT 20.0f

#define MARGIN_WIDTH 10.0f

#define ROW_NUM 8
#define BUTTON_MARGIN_WIDTH 8.0f

#define SCREEN_BOUNDS [[UIScreen mainScreen] bounds]
#define PLAYER_VIEW_WIDTH SCREEN_BOUNDS.size.width
#define PLAYER_VIEW_HEIGHT  180.0f

#define BAR_WIDTH PLAYER_VIEW_WIDTH
#define BAR_HEIGHT 44.0f

#define BUTTON_HEIGHT (BAR_HEIGHT - 2 * MARGIN_WIDTH)
#define BUTTON_WIDTH (BAR_WIDTH - (ROW_NUM + 1) * BUTTON_MARGIN_WIDTH)/ROW_NUM

#define SELF_WIDTH PLAYER_VIEW_WIDTH
#define SELF_HEIGHT (2 * 44 + PLAYER_VIEW_HEIGHT)

#define SLIDER_HEIGHT BUTTON_HEIGHT
#define SLIDER_WIDTH (PLAYER_VIEW_WIDTH - 8 * BUTTON_MARGIN_WIDTH - 6 * BUTTON_WIDTH)

@interface PlayerView ()

@property (assign, nonatomic) int minValue;
@property (assign, nonatomic) int maxValue;
@property (assign, nonatomic) BOOL isSettingSliderShowing;
@property (assign, nonatomic) SettingSliderType settingSliderType;

@end

@implementation PlayerView

- (void)dealloc
{
//    [self.playerView removeGestureRecognizer:self.tapGesture];
    if ([self.timer isValid]) {
        [self.timer invalidate];
    }
}
- (instancetype)init
{
    CGRect frame = [[UIScreen mainScreen] bounds];
    
    return [self initWithFrame:frame];
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame minValue:0 maxValue:32];
}

- (id)initWithFrame:(CGRect)frame minValue:(int)miniValue maxValue:(int)_MaxValue
{
    frame = CGRectMake(frame.origin.x, frame.origin.y, SELF_WIDTH, SELF_HEIGHT);
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setMinValue:miniValue];
        [self setMaxValue:_MaxValue];
        [self initParameters];
    }
    return self;
}

- (void)initParameters
{
    if (self.maxValue == 0) {
        self.maxValue = 32;
    }
    [self initUI];
    [self initData];
}

- (void)initUI
{
    /*****************init the topBarView*******************/
    self.topBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, BAR_WIDTH, BAR_HEIGHT)];
//    self.topBarView.backgroundColor = [UIColor yellowColor];
    self.topBarView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addSubview:self.topBarView];
    
    //init the close button
    self.closeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.closeButton.frame = CGRectMake(BUTTON_MARGIN_WIDTH, MARGIN_WIDTH, BUTTON_WIDTH, BUTTON_HEIGHT);
    self.closeButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    self.closeButton.tag = 1;
    [self.closeButton addTarget:self action:@selector(touchUpInsideButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.closeButton addTarget:self action:@selector(touchDownInsideButton:) forControlEvents:UIControlEventTouchDown];
    [self.closeButton setSelected:NO];
    [self.closeButton setBackgroundImage:[UIImage imageNamed:@"video_stop_pre"] forState:UIControlStateSelected];
    [self.closeButton setBackgroundImage:[UIImage imageNamed:@"video_stop_btn"] forState:UIControlStateNormal];
    [self.closeButton setTintColor:[UIColor clearColor]];
    [self.closeButton setUserInteractionEnabled:YES];
    [self.topBarView addSubview:self.closeButton];
    
    //the button1
    self.button1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.button1.frame = CGRectMake(BUTTON_MARGIN_WIDTH + VIEW_END_X(self.closeButton), MARGIN_WIDTH, BUTTON_WIDTH, BUTTON_HEIGHT);
    self.button1.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    self.button1.tag = 2;
    [self.button1 addTarget:self action:@selector(touchUpInsideButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.button1 addTarget:self action:@selector(touchDownInsideButton:) forControlEvents:UIControlEventTouchDown];
    [self.button1 setSelected:NO];
    [self.button1 setBackgroundImage:[UIImage imageNamed:@"video_10"] forState:UIControlStateSelected];
    [self.button1 setBackgroundImage:[UIImage imageNamed:@"video_10"] forState:UIControlStateNormal];
    [self.button1 setTintColor:[UIColor clearColor]];
    [self.button1 setUserInteractionEnabled:YES];
    [self.topBarView addSubview:self.button1];
    
    //the button2
    self.button2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.button2.frame = CGRectMake(BUTTON_MARGIN_WIDTH + VIEW_END_X(self.button1), MARGIN_WIDTH, BUTTON_WIDTH, BUTTON_HEIGHT);
    self.button2.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    self.button2.tag = 3;
    [self.button2 addTarget:self action:@selector(touchUpInsideButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.button2 addTarget:self action:@selector(touchDownInsideButton:) forControlEvents:UIControlEventTouchDown];
    [self.button2 setSelected:NO];
    [self.button2 setBackgroundImage:[UIImage imageNamed:@"video_11"] forState:UIControlStateSelected];
    [self.button2 setBackgroundImage:[UIImage imageNamed:@"video_11"] forState:UIControlStateNormal];
    [self.button2 setTintColor:[UIColor clearColor]];
    [self.button2 setUserInteractionEnabled:YES];
    [self.topBarView addSubview:self.button2];
    
    //the left_right
    self.left_right_btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.left_right_btn.frame = CGRectMake(BUTTON_MARGIN_WIDTH + VIEW_END_X(self.button2), MARGIN_WIDTH, BUTTON_WIDTH, BUTTON_HEIGHT);
    self.left_right_btn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    self.left_right_btn.tag = 4;
    [self.left_right_btn addTarget:self action:@selector(touchUpInsideButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.left_right_btn addTarget:self action:@selector(touchDownInsideButton:) forControlEvents:UIControlEventTouchDown];
    [self.left_right_btn setSelected:NO];
    [self.left_right_btn setBackgroundImage:[UIImage imageNamed:@"video_1"] forState:UIControlStateSelected];
    [self.left_right_btn setBackgroundImage:[UIImage imageNamed:@"video_1"] forState:UIControlStateNormal];
    [self.left_right_btn setTintColor:[UIColor clearColor]];
    [self.left_right_btn setUserInteractionEnabled:YES];
    [self.topBarView addSubview:self.left_right_btn];
    
    //the up_down_btn
    self.up_down_btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.up_down_btn.frame = CGRectMake(BUTTON_MARGIN_WIDTH + VIEW_END_X(self.left_right_btn), MARGIN_WIDTH, BUTTON_WIDTH, BUTTON_HEIGHT);
    self.up_down_btn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    self.up_down_btn.tag = 5;
    [self.up_down_btn addTarget:self action:@selector(touchUpInsideButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.up_down_btn addTarget:self action:@selector(touchDownInsideButton:) forControlEvents:UIControlEventTouchDown];
    [self.up_down_btn setSelected:NO];
    [self.up_down_btn setBackgroundImage:[UIImage imageNamed:@"video_2"] forState:UIControlStateSelected];
    [self.up_down_btn setBackgroundImage:[UIImage imageNamed:@"video_2"] forState:UIControlStateNormal];
    [self.up_down_btn setTintColor:[UIColor clearColor]];
    [self.up_down_btn setUserInteractionEnabled:YES];
    [self.topBarView addSubview:self.up_down_btn];
    
    //the turn_left_right_btn
    self.turn_left_right_btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.turn_left_right_btn.frame = CGRectMake(BUTTON_MARGIN_WIDTH + VIEW_END_X(self.up_down_btn), MARGIN_WIDTH, BUTTON_WIDTH, BUTTON_HEIGHT);
    self.turn_left_right_btn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    self.turn_left_right_btn.tag = 6;
    [self.turn_left_right_btn addTarget:self action:@selector(touchUpInsideButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.turn_left_right_btn addTarget:self action:@selector(touchDownInsideButton:) forControlEvents:UIControlEventTouchDown];
    [self.turn_left_right_btn setSelected:NO];
    [self.turn_left_right_btn setBackgroundImage:[UIImage imageNamed:@"video_3"] forState:UIControlStateSelected];
    [self.turn_left_right_btn setBackgroundImage:[UIImage imageNamed:@"video_3"] forState:UIControlStateNormal];
    [self.turn_left_right_btn setTintColor:[UIColor clearColor]];
    [self.turn_left_right_btn setUserInteractionEnabled:YES];
    [self.topBarView addSubview:self.turn_left_right_btn];
    
    //the turn_up_down_btn
    self.turn_up_down_btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.turn_up_down_btn.frame = CGRectMake(BUTTON_MARGIN_WIDTH + VIEW_END_X(self.turn_left_right_btn), MARGIN_WIDTH, BUTTON_WIDTH, BUTTON_HEIGHT);
    self.turn_up_down_btn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    self.turn_up_down_btn.tag = 7;
    [self.turn_up_down_btn addTarget:self action:@selector(touchUpInsideButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.turn_up_down_btn addTarget:self action:@selector(touchDownInsideButton:) forControlEvents:UIControlEventTouchDown];
    [self.turn_up_down_btn setSelected:NO];
    [self.turn_up_down_btn setBackgroundImage:[UIImage imageNamed:@"video_4"] forState:UIControlStateSelected];
    [self.turn_up_down_btn setBackgroundImage:[UIImage imageNamed:@"video_4"] forState:UIControlStateNormal];
    [self.turn_up_down_btn setTintColor:[UIColor clearColor]];
    [self.turn_up_down_btn setUserInteractionEnabled:YES];
    [self.topBarView addSubview:self.turn_up_down_btn];
    
    //the button3
    self.button3 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.button3.frame = CGRectMake(BUTTON_MARGIN_WIDTH + VIEW_END_X(self.turn_up_down_btn), MARGIN_WIDTH, BUTTON_WIDTH, BUTTON_HEIGHT);
    self.button3.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    self.button3.tag = 8;
    [self.button3 addTarget:self action:@selector(touchUpInsideButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.button3 addTarget:self action:@selector(touchDownInsideButton:) forControlEvents:UIControlEventTouchDown];
    [self.button3 setSelected:NO];
    [self.button3 setBackgroundImage:[UIImage imageNamed:@"video_14_selected"] forState:UIControlStateSelected];
    [self.button3 setBackgroundImage:[UIImage imageNamed:@"video_14"] forState:UIControlStateNormal];
    [self.button3 setTintColor:[UIColor clearColor]];
    [self.button3 setUserInteractionEnabled:YES];
    [self.topBarView addSubview:self.button3];
    
    /*****************init the playerView*******************/
    self.playerView = [[DisplayImageView alloc] initWithFrame:CGRectMake(0, BAR_HEIGHT,PLAYER_VIEW_WIDTH,PLAYER_VIEW_HEIGHT)];
    self.playerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
#warning this is the test code
    //self.playerView.image = [UIImage imageNamed:@"通用头像"];
    self.playerView.contentMode = UIViewContentModeScaleAspectFit;
    self.playerView.delegate = self;
    self.playerView.userInteractionEnabled = YES;
    [self addSubview:self.playerView];
    
    self.noticeLabel = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN_WIDTH/2, PLAYER_VIEW_HEIGHT - BAR_HEIGHT, 200, BAR_HEIGHT)];
    self.noticeLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    [self.noticeLabel setFont:[UIFont systemFontOfSize:14.0]];
    [self.noticeLabel setText:@"请按住右边的麦克风进行语音对话"];
    [self.playerView addSubview:self.noticeLabel];
    
    self.talkButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.talkButton.frame = CGRectMake(PLAYER_VIEW_WIDTH - MARGIN_WIDTH - BAR_HEIGHT, PLAYER_VIEW_HEIGHT - BAR_HEIGHT, BAR_HEIGHT, BAR_HEIGHT);
    self.talkButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin| UIViewAutoresizingFlexibleTopMargin;
    [self.talkButton addTarget:self action:@selector(talkButtonClosed:) forControlEvents:UIControlEventTouchUpInside];
    [self.talkButton addTarget:self action:@selector(talkButtonOpened:) forControlEvents:UIControlEventTouchDown];
    [self.talkButton setSelected:NO];
    [self.talkButton setBackgroundImage:[UIImage imageNamed:@"speak_pre"] forState:UIControlStateSelected];
    [self.talkButton setBackgroundImage:[UIImage imageNamed:@"speak_nor"] forState:UIControlStateNormal];
    [self.talkButton setTintColor:[UIColor clearColor]];
    [self.talkButton setUserInteractionEnabled:YES];
    [self.playerView addSubview:self.talkButton];
    
    
    /*****************init the bottomBarView*******************/
    self.bottomBarView = [[UIView alloc] initWithFrame:CGRectMake(0, BAR_HEIGHT+PLAYER_VIEW_HEIGHT, BAR_WIDTH, BAR_HEIGHT)];
    self.bottomBarView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
//    self.bottomBarView.backgroundColor = [UIColor redColor];
    [self addSubview:self.bottomBarView];
    
    //the button4
    self.button4 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.button4.frame = CGRectMake(BUTTON_MARGIN_WIDTH, MARGIN_WIDTH, BUTTON_WIDTH, BUTTON_HEIGHT);
    self.button4.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    self.button4.tag = 9;
    [self.button4 addTarget:self action:@selector(touchUpInsideButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.button4 addTarget:self action:@selector(touchDownInsideButton:) forControlEvents:UIControlEventTouchDown];
    [self.button4 setSelected:NO];
    [self.button4 setBackgroundImage:[UIImage imageNamed:@"video_6_no"] forState:UIControlStateSelected];
    [self.button4 setBackgroundImage:[UIImage imageNamed:@"video_6_no"] forState:UIControlStateNormal];
    [self.button4 setTintColor:[UIColor clearColor]];
    [self.button4 setUserInteractionEnabled:YES];
    [self.bottomBarView addSubview:self.button4];
    
    //the button5
    self.button5 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.button5.frame = CGRectMake(BUTTON_MARGIN_WIDTH + VIEW_END_X(self.button4), MARGIN_WIDTH, BUTTON_WIDTH, BUTTON_HEIGHT);
    self.button5.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    self.button5.tag = 10;
    [self.button5 addTarget:self action:@selector(touchUpInsideButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.button5 addTarget:self action:@selector(touchDownInsideButton:) forControlEvents:UIControlEventTouchDown];
    [self.button5 setSelected:NO];
    [self.button5 setBackgroundImage:[UIImage imageNamed:@"video_7"] forState:UIControlStateSelected];
    [self.button5 setBackgroundImage:[UIImage imageNamed:@"video_7"] forState:UIControlStateNormal];
    [self.button5 setTintColor:[UIColor clearColor]];
    [self.button5 setUserInteractionEnabled:YES];
    [self.bottomBarView addSubview:self.button5];
    
    //the button6
    self.button6 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.button6.frame = CGRectMake(BUTTON_MARGIN_WIDTH + VIEW_END_X(self.button5), MARGIN_WIDTH, BUTTON_WIDTH, BUTTON_HEIGHT);
    self.button6.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    self.button6.tag = 11;
    [self.button6 addTarget:self action:@selector(touchUpInsideButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.button6 addTarget:self action:@selector(touchDownInsideButton:) forControlEvents:UIControlEventTouchDown];
    [self.button6 setSelected:NO];
    [self.button6 setBackgroundImage:[UIImage imageNamed:@"video_8"] forState:UIControlStateSelected];
    [self.button6 setBackgroundImage:[UIImage imageNamed:@"video_8"] forState:UIControlStateNormal];
    [self.button6 setTintColor:[UIColor clearColor]];
    [self.button6 setUserInteractionEnabled:YES];
    [self.bottomBarView addSubview:self.button6];
    
    //the button7
    self.button7 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.button7.frame = CGRectMake(BUTTON_MARGIN_WIDTH + VIEW_END_X(self.button6), MARGIN_WIDTH, BUTTON_WIDTH, BUTTON_HEIGHT);
    self.button7.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    self.button7.tag = 12;
    [self.button7 addTarget:self action:@selector(touchUpInsideButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.button7 addTarget:self action:@selector(touchDownInsideButton:) forControlEvents:UIControlEventTouchDown];
    [self.button7 setSelected:NO];
    [self.button7 setBackgroundImage:[UIImage imageNamed:@"video_9"] forState:UIControlStateSelected];
    [self.button7 setBackgroundImage:[UIImage imageNamed:@"video_9"] forState:UIControlStateNormal];
    [self.button7 setTintColor:[UIColor clearColor]];
    [self.button7 setUserInteractionEnabled:YES];
    [self.bottomBarView addSubview:self.button7];
    
    //the button8
    self.button8 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.button8.frame = CGRectMake(BUTTON_MARGIN_WIDTH + VIEW_END_X(self.button7), MARGIN_WIDTH, BUTTON_WIDTH, BUTTON_HEIGHT);
    self.button8.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    self.button8.tag = 13;
    [self.button8 addTarget:self action:@selector(touchUpInsideButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.button8 addTarget:self action:@selector(touchDownInsideButton:) forControlEvents:UIControlEventTouchDown];
    [self.button8 setSelected:NO];
    [self.button8 setBackgroundImage:[UIImage imageNamed:@"video_12"] forState:UIControlStateSelected];
    [self.button8 setBackgroundImage:[UIImage imageNamed:@"video_12"] forState:UIControlStateNormal];
    [self.button8 setTintColor:[UIColor clearColor]];
    [self.button8 setUserInteractionEnabled:YES];
    [self.bottomBarView addSubview:self.button8];
    
    //the button9
    self.button9 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.button9.frame = CGRectMake(BUTTON_MARGIN_WIDTH + VIEW_END_X(self.button8), MARGIN_WIDTH, BUTTON_WIDTH, BUTTON_HEIGHT);
    self.button9.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    self.button9.tag = 14;
    [self.button9 addTarget:self action:@selector(touchUpInsideButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.button9 addTarget:self action:@selector(touchDownInsideButton:) forControlEvents:UIControlEventTouchDown];
    [self.button9 setSelected:NO];
    [self.button9 setBackgroundImage:[UIImage imageNamed:@"video_13"] forState:UIControlStateSelected];
    [self.button9 setBackgroundImage:[UIImage imageNamed:@"video_13"] forState:UIControlStateNormal];
    [self.button9 setTintColor:[UIColor clearColor]];
    [self.button9 setUserInteractionEnabled:YES];
    [self.bottomBarView addSubview:self.button9];
    
    self.volumeSlider  =[[UISlider alloc] initWithFrame:CGRectMake(BUTTON_MARGIN_WIDTH + VIEW_END_X(self.button9), MARGIN_WIDTH, SLIDER_WIDTH, SLIDER_HEIGHT)];
    self.volumeSlider.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
    self.volumeSlider.backgroundColor = [UIColor clearColor];
    self.volumeSlider.minimumValue = self.minValue;
    self.volumeSlider.maximumValue = self.maxValue;
    self.volumeSlider.value = 0.5 * self.maxValue;
    [self.volumeSlider addTarget:self action:@selector(updateValue:) forControlEvents:UIControlEventValueChanged];
    //左右轨的图片
    UIImage *stetchLeftTrack= [UIImage imageNamed:@"volume_bar_selected"];
    UIImage *stetchRightTrack = [UIImage imageNamed:@"volume_bar_normal"];
    //滑块图片
    UIImage *thumbImage = [UIImage imageNamed:@"volume_btn"];
    
    [self.volumeSlider setMinimumTrackImage:stetchLeftTrack forState:UIControlStateNormal];
    [self.volumeSlider setMaximumTrackImage:stetchRightTrack forState:UIControlStateNormal];
    //注意这里要加UIControlStateHightlighted的状态，否则当拖动滑块时滑块将变成原生的控件
    [self.volumeSlider setThumbImage:thumbImage forState:UIControlStateHighlighted];
    [self.volumeSlider setThumbImage:thumbImage forState:UIControlStateNormal];
    
    [self.bottomBarView addSubview:self.volumeSlider];
    
    
    self.popupQualityView = [[CMPopTipViewQuality alloc] initWithBackgroundColor:[UIColor colorWithRed:124.0/255.0f green:111.0/255.0f blue:176.0/255.0f alpha:1.0]];
    self.popupQualityView.alpha = 0.5;
    self.popupQualityView.qualityView.delegate = self;
    self.popupQualityView.delegate = self;
    
    self.settingSlider  =[[UISlider alloc] initWithFrame:CGRectMake(0,0,100,44)];
    self.settingSlider.center = self.playerView.center;
    self.settingSlider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.settingSlider.backgroundColor = [UIColor clearColor];
    self.settingSlider.userInteractionEnabled;
    self.settingSlider.hidden = YES;
    self.settingSlider.minimumValue = 0.0;
    self.settingSlider.maximumValue = 255.0;
    self.settingSlider.value = 127;
    [self.settingSlider addTarget:self action:@selector(updateSettingSliderValue:) forControlEvents:UIControlEventValueChanged];
    [self.playerView addSubview:self.settingSlider];

    NSLog(NSStringFromCGRect(self.button9.frame));
    
    [self setupConstraints];
    [self showBars:YES];
    [self hidenTalkViews:YES];
}

- (void)initData
{
    self.backgroundColor = [UIColor blackColor];
    self.isFullScreen = NO;
    self.qualityType = VideoQualityTypeLD;
    self.isSettingSliderShowing = NO;
    self.settingSliderType = SettingSliderTypeBrightness;
    [self startTimer];
}

-(void) setupConstraints
{

}
- (void)hidenBarsWhenShowing
{
    if (!self.isFullScreen) {
        [self showBars:NO];
    }
    
    if ([self.timer isValid]) {
        [self.timer invalidate];
    }
}

- (void)startTimer
{
    if (![self.timer isValid]) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(hidenBarsWhenShowing) userInfo:nil repeats:NO];
    }
}

- (void)clikedOnPlayerView:(UITapGestureRecognizer *)sender
{
    [self showBars:self.isFullScreen];
}
-(void) showBars:(BOOL)show
{
    __weak __typeof(self) weakself = self;
    if (self.isFullScreen) {//显示工具栏
        if (show) {
            CGRect playerFrame = self.playerView.frame;
            playerFrame.origin.y = BAR_HEIGHT;
            playerFrame.size.height = self.frame.size.height - 2*BAR_HEIGHT ;
            [UIView animateWithDuration:0.3 animations:^{
                weakself.topBarView.alpha = 1;
                weakself.bottomBarView.alpha = 1;
                weakself.playerView.frame = playerFrame;
                weakself.isFullScreen = !show;
            }];
        }
    }else{//影藏工具栏
        if(!show) {
            CGRect playerFrame = self.playerView.frame;
            playerFrame.origin = self.topBarView.frame.origin;
            playerFrame.size.height = self.frame.size.height;
            [UIView animateWithDuration:0.3 animations:^{
                weakself.topBarView.alpha = 0;
                weakself.bottomBarView.alpha = 0;
                weakself.playerView.frame = playerFrame;
                weakself.isFullScreen = !show;
            }];
        }
    }
}
- (void)hidenTalkViews:(BOOL)hiden
{
    [self.noticeLabel setHidden:hiden];
    [self.talkButton setHidden:hiden];
}

-(IBAction)updateValue:(id)sender
{
    //添加响应事件
    //读取滑块的值
    float value = self.volumeSlider.value;
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerView:didChangedVolumeWithValue:)]) {
        [self.delegate playerView:self didChangedVolumeWithValue:value];
    }
}

- (IBAction)updateSettingSliderValue:(id)sender
{
    float value = self.settingSlider.value;
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerView:didChangedSettingWithValue:type:)]) {
        [self.delegate playerView:self didChangedSettingWithValue:value type:self.settingSliderType];
    }
}

- (void)talkButtonOpened:(id)sender
{
    [self.talkButton setBackgroundImage:[UIImage imageNamed:@"speak_pre"] forState:UIControlStateNormal];
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerView:didSwitchTalkStatus:)]) {
        [self.delegate playerView:self didSwitchTalkStatus:YES];
    }
}

- (void)talkButtonClosed:(id)sender
{
    [self.talkButton setBackgroundImage:[UIImage imageNamed:@"speak_nor"] forState:UIControlStateNormal];
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerView:didSwitchTalkStatus:)]) {
        [self.delegate playerView:self didSwitchTalkStatus:NO];
    }
}

- (void)touchDownInsideButton:(UIButton *)btn
{
    switch (btn.tag) {
        case 9:
            
            break;
            
        case 12:
        {
            self.popupQualityView.qualityView.qualityType = self.qualityType;
            [self.popupQualityView presentPointingAtView:btn inView:self animated:YES];
        }
            break;
            
        default:
            break;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerView:touchDownInsideButtonAtIndex:)]) {
        [self.delegate playerView:self touchDownInsideButtonAtIndex:btn.tag];
    }
}
- (void)touchUpInsideButton:(UIButton *)btn
{
    switch (btn.tag) {
        case 9:
        {
            if (!self.talkButton.hidden) {
                [self.button4 setBackgroundImage:[UIImage imageNamed:@"video_6_no"] forState:UIControlStateNormal];
                [self hidenTalkViews:YES];
            }else{
                [self.button4 setBackgroundImage:[UIImage imageNamed:@"video_6_yes"] forState:UIControlStateNormal];
                [self hidenTalkViews:NO];
            }
        }
            break;
        case 2:
        {
            [self.settingSlider setHidden:self.isSettingSliderShowing];
            self.settingSliderType = SettingSliderTypeBrightness;
            self.isSettingSliderShowing = !self.isSettingSliderShowing;
        }
            break;
        case 3:
        {
            [self.settingSlider setHidden:self.isSettingSliderShowing];
            self.settingSliderType = SettingSliderTypeContrast;
            self.isSettingSliderShowing = !self.isSettingSliderShowing;
        }
            break;
        case 14:
        {
            [self.settingSlider setHidden:self.isSettingSliderShowing];
            self.settingSliderType = SettingSliderTypeSaturation;
            self.isSettingSliderShowing = !self.isSettingSliderShowing;
        }
            break;
        default:
            break;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerView:touchUpInsideButtonAtIndex:)]) {
        [self.delegate playerView:self touchUpInsideButtonAtIndex:btn.tag];
    }
    
}
#pragma mark - DisplayImageView
- (void)displayImageViewTaped:(id)sender
{
    [self showBars:self.isFullScreen];
}

- (void)selectQualityView:(SelectQualityView *)selectQualityView
          changeQualityTo:(VideoQualityType)newQualityType
{
    self.qualityType = newQualityType;
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerView:didChangedQualityTypeWithValue:)]) {
        [self.delegate playerView:self didChangedQualityTypeWithValue:newQualityType];
    }
    [self.popupQualityView dismissAnimated:YES];
}

- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView
{

}


@end
