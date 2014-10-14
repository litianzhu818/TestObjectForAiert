

#import "AddDeviceMainViewController.h"

#import "BasicDefine.h"
#import "UIColor+AppTheme.h"
#import "InputDeviceInfoTableViewController.h"


#define kTextField2Keyboard 30

@interface AddDeviceMainViewController ()
{
    BOOL _viewHasDisappear;
}

@end

@implementation AddDeviceMainViewController

@synthesize subView;

@synthesize firstMethodTitleLabel;
@synthesize firstMethodDescriptionLabel;
@synthesize secondMethodTitleLabel;
@synthesize scanQrCodeButton;
@synthesize searchCameraIdButton;
@synthesize scanDeviceInLanButton;
@synthesize cameraIdField;

@synthesize errorImageView;
@synthesize errorLabel;

@synthesize busyView;
@synthesize activityIndicatorView;

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
    
    [self localizedSupport];
    
    self.view.backgroundColor = [UIColor AppThemeTableViewBackgroundColor];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //Keyboard
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
#ifdef __IPHONE_5_0
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 5.0) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
#endif
    
    [self hideError];
    [self showBusy:NO];
    
    _viewHasDisappear = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.cameraIdField resignFirstResponder];
    
    //Keyboard
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self showBusy:NO];
    
    _viewHasDisappear = YES;
}

#pragma mark - Localized Support

- (void)localizedSupport
{
    self.title = NSLocalizedString(@"添加摄像机",
                                   @"Add Device");
    self.firstMethodTitleLabel.text = NSLocalizedString(@"First Method",
                                                        @"First Method");
    self.firstMethodDescriptionLabel.text = NSLocalizedString(@"Scan the QR code on the label of camera or manually enter ID",
                                                              @"Scan the QR code on the label of camera or manually enter ID");
    [self.scanQrCodeButton setTitle:NSLocalizedString(@" Scan QR code",
                                                      @" Scan QR code")
                           forState:UIControlStateNormal];
    self.cameraIdField.placeholder = NSLocalizedString(@"Enter camera ID",
                                                       @"Enter camera ID");
    [self.scanDeviceInLanButton setTitle:NSLocalizedString(@" Search device in LAN",
                                                           @" Search device in LAN")
                                forState:UIControlStateNormal];
    self.secondMethodTitleLabel.text = NSLocalizedString(@"Second Method",
                                                         @"Second Method");
}

#pragma mark - Show and Hide Error
- (void)showError:(NSString *)message
{
    errorLabel.text = message;
    errorLabel.hidden = NO;
    errorImageView.hidden = NO;
}

- (void)hideError
{
    errorLabel.hidden = YES;
    errorImageView.hidden = YES;
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

//- (IBAction)backButton_TouchUpInside:(id)sender {
//    [self.navigationController popViewControllerAnimated:YES];
//}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AddDeviceMain2ScanQrCode"] ||
        [segue.identifier isEqualToString:@"AddDeviceMain2SearchInLan"]) {
        self.hidesBottomBarWhenPushed = YES;
    }
    else if([segue.identifier isEqualToString:@"AddDeviceMain2InputDevicePassword"])
    {
        self.hidesBottomBarWhenPushed = YES;
        InputDeviceInfoTableViewController *controller = segue.destinationViewController;
        if (controller) {
            controller.cameraId = cameraIdField.text;
        }
    }
}

#pragma mark - Show Busy

- (void)showBusy:(BOOL)busy
{
    if (busy) {
        [self.cameraIdField resignFirstResponder];
    }
    
    scanQrCodeButton.enabled = !busy;
    scanDeviceInLanButton.enabled = !busy;
    searchCameraIdButton.enabled = !busy;
    cameraIdField.enabled = !busy;
    
    busyView.hidden = !busy;
    if (busy) {
        [activityIndicatorView startAnimating];
    }
    else {
        [activityIndicatorView stopAnimating];
    }
}

- (IBAction)background_TouchDown:(id)sender
{
    [self.cameraIdField resignFirstResponder];
}

- (void)cameraIdField_PressDone:(id)sender
{
    [self searchCameraIdButton_TouchUpInside:nil];
}

#pragma mark - Button Function

- (IBAction)searchCameraIdButton_TouchUpInside:(id)sender
{
    if (cameraIdField.text.length != 10 && cameraIdField.text.length != 15) {
        [self showError:NSLocalizedString(@"Please enter ten or fifteen numbers camera ID",
                                          @"Please enter ten or fifteen numbers camera ID")];
        return;
    }
    
    [self hideError];
    [self showBusy:YES];
    
    if (!_viewHasDisappear) {
        [self performSegueWithIdentifier:@"AddDeviceMain2InputDevicePassword" sender:self];
        [self showBusy:NO];
    }
}

#pragma mark - Keyboard

- (void)keyboardWillShow:(NSNotification *)notification
{
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
    
    //Get Tabbar Height
    CGFloat tabBarHeight = 0;//self.tabBarController.tabBar.frame.size.height;
    
    //
    CGFloat y = ((self.view.frame.size.height + tabBarHeight - size) -
                 (cameraIdField.frame.origin.y + cameraIdField.frame.size.height +
                  kTextField2Keyboard));
    y = MIN(y, 0.0f);
    
    //
    CGRect frame = self.subView.frame;
    frame.origin = CGPointMake(frame.origin.x, y);
    //
    [UIView beginAnimations:@"Curl"context:nil];//动画开始
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:curve];
    [UIView setAnimationDelegate:self];
    [self.subView setFrame:frame];
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

    //
    CGRect frame = self.subView.frame;
    if (frame.origin.y < 0) {
        frame.origin = CGPointMake(frame.origin.x, 0);
        //
        [UIView beginAnimations:@"Curl"context:nil];//动画开始
        [UIView setAnimationDuration:animationDuration];
        [UIView setAnimationCurve:curve];
        [UIView setAnimationDelegate:self];
        [self.subView setFrame:frame];
        [UIView commitAnimations];
    }
    
}

@end
