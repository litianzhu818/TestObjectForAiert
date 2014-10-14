

#import "DeviceSettingTableViewController.h"

#import "BasicDefine.h"
#import "UIColor+AppTheme.h"

#import "UITableView+AppTheme.h"

#import "DeviceWifiSettingTableViewController.h"

@interface DeviceSettingTableViewController ()
{
    BOOL _viewHasDisappear;
    
    BOOL _busy;

    BOOL _modifyPasswordHidden;
    BOOL _modifyDeviceNameHidden;
    
    NSArray *_cellHeightList;
    
//    int viewHeight;
}

@end

@implementation DeviceSettingTableViewController

@synthesize currentDeviceName;

@synthesize modifyPasswordTitleLabel;
@synthesize modifyPasswordArrowImageView;
@synthesize modifyPasswordUserNameTitleLabel;
@synthesize modifyPasswordUserNameValueLablel;
@synthesize modifyPasswordOldPasswordTitleLabel;
@synthesize modifyPasswordOldPasswordField;
@synthesize modifyPasswordNewPasswordTitleLabel;
@synthesize modifyPasswordNewPasswordField;
@synthesize modifyPasswordConfirmPasswordTitleLabel;
@synthesize modifyPasswordComfirmPasswordField;
@synthesize modifyPasswordSubmitButton;
@synthesize modifyPasswordBusyView;
@synthesize modifyPasswordActivityIndicatorView;
@synthesize modifyPasswordErrorImageView;
@synthesize modifyPasswordErrorLabel;

@synthesize modifyDeviceNameTitleLabel;
@synthesize modifyDeviceNameArrowImageView;
@synthesize modifyDeviceNameNewNameTitleLabel;
@synthesize modifyDeviceNameNewNameField;
@synthesize modifyDeviceNameSubmitButton;
@synthesize modifyDeviceNameBusyView;
@synthesize modifyDeviceNameActivityIndicatorView;
@synthesize modifyDeviceNameErrorImageView;
@synthesize modifyDeviceNameErrorLabel;

@synthesize wifiSettingTitleLabel;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.clearsSelectionOnViewWillAppear = YES;
    [self.tableView hideExtraCellLine];
    
    [self localizedSupport];
    /*
     //
     //修正IOS7下导航栏按钮边距大的问题
     if (IOS7_OR_LATER) {
     //看起来没执行，实际有意义，由于"UINavigationItem+Margin.h"
     self.navigationItem.leftBarButtonItem = self.navigationItem.leftBarButtonItem;
     self.navigationItem.rightBarButtonItem = self.navigationItem.rightBarButtonItem;
     }
     */
    
    //RealZYC - 修正ios7下tableview的分割线不顶头的bug
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    self.view.backgroundColor = [UIColor AppThemeTableViewBackgroundColor];
    
    _viewHasDisappear = YES;
    _busy = NO;
    
    
    _cellHeightList = [[NSArray alloc] initWithObjects:
                       [NSNumber numberWithInt:44],
                       [NSNumber numberWithInt:14],
                       [NSNumber numberWithInt:33],
                       [NSNumber numberWithInt:33],
                       [NSNumber numberWithInt:33],
                       [NSNumber numberWithInt:33],
                       [NSNumber numberWithInt:81],
                       [NSNumber numberWithInt:44],
                       [NSNumber numberWithInt:17],
                       [NSNumber numberWithInt:33],
                       [NSNumber numberWithInt:81],
                       [NSNumber numberWithInt:44], nil];
    
    self.modifyPasswordHidden = YES;
    self.modifyDeviceNameHidden = YES;
    
//    viewHeight = 0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _viewHasDisappear = NO;
    [self showBusy:NO];
    
    [self hideErrorPassword];
    [self hideErrorDeviceName];
    
//    //
//    //Keyboard
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
//#ifdef __IPHONE_5_0
//    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
//    if (version >= 5.0) {
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
//    }
//#endif
    
    [self textFieldResignFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //Set Current Device Name
    self.modifyDeviceNameNewNameField.placeholder = currentDeviceName;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
//    //Keyboard
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    _viewHasDisappear = YES;
    [self showBusy:NO];
    [self textFieldResignFirstResponder];
}

#pragma mark - Localized Support

- (void)localizedSupport
{
    self.title = NSLocalizedString(@"Device Setting", @"Device Setting");
    //
    modifyPasswordTitleLabel.text = NSLocalizedString(@"Modify the device password", @"Modify the device password");
    modifyPasswordUserNameTitleLabel.text = NSLocalizedString(@"User Name", @"User Name");
    modifyPasswordOldPasswordTitleLabel.text = NSLocalizedString(@"Old Password", @"Old Password");
    modifyPasswordOldPasswordField.placeholder = NSLocalizedString(@"Enter Old Password", @"Enter Old Password");
    modifyPasswordNewPasswordTitleLabel.text = NSLocalizedString(@"New Password", @"New Password");
    modifyPasswordNewPasswordField.placeholder = NSLocalizedString(@"Enter New Password", @"Enter New Password");
    modifyPasswordConfirmPasswordTitleLabel.text = NSLocalizedString(@"Comfirm Password", @"Comfirm Password");
    modifyPasswordComfirmPasswordField.placeholder = NSLocalizedString(@"Comfirm Password", @"Comfirm Password");
    [modifyPasswordSubmitButton setTitle:NSLocalizedString(@"Submit", @"Submit")
                                forState:UIControlStateNormal];
    //
    modifyDeviceNameTitleLabel.text = NSLocalizedString(@"Modity the device name", @"Modity the device name");
    modifyDeviceNameNewNameTitleLabel.text = NSLocalizedString(@"Device Name", @"Device Name");
    modifyDeviceNameNewNameField.placeholder = @"";
    [modifyDeviceNameSubmitButton setTitle:NSLocalizedString(@"Submit", @"Submit")
                                forState:UIControlStateNormal];
    //
    wifiSettingTitleLabel.text = NSLocalizedString(@"Wi-Fi setting of device", @"Wi-Fi setting of device");

    //
    modifyPasswordOldPasswordField.placeHolderColor = [UIColor AppThemePlaceHolderColor];
    modifyPasswordNewPasswordField.placeHolderColor = [UIColor AppThemePlaceHolderColor];
    modifyPasswordComfirmPasswordField.placeHolderColor = [UIColor AppThemePlaceHolderColor];
    modifyDeviceNameNewNameField.placeHolderColor = [UIColor AppThemePlaceHolderColor];
    
    //
    modifyPasswordOldPasswordField.paddingLeft = 0;
    modifyPasswordNewPasswordField.paddingLeft = 0;
    modifyPasswordComfirmPasswordField.paddingLeft = 0;
    modifyDeviceNameNewNameField.paddingLeft = 0;
}

#pragma mark - Show And Hide Cell

- (BOOL)modifyPasswordHidden
{
    return _modifyPasswordHidden;
}

- (void)setModifyPasswordHidden:(BOOL)modifyPasswordHidden
{
    _modifyPasswordHidden = modifyPasswordHidden;
    for (int i = 1; i <= 6; i++) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        if (cell) {
            cell.hidden = _modifyPasswordHidden;
        }
    }
    [self.tableView reloadData];
    self.modifyPasswordArrowImageView.image = (_modifyPasswordHidden ?
                                               [UIImage imageNamed:@"icon_littlearrow_right.png"] :
                                               [UIImage imageNamed:@"icon_littlearrow_down.png"]);
}

- (BOOL)modifyDeviceNameHidden
{
    return _modifyDeviceNameHidden;
}

- (void)setModifyDeviceNameHidden:(BOOL)modifyDeviceNameHidden
{
    _modifyDeviceNameHidden = modifyDeviceNameHidden;
    for (int i = 8; i <= 10; i++) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        if (cell) {
            cell.hidden = _modifyDeviceNameHidden;
        }
    }
    [self.tableView reloadData];
    self.modifyDeviceNameArrowImageView.image = (_modifyDeviceNameHidden ?
                                               [UIImage imageNamed:@"icon_littlearrow_right.png"] :
                                                 [UIImage imageNamed:@"icon_littlearrow_down.png"]);
}

#pragma mark - Show Busy

- (void)showBusy:(BOOL)busy
{
    _busy = busy;
    if (busy) {
        [self textFieldResignFirstResponder];
    }
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if (cell) {
        cell.selectionStyle = busy ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleGray;
    }
    cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:7 inSection:0]];
    if (cell) {
        cell.selectionStyle = busy ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleGray;
    }
    cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:11 inSection:0]];
    if (cell) {
        cell.selectionStyle = busy ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleGray;
    }
    
    modifyPasswordOldPasswordField.enabled = !busy;
    modifyPasswordNewPasswordField.enabled = !busy;
    modifyPasswordComfirmPasswordField.enabled = !busy;
    modifyPasswordSubmitButton.enabled = !busy;
    
    modifyDeviceNameNewNameField.enabled = !busy;
    modifyDeviceNameSubmitButton.enabled = !busy;
    
    modifyPasswordBusyView.hidden = !busy;
    if (busy) {
        [modifyPasswordActivityIndicatorView startAnimating];
    }
    else {
        [modifyPasswordActivityIndicatorView stopAnimating];
    }
    
    modifyDeviceNameBusyView.hidden = !busy;
    if (busy) {
        [modifyDeviceNameActivityIndicatorView startAnimating];
    }
    else {
        [modifyDeviceNameActivityIndicatorView stopAnimating];
    }
}

#pragma mark - Show and Hide Error

- (void)showErrorPassword:(NSString *)message
{
    modifyPasswordErrorLabel.text = message;
    modifyPasswordErrorLabel.hidden = NO;
    modifyPasswordErrorImageView.hidden = NO;
}

- (void)hideErrorPassword
{
    modifyPasswordErrorLabel.hidden = YES;
    modifyPasswordErrorImageView.hidden = YES;
}

- (void)showErrorDeviceName:(NSString *)message
{
    modifyDeviceNameErrorLabel.text = message;
    modifyDeviceNameErrorLabel.hidden = NO;
    modifyDeviceNameErrorImageView.hidden = NO;
}

- (void)hideErrorDeviceName
{
    modifyDeviceNameErrorLabel.hidden = YES;
    modifyDeviceNameErrorImageView.hidden = YES;
}

#pragma mark - Button and Text Field

- (IBAction)modifyPasswordSubmitButton_TouchUpInside:(id)sender
{
    //TODO Core Change Password
    //Check Error
    if (modifyPasswordOldPasswordField.text.length == 0) {
        [self showErrorPassword:NSLocalizedString(@"Please enter old password", @"Please enter old password")];
        return;
    }
    else if (modifyPasswordNewPasswordField.text.length == 0)
    {
        [self showErrorPassword:NSLocalizedString(@"Please enter new password", @"Please enter new password")];
        return;
    }
    else if (modifyPasswordComfirmPasswordField.text.length == 0)
    {
        [self showErrorPassword:NSLocalizedString(@"Please confirm password", @"Please confirm password")];
        return;
    }
    else if (![modifyPasswordNewPasswordField.text
              isEqualToString:modifyPasswordComfirmPasswordField.text])
    {
        [self showErrorPassword:NSLocalizedString(@"Two password do not match", @"Two password do not match")];
        return;
    }
    
    //Hide Error And KeyBoard
    [self hideErrorPassword];
    [self textFieldResignFirstResponder];
    
    //Start Busy
    [self showBusy:YES];
    
    //Run WebInterface: Set busy and wait
    //TODO
    
    //Test
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!_viewHasDisappear) {
            //Test
            self.title = self.modifyPasswordNewPasswordField.text;
            
            self.modifyPasswordOldPasswordField.text = @"";
            self.modifyPasswordNewPasswordField.text = @"";
            self.modifyPasswordComfirmPasswordField.text = @"";
            
            //Hide Busy
            [self showBusy:NO];
        }

    });

}

- (IBAction)modifyDeviceNameSubmitButton_TouchUpInside:(id)sender
{
    //TODO Core Change Device Name
    //Check Error
    if (modifyDeviceNameNewNameField.text.length == 0) {
        [self showErrorDeviceName:NSLocalizedString(@"Please enter new device name", @"Please enter new device name")];
        return;
    }
    
    //Hide Error And KeyBoard
    [self hideErrorDeviceName];
    [self textFieldResignFirstResponder];
    
    //Start Busy
    [self showBusy:YES];
    
    //Run WebInterface: Set busy and wait
    //TODO
    
    //Test
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!_viewHasDisappear) {
            //Test
            self.currentDeviceName = self.modifyDeviceNameNewNameField.text;
            self.modifyDeviceNameNewNameField.placeholder = self.currentDeviceName;
            
            //
            self.modifyDeviceNameNewNameField.text = @"";
            
            //Hide Busy
            [self showBusy:NO];
        }
    });
}

- (IBAction)modifyPasswordOldPasswordField_PressNext:(id)sender
{
    [modifyPasswordNewPasswordField becomeFirstResponder];
}

- (IBAction)modifyPasswordNewPasswordField_PressNext:(id)sender
{
    [modifyPasswordComfirmPasswordField becomeFirstResponder];
}

- (IBAction)modifyPasswordComfirmPasswordField_PressDone:(id)sender
{
    [self modifyPasswordSubmitButton_TouchUpInside:self];
}

- (IBAction)modifyDeviceNameNewNameField_PressDone:(id)sender
{
    [self modifyDeviceNameSubmitButton_TouchUpInside:self];
}

- (void)textFieldResignFirstResponder
{
    [modifyPasswordOldPasswordField resignFirstResponder];
    [modifyPasswordNewPasswordField resignFirstResponder];
    [modifyPasswordComfirmPasswordField resignFirstResponder];
    [modifyDeviceNameNewNameField resignFirstResponder];
}

#pragma mark - Table view Delefate and Data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    if (0 == row || 7 == row || 11 == row) {
        return [[_cellHeightList objectAtIndex:row] integerValue];
    }
    else
    {
        if (row < 7) {
            return self.modifyPasswordHidden ? 0 : [[_cellHeightList objectAtIndex:row] integerValue];
        }
        else {
            return self.modifyDeviceNameHidden ? 0 : [[_cellHeightList objectAtIndex:row] integerValue];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_busy) {
        return;
    }
    
    NSInteger row = indexPath.row;
    if (0 == row) {
        self.modifyPasswordHidden = !self.modifyPasswordHidden;
        [self.tableView selectRowAtIndexPath:nil animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
    else if (7 == row) {
        self.modifyDeviceNameHidden = !self.modifyDeviceNameHidden;
        [self.tableView selectRowAtIndexPath:nil animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
    else if (11 == row) {
        //Do nothing
    }
    else { //Tap Background
        [self textFieldResignFirstResponder];
    }
}

//Need for iPad
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //解决在ipad上背景不透明的问题
    //http://www.myexception.cn/operating-system/1446505.html
    [cell setBackgroundColor:[UIColor clearColor]];
}

#pragma mark - Autorotate

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

#pragma mark - Navigation

- (IBAction)backButton_TouchUpInside:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Setting2WifiSetting"]) {        
        self.hidesBottomBarWhenPushed = YES;
        
        //Test
        DeviceWifiSettingTableViewController *viewController = segue.destinationViewController;
        if (viewController) {
            //TODO Core
            //Test Open Next Page WLAN
            //viewController.wifiOn = YES;
        }
    }
}


#pragma mark - Keyboard

//- (void)keyboardWillShow:(NSNotification *)notification
//{
//    if (viewHeight < 0 || viewHeight < self.view.frame.size.height) {
//        viewHeight = self.view.frame.size.height;
//    }
//    
//    NSDictionary *userInfo = [notification userInfo];
//    
//    // Get the origin of the keyboard when it's displayed.
//    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
//    
//    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
//    CGRect keyboardRect = [aValue CGRectValue];
//    
//    // Get the duration of the animation.
//    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
//    NSTimeInterval animationDuration;
//    [animationDurationValue getValue:&animationDuration];
//    UIViewAnimationCurve curve;
//    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&curve];
//    
//    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
//    //CGFloat size = MIN(keyboardRect.size.height, keyboardRect.size.width);
//    CGFloat size = [self.view convertRect:keyboardRect fromView:nil].size.height;
//    
//    CGRect frame = self.view.frame;
//    frame.size = CGSizeMake(frame.size.width, viewHeight - size);
//    [UIView beginAnimations:@"Curl"context:nil];//动画开始
//    [UIView setAnimationDuration:animationDuration];
//    [UIView setAnimationCurve:curve];
//    [UIView setAnimationDelegate:self];
//    [self.view setFrame:frame];
//    [UIView commitAnimations];
//    
//}
//
//- (void)keyboardWillHide:(NSNotification *)notification {
//    NSDictionary *userInfo = [notification userInfo];
//    // Get the duration of the animation.
//    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
//    NSTimeInterval animationDuration;
//    [animationDurationValue getValue:&animationDuration];
//    UIViewAnimationCurve curve;
//    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&curve];
//    
//    if (viewHeight > 0) {
//        [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
//        [UIView setAnimationDuration:animationDuration];
//        [UIView setAnimationCurve:curve];
//        CGRect rect = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y,
//                                 self.view.frame.size.width, viewHeight);
//        self.view.frame = rect;
//        
//        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
//                              atScrollPosition:UITableViewScrollPositionTop animated:YES];
//        
//        [UIView commitAnimations];
//    }
//    
//}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == modifyPasswordComfirmPasswordField) {
        [self modifyPasswordSubmitButton_TouchUpInside:self];
        return NO;
    }
    else if (textField == modifyDeviceNameNewNameField) {
        [self modifyDeviceNameSubmitButton_TouchUpInside:self];
        return NO;
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    /*
     CGRect frame = CGRectMake(textField.frame.origin.x, textField.frame.origin.y+self.ChangePasswordCell.frame.origin.y, textField.frame.size.width, textField.frame.size.height);
     
     int offset = frame.origin.y + 98 - (self.view.frame.size.height - 216.0);//键盘高度216
     NSTimeInterval animationDuration = 0.30f;
     [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];
     [UIView setAnimationDuration:animationDuration];
     float width = self.view.frame.size.width;
     float height = self.view.frame.size.height;
     if(offset > 0)
     {
     CGRect rect = CGRectMake(0.0f, -offset,width,height);
     self.view.frame = rect;
     }
     [UIView commitAnimations];
     */
    
    [self performSelector:@selector(checkAndScroll:) withObject:textField afterDelay:0.31f];
    
}

- (void)checkAndScroll:(UITextField *)textField
{
    int row = 0;
    
    if (textField == modifyPasswordOldPasswordField) {
        row = 3;
    }
    else if (textField == modifyPasswordNewPasswordField) {
        row = 4;
    }
    else if (textField == modifyPasswordComfirmPasswordField) {
        row = 5;
    }
    else if (textField == modifyDeviceNameNewNameField) {
        row = 9;
    }
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

@end
