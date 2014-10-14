//
//  VideoHistoryViewController.m
//  AiertApp
//
//  Created by Peter Lee on 14/10/14.
//  Copyright (c) 2014年 爱尔特电子有限公司. All rights reserved.
//

#import "VideoHistoryViewController.h"

@interface VideoHistoryViewController ()
{
    SegmentedControl *segmentControl;
    BOOL remoteTag;
}

@property(assign, nonatomic) BOOL remoteTag;
@property(strong, nonatomic) SegmentedControl *segmentControl;

@end

@implementation VideoHistoryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initializationParameters];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initializationParameters
{
    //Here initialization your parameters
    [self initializationUI];
    [self initializationData];
}

-(void)initializationUI
{
    //Here initialization your UI parameters
    //self.title = @"录像";
    [self.navigationItem setTitle:@"录像"];
    UIImage *image = PNG_NAME(@"btn_big");
    image = [image stretchableImageWithLeftCapWidth:floorf(image.size.width*0.5) topCapHeight:floorf(image.size.height*0.5)];
    [self.navigationController.navigationBar setBackgroundImage:PNG_NAME(@"6") forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationItem.titleView setTintColor:[UIColor whiteColor]];
    
    self.navigationItem.titleView = self.segmentControl;
}

-(void)initializationData
{
    //Here initialization your data parameters
}

- (SegmentedControl *)segmentControl
{
    if (!segmentControl) {
        segmentControl = [[SegmentedControl alloc] initWithItems:@[@"本地", @"远程"]];
        segmentControl.titleTextColor = [UIColor colorWithRed:0.38f green:0.68f blue:0.93f alpha:1.0f];
        segmentControl.selectedTitleTextColor = [UIColor whiteColor];
        segmentControl.selectedTitleFont = [UIFont systemFontOfSize:18.0f];
        segmentControl.segmentIndicatorBackgroundColor = [UIColor colorWithRed:0.38f green:0.68f blue:0.93f alpha:1.0f];
        segmentControl.backgroundColor = [UIColor colorWithRed:0.31f green:0.53f blue:0.72f alpha:1.0f];
        segmentControl.borderWidth = 0.0f;
        segmentControl.segmentIndicatorBorderWidth = 0.0f;
        segmentControl.segmentIndicatorInset = 1.0f;
        segmentControl.segmentIndicatorBorderColor = self.view.backgroundColor;
        [segmentControl sizeToFit];
        segmentControl.cornerRadius = CGRectGetHeight(segmentControl.frame) / 2.0f;
        
        [segmentControl addTarget:self action:@selector(segmentSelected:) forControlEvents:UIControlEventValueChanged];
    }
    
    return segmentControl;
}

- (BOOL)remoteTag
{
    return (self.segmentControl.selectedSegmentIndex > 0);
}


- (void)segmentSelected:(id)sender
{
    self.remoteTag ? LOG(@"远程"):LOG(@"本地");
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
