//
//  PlayerBottomBar.h
//  AiertApp
//
//  Created by Peter Lee on 14/11/10.
//  Copyright (c) 2014年 爱尔特电子有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PlayerBottomBarDelegate;

@interface PlayerBottomBar : UIView

@property (weak, nonatomic) IBOutlet UIButton *close_Btn;
@property (weak, nonatomic) IBOutlet UIButton *left_right_btn;
@property (weak, nonatomic) IBOutlet UIButton *up_down_btn;
@property (weak, nonatomic) IBOutlet UIButton *turn_left_right_btn;
@property (weak, nonatomic) IBOutlet UIButton *turn_up_down_btn;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (assign, nonatomic) id<PlayerBottomBarDelegate> delegate;

+ (instancetype)instanceFromNib;
- (void)setFrame:(CGRect)frame;

- (IBAction)closeAction:(id)sender;
- (IBAction)left_rightAction:(id)sender;
- (IBAction)up_downAction:(id)sender;
- (IBAction)turn_up_downAction:(id)sender;
- (IBAction)turn_left_rightAction:(id)sender;

@end

@protocol PlayerBottomBarDelegate <NSObject>

@required

@optional

- (void)playerBottomBar:(PlayerBottomBar *)playerBottomBar didClikedOnButtonIndex:(NSUInteger)index;

@end
