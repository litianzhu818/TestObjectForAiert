//
//  AiertHeaderView.h
//  AiertApp
//
//  Created by Peter Lee on 14/9/11.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

#define MARGIN_WIDTH 5.0f

@protocol AiertHeaderViewDelegate;

@interface AiertHeaderView : UIView

@property (strong, nonatomic) IBOutlet UIButton *refreshButton;
@property (strong, nonatomic) IBOutlet UIImageView *cameraImageView;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (assign, nonatomic) IBOutlet id<AiertHeaderViewDelegate> delegate;

-(IBAction)clikedOnRefreshButton:(id)sender;
-(void)stopRefreshing;

@end

@protocol AiertHeaderViewDelegate <NSObject>

-(void)clikedOnAiertHeaderView:(AiertHeaderView *)aiertHeaderView;
-(void)clikedRefreshButtonOnAiertHeaderView:(AiertHeaderView *)aiertHeaderView;

@end
