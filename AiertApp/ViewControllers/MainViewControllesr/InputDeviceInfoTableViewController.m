

#import "InputDeviceInfoTableViewController.h"
#import "BasicDefine.h"
#import "UIColor+AppTheme.h"
#import "UITableView+AppTheme.h"
#import "AppData.h"
#import "ZMDevice.h"
#import "ZSWebInterface.h"
#import "SVProgressHUD.h"
#import "NSDictionary+Request.h"

@interface InputDeviceInfoTableViewController ()
{
    int viewHeight;
}
@end

@implementation InputDeviceInfoTableViewController

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
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    self.view.backgroundColor = [UIColor AppThemeTableViewBackgroundColor];
    self.deviceNameField.textColor = [UIColor AppThemeSelectedTextColor];
    self.deviceNameField.placeHolderColor = [UIColor AppThemePlaceHolderColor];
    self.passwordTextField.placeHolderColor = [UIColor AppThemePlaceHolderColor];
    self.passwordTextField.textColor = [UIColor AppThemeSelectedTextColor];
    viewHeight = 0;
    
    [self checkEnalbed];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.deviceNameField.text = self.cameraId;
    self.passwordTextField.text = @"";
    
    //Keyboard
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
#ifdef __IPHONE_5_0
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 5.0) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillChangeFrameNotification
                                                   object:nil];
    }
#endif
    
    [self hideError];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self textFieldResignFirstResponder];
    
    //Keyboard
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//Need for iPad
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //解决在ipad上背景不透明的问题
    //http://www.myexception.cn/operating-system/1446505.html
    [cell setBackgroundColor:[UIColor clearColor]];
}

#pragma mark - Show and Hide Error
- (void)showError:(NSString *)message
{
    self.errorLabel.text = message;
    self.errorLabel.hidden = NO;
    self.errorImageView.hidden = NO;
}

- (void)hideError
{
    self.errorLabel.hidden = YES;
    self.errorImageView.hidden = YES;
}


#pragma mark - Localized Support

- (void)localizedSupport
{
    self.title = NSLocalizedString(@"Add Device", @"Add Device");
    self.deviceNameLabel.text = NSLocalizedString(@"Device Name", @"Device Name");
    self.deviceNameField.placeholder = @"0123456789";
    self.passwordTextField.placeholder = NSLocalizedString(@"Password", @"Password");
    self.passwordLabel.text = NSLocalizedString(@"Password", @"Password");
    [self.submitButton setTitle:NSLocalizedString(@"Submit", @"Submit")
                       forState:UIControlStateNormal];
}

#pragma mark - TableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self textFieldResignFirstResponder];
}

#pragma mark - Submit

- (IBAction)submitButton_TouchUpInside:(id)sender
{
    [self textFieldResignFirstResponder];
    
    if (self.deviceNameField.text.length == 0) {
        [self showError:NSLocalizedString(@"Please enter device name",
                                          @"Please enter device name")];
        return;
    }
    
    [self hideError];
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Submitting...", @"Submitting...")
                         maskType:SVProgressHUDMaskTypeBlack];
    
    [ZSWebInterface addDeviceWithDeviceId:self.cameraId
                               deviceName:self.deviceNameField.text
                                 accessName:@"admin"
                                 password:self.passwordTextField.text
                                    scene:1
                              description:@""
                                  success:^(NSDictionary *data) {
                                      [SVProgressHUD dismiss];
                                      
                                      DLog(@"addDevice response============> %@",data);

                                      ZMDevice *device = [[ZMDevice alloc] initWithDeviceId:self.cameraId
                                                                                   password:self.passwordTextField.text
                                                                                 deviceName:self.deviceNameField.text
                                                                               channelCount:1];
                                      
                                      if ([AppData addDevice:device]) {
                                          [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"DevicesUpdated"
                                                                                                                               object:nil]];
                                      }
                                      
                                      [self.navigationController popToRootViewControllerAnimated:YES];

                                  } failure:^(NSDictionary *data) {
                                      
                                      NSString *strResult = [data strResult];
                                      if ([strResult isEqualToString:WebInterface_Result_NetworkError]) {
                                          [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Link server failure",
                                                                                               @"Link server failure")];
                                      }
                                      else {
                                          [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Incorrect user name or password",
                                                                                               @"Incorrect user name or password")];
                                          
                                      }

                                  }];
    
}

- (IBAction)deviceNameField_PressNext:(id)sender
{
    [self.passwordTextField becomeFirstResponder];
    [self checkEnalbed];
}

- (IBAction)passwordTextField_PressDone:(id)sender
{
    [self textFieldResignFirstResponder];
    
    [self checkEnalbed];
    [self submitButton_TouchUpInside:nil];
}

#pragma mark - TextField

- (void) textFieldResignFirstResponder
{
    [self.deviceNameField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}
- (IBAction)input_TextChanged:(id)sender
{
    [self checkEnalbed];
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

#pragma mark - Keyboard

- (void)keyboardWillShow:(NSNotification *)notification
{
    if (viewHeight < 0 || viewHeight < self.view.frame.size.height) {
        viewHeight = self.view.frame.size.height;
    }
    
    NSDictionary *userInfo = [notification userInfo];
    
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    UIViewAnimationCurve curve;
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&curve];
    
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    //CGFloat size = MIN(keyboardRect.size.height, keyboardRect.size.width);
    CGFloat size = [self.view convertRect:keyboardRect fromView:nil].size.height;
    
    CGRect frame = self.view.frame;
    frame.size = CGSizeMake(frame.size.width, viewHeight - size);
    [UIView beginAnimations:@"Curl"context:nil];//动画开始
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:curve];
    [UIView setAnimationDelegate:self];
    [self.view setFrame:frame];
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]
                          atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    
    [UIView commitAnimations];
    
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    UIViewAnimationCurve curve;
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&curve];
    
    if (viewHeight > 0) {
        [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
        [UIView setAnimationDuration:animationDuration];
        [UIView setAnimationCurve:curve];
        CGRect rect = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y,
                                 self.view.frame.size.width, viewHeight);
        self.view.frame = rect;
        
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                              atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
        [UIView commitAnimations];
    }
}

- (void)checkEnalbed
{
    if ([self.deviceNameField.text length] > 0 &&
        [self.passwordTextField.text length] > 0) {
        [self.submitButton setEnabled:YES];
    }
    else{
        [self.submitButton setEnabled:NO];
    }
}
@end
