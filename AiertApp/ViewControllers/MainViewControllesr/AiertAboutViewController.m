//
//  AiertAboutViewController.m
//  AiertApp
//
//  Created by Peter Lee on 14/9/3.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "AiertAboutViewController.h"

@interface AiertAboutViewController ()
{
    NSDictionary *systemInfoDic;
}

@end

@implementation AiertAboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    //[self.tabBarController.tabBar setHidden:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initParameters];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initParameters
{
    [self initData];
    [self initUI];
}
-(void)initUI
{
    [self.navigationItem setTitle:@"关于我们"];
    UIImage *image = PNG_NAME(@"btn_big");
    image = [image stretchableImageWithLeftCapWidth:floorf(image.size.width*0.5) topCapHeight:floorf(image.size.height*0.5)];
    [self.navigationController.navigationBar setBackgroundImage:PNG_NAME(@"6") forBarMetrics:UIBarMetricsDefault];
    //[self.navigationController.navigationItem.titleView setTintColor:[UIColor whiteColor]];
    [self.nameButton setBackgroundImage:image forState:UIControlStateNormal];
    [self.complanyButton setBackgroundImage:image forState:UIControlStateNormal];
    [self.versionButton setBackgroundImage:image forState:UIControlStateNormal];
    
    [self.nameButton setTitle:[systemInfoDic objectForKey:@"SoftwareName"] forState:UIControlStateNormal];
    [self.complanyButton setTitle:[systemInfoDic objectForKey:@"CompanyName"] forState:UIControlStateNormal];
    [self.versionButton setTitle:[NSString stringWithFormat:@"%@%@",@"ZXA-CameraV",[systemInfoDic objectForKey:@"SoftwareVersion"]] forState:UIControlStateNormal];

}
-(void)initData
{
    systemInfoDic = READ_PLIST(@"CompanyInfo");
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
