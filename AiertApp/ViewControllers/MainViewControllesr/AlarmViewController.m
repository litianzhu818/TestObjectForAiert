//
//  AlarmViewController.m
//  AiertApp
//
//  Created by Peter Lee on 14/10/14.
//  Copyright (c) 2014年 爱尔特电子有限公司. All rights reserved.
//

#import "AlarmViewController.h"

@interface AlarmViewController ()

@end

@implementation AlarmViewController

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
    [self.navigationItem setTitle:@"报警事件"];
    UIImage *image = PNG_NAME(@"btn_big");
    image = [image stretchableImageWithLeftCapWidth:floorf(image.size.width*0.5) topCapHeight:floorf(image.size.height*0.5)];
    [self.navigationController.navigationBar setBackgroundImage:PNG_NAME(@"6") forBarMetrics:UIBarMetricsDefault];
    //[self.navigationController.navigationItem.titleView setTintColor:[UIColor whiteColor]];

}

-(void)initializationData
{
    //Here initialization your data parameters
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
