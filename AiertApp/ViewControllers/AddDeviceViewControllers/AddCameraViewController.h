//
//  AddCameraViewController.h
//  AiertApp
//
//  Created by Peter Lee on 14/9/13.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "BaseViewController.h"
#import "ScanQrCodeViewController.h"

#define VIEW_MOVE_WIDTH 35.0f

typedef void(^FinishedBlock)(AiertDeviceInfo *deviceInfo);

@interface AddCameraViewController : BaseViewController<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UIView *inpuBgView;
@property (strong, nonatomic) IBOutlet UITextField *nameField;
@property (strong, nonatomic) IBOutlet UITextField *deviceIDField;
@property (strong, nonatomic) IBOutlet UITextField *userNameField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;

@property (assign, nonatomic) BOOL isKeyBoardShow;
@property (strong, nonatomic) AiertDeviceInfo *deviceInfo;
@property (strong, nonatomic) FinishedBlock finishedBlock;

-(IBAction)clikedOnOkButton:(id)sender;

@end
