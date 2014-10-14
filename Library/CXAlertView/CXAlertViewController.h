//
//  CXAlertViewController.h
//  CXAlertViewDemo
//
//  Created by Peter Lee on 14/9/13.
//  Copyright (c) 2013年 爱尔特电子有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CXAlertView.h"

@interface CXAlertViewController : UIViewController

@property (nonatomic, strong) CXAlertView *alertView;

@property (nonatomic, assign) BOOL rootViewControllerPrefersStatusBarHidden;

@end
