//
//  AddCameraViewController.m
//  AiertApp
//
//  Created by Peter Lee on 14/9/13.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "AddCameraViewController.h"

@interface AddCameraViewController ()

@end

@implementation AddCameraViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self initGesture];
    [self initNotifications];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.view removeGestureRecognizer:_tapGestureRecognizer];
    [self removeNotifications];
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
    [self initUI];
    [self initData];
}
-(void)initUI
{
    [self.navigationItem setTitle:@"添加摄像机"];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(clikedOnOkButton:)];
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(clikedOnBackButton:)];
//    [self.navigationItem.leftBarButtonItem setImage:self.navigationItem.backBarButtonItem];
    
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    self.tableView.layer.cornerRadius = 6.0f;
    self.tableView.layer.borderWidth = 0.2f;
    self.tableView.layer.borderColor = [self.tableView backgroundColor].CGColor;
    self.tableView.layer.masksToBounds = YES;
    
    self.inpuBgView.layer.cornerRadius = 6.0f;
    self.inpuBgView.layer.borderWidth = 0.2f;
    self.inpuBgView.layer.borderColor = [self.tableView backgroundColor].CGColor;
    
    self.inpuBgView.layer.masksToBounds = YES;
    [self.view bringSubviewToFront:self.tableView];
    
    
}
-(void)initData
{
    _isKeyBoardShow = NO;
}

-(IBAction)clikedOnOkButton:(id)sender
{
    [self hidenKeyboard];
    
    if ([self checkUserInputData]) {
        self.deviceInfo = [[AiertDeviceInfo alloc] initWithDeviceName:self.nameField.text
                                                             deviceID:self.deviceIDField.text
                                                             userName:self.userNameField.text
                                                         userPassword:self.passwordField.text];
        LOG(@"%@",self.deviceInfo);
        if (self.finishedBlock) {
            self.finishedBlock(self.deviceInfo);
        }
        
        //存数据库中
        [[myAppDelegate aiertDeviceCoreDataManager] addDeviceWithDeviceInfo:self.deviceInfo];
        
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    [self showMessage:@"您输入的信息不完整，请检查后补全输入" title:@"提示" cancelButtonTitle:@"知道了" cancleBlock:^{
    }];
}
//初始化手势
-(void)initGesture
{
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidenKeyboard)];
    [self.defaultImageView addGestureRecognizer:_tapGestureRecognizer];
}

-(void)initNotifications
{
    //注册键盘出现通知
    [NotificationCenter addObserver:self selector:@selector (keyboardWillShow:)
                               name: UIKeyboardWillShowNotification object:nil];
    //注册键盘隐藏通知
	[NotificationCenter addObserver:self selector:@selector (keyboardWillHide:)
                               name: UIKeyboardWillHideNotification object:nil];
}

-(void)removeNotifications
{
    //解除键盘出现通知
    [NotificationCenter removeObserver:self
                                  name: UIKeyboardWillShowNotification object:nil];
    //解除键盘隐藏通知
    [NotificationCenter removeObserver:self
                                  name: UIKeyboardWillHideNotification object:nil];
}

-(void) keyboardWillShow: (NSNotification *)notification
{
    
	if (_isKeyBoardShow) {//键盘已经出现要忽略通知
		return;
	}
	// 获得键盘尺寸
	NSDictionary* info = [notification userInfo];
	//NSValue* aValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
	NSNumber *number = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationTime = [number doubleValue];
	//CGSize keyboardSize = [aValue CGRectValue].size;
	
    CGRect frame = self.view.frame;
    frame.origin.y -= VIEW_MOVE_WIDTH;//view的Y轴上移
    frame.size.height += VIEW_MOVE_WIDTH; //View的高度增加
    
    [UIView animateWithDuration:animationTime animations:^{
        self.view.frame = frame;
    } completion:^(BOOL finished) {
        _isKeyBoardShow = YES;
    }];
}

-(void) keyboardWillHide: (NSNotification *)notification
{
    
    NSDictionary* info = [notification userInfo];
	//NSValue* aValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    NSNumber *number = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationTime = [number doubleValue];
	//CGSize keyboardSize = [aValue CGRectValue].size;
	
    CGRect frame = self.view.frame;
    frame.origin.y += VIEW_MOVE_WIDTH;//view的Y轴上移
    frame.size.height -= VIEW_MOVE_WIDTH; //View的高度增加
    
    [UIView animateWithDuration:animationTime animations:^{
        self.view.frame = frame;
    } completion:^(BOOL finished) {
        if (!_isKeyBoardShow) {
            return;
        }
        _isKeyBoardShow = NO;
    }];
}

-(BOOL)checkUserInputData
{
    if ([self.nameField.text isEqualToString:@""] || [self.deviceIDField.text isEqualToString:@""] || [self.userNameField.text isEqualToString:@""] || [self.passwordField.text isEqualToString:@""]) {
        return NO;
    }
    return YES;
}

-(void)hidenKeyboard
{
    [self.nameField resignFirstResponder];
    [self.deviceIDField resignFirstResponder];
    [self.userNameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
}

-(void)refreshUIWithDeviceInfo:(AiertDeviceInfo *)deviceInfo
{
    MAIN_GCD(^{
        if (deviceInfo.deviceName) {
            [self.nameField setText:deviceInfo.deviceName];
        }
        if (deviceInfo.deviceID) {
            [self.deviceIDField setText:deviceInfo.deviceID];
        }
        if (deviceInfo.userInfo.userName) {
            [self.userNameField setText:deviceInfo.userInfo.userName];
        }
        if (deviceInfo.userInfo.userPassword) {
            [self.passwordField setText:deviceInfo.userInfo.userPassword];
        }
    });
}

#pragma mark -
#pragma mark - UITextFieldDelegate Methods
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [self hidenKeyboard];
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self hidenKeyboard];
    return YES;
}

#pragma mark -
#pragma mark - UITableViewDataSource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil){
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
	if (indexPath.row == 0) {
        [cell.imageView setImage:PNG_NAME(@"qr")];
        [cell.textLabel setText:@"扫描条码"];
    }
    if (indexPath.row == 1) {
        [cell.imageView setImage:PNG_NAME(@"search")];
        [cell.textLabel setText:@"搜索"];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
	return cell;
}

#pragma mark -
#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            [self performSegueWithIdentifier:@"QR" sender:nil];
            break;
        case 1:
            [self performSegueWithIdentifier:@"SEARCH" sender:nil];
            break;
        default:
            break;
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"QR"]) {
        ScanQrCodeViewController *readerViewController = [segue destinationViewController];
        [readerViewController setFinishBlock:^(AiertDeviceInfo *deviceInfo) {
            LOG(deviceInfo.description);
            [self refreshUIWithDeviceInfo:deviceInfo];
        }];
    }
}


@end
