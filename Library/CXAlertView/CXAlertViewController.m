//
//  CXAlertViewController.m
//  CXAlertViewDemo
//
//  Created by Peter Lee on 14/9/13.
//  Copyright (c) 2013年 爱尔特电子有限公司. All rights reserved.
//

#import "CXAlertViewController.h"

@interface CXAlertView ()

- (void)setup;
- (void)resetTransition;
- (void)invalidateLayout;
- (void)resetOnOrientation:(UIInterfaceOrientation)toInterfaceOrientation;

@property (nonatomic, strong) UIWindow *oldKeyWindow;

@end

@interface CXAlertViewController ()
{
    BOOL _oldShouldAutorotate;
    NSInteger _oldSupportedInterfaceOrientations;
}

@end

@implementation CXAlertViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View life cycle

- (void)loadView
{
    self.view = self.alertView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.alertView setup];
    
    _oldShouldAutorotate = self.alertView.oldKeyWindow.rootViewController.shouldAutorotate;
    _oldSupportedInterfaceOrientations = self.alertView.oldKeyWindow.rootViewController.supportedInterfaceOrientations;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.alertView resetTransition];
    [self.alertView invalidateLayout];
    [self.alertView resetOnOrientation:toInterfaceOrientation];
}

- (NSUInteger)supportedInterfaceOrientations
{
    
    
    return _oldSupportedInterfaceOrientations;  //UIInterfaceOrientationMaskAll; //self.supportedInterfaceOrientations;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return _oldShouldAutorotate; //NO;//self.shouldAutorotate;
}

- (BOOL)prefersStatusBarHidden
{
    return _rootViewControllerPrefersStatusBarHidden;
}
@end
