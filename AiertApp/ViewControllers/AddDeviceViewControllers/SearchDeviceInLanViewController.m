

#import "SearchDeviceInLanViewController.h"
#import "BasicDefine.h"
#import "UIColor+AppTheme.h"
#import "SearchDeviceInLanCell.h"
#import "InputDeviceInfoTableViewController.h"
#import "UITableView+AppTheme.h"
#import "Reachability.h"
#import "SVProgressHUD.h"

#define kTextField2Keyboard 30

@interface SearchDeviceInLanViewController ()
{
    dispatch_queue_t pingQueue;
    
    BOOL _viewHasDisappear;
    
    BOOL needStopSearchViews;
}
@property (strong, nonatomic) UIView *maskActivityIndicatorViewTop;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorViewTop;
@property (strong, nonatomic) PingLocalNetWorkProtocal *pingProtocol;
@property (strong, nonatomic) NSMutableArray *deviceList;
@property (strong, nonatomic) NSString *cameraId;
@end

@implementation SearchDeviceInLanViewController

@synthesize subView;
@synthesize tableView;
@synthesize scanQrCodeButton;
@synthesize searchCameraIdButton;
@synthesize cameraIdField;

@synthesize errorImageView;
@synthesize errorLabel;
@synthesize busyView;

@synthesize refreshButton;

@synthesize foundNoneDescriptionLabel;

- (void)dealloc
{
    pingQueue = nil;
}

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
    //self.view.backgroundColor = [UIColor AppThemeTableViewBackgroundColor];
    self.tableView.backgroundColor = [UIColor AppThemeTableViewBackgroundColor];
    needStopSearchViews = NO;
    
    self.maskActivityIndicatorViewTop = [[UIView alloc] initWithFrame:CGRectMake(0, 0,
                                                                                 self.refreshButton.frame.size.width,
                                                                                 self.refreshButton.frame.size.height)];
    self.maskActivityIndicatorViewTop.backgroundColor = [UIColor clearColor];
    self.maskActivityIndicatorViewTop.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                                          UIViewAutoresizingFlexibleHeight);
    
    self.activityIndicatorViewTop = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.activityIndicatorViewTop.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                                      UIViewAutoresizingFlexibleRightMargin |
                                                      UIViewAutoresizingFlexibleTopMargin |
                                                      UIViewAutoresizingFlexibleBottomMargin);
    self.activityIndicatorViewTop.frame = CGRectMake(10,10,0,0);
    [self.maskActivityIndicatorViewTop addSubview:self.activityIndicatorViewTop];
    
    [self.refreshButton addSubview:self.maskActivityIndicatorViewTop];
    [self.maskActivityIndicatorViewTop setHidden:YES];

    
    pingQueue = dispatch_queue_create("pingQueue1", NULL);
    
    self.pingProtocol = [[PingLocalNetWorkProtocal alloc] initWithDeviceId:nil];
    self.pingProtocol.pingLocalNetWorkProtocalDelegate = self;

//    [self pingLocalNetwork];
    [self refreshButton_TouchUpInside:nil];
    
    self.deviceList = [[NSMutableArray alloc] initWithCapacity:8];
    [self.tableView hideExtraCellLine];
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
#ifdef __IPHONE_5_0
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 5.0) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
#endif
    
    [self hideError];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self showTableView:YES];
    
    _viewHasDisappear = NO;
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self textFieldResignFirstResponder];
    
    //Keyboard
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //
    //self.hidesBottomBarWhenPushed = NO;
    
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    
    _viewHasDisappear = YES;
}

- (void)pingLocalNetwork
{
    __weak SearchDeviceInLanViewController *tempSelf = self;
    
    if (ReachableViaWiFi == [[Reachability reachabilityForLocalWiFi] currentReachabilityStatus]) {
        dispatch_async(pingQueue, ^{
            [tempSelf.pingProtocol pingLocalDevicesWithBindPort:2335];
        });
    }else
    {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Wifi不可用!",
                                                             @"Wifi is not available!")];
    }
}

#pragma mark - Show & Hide

- (void)showTableView:(BOOL)show
{
    self.tableView.hidden = !show;
    self.subView.hidden = show;
}

#pragma mark - Localized Support

- (void)localizedSupport
{
    self.title = NSLocalizedString(@"搜索设备", @"Search device in LAN");
    self.foundNoneDescriptionLabel.text = NSLocalizedString(@"没有搜索到任何设备，你可以检查设备是否连接在局域网中，或者改用其他方式添加设备", @"No camera is searched in LAN, please check whether the device is connected properly, or try other method to add camera");
    
    [self.scanQrCodeButton setTitle:NSLocalizedString(@" Scan QR code", @" Scan QR code")
                           forState:UIControlStateNormal];
    self.cameraIdField.placeholder = NSLocalizedString(@"Enter camera ID", @"Enter camera ID");
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    aTableView.separatorStyle = (self.deviceList.count > 0) ? UITableViewCellSeparatorStyleSingleLine : UITableViewCellSeparatorStyleNone;
    // Return the number of sections.
    return self.deviceList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SearchDeviceInLanCell";
    SearchDeviceInLanCell *cell;
    cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [SearchDeviceInLanCell cellFromXib];
    }
    
    cell.titleLabel.text = self.deviceList[indexPath.row];
    cell.mainImageView.image = [UIImage imageNamed:@"list_ipc_offline.png"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.cameraId = self.deviceList[indexPath.row];
    [self performSegueWithIdentifier:@"SearchInLan2InputDevicePassword" sender:self];
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

- (IBAction)refreshButton_TouchUpInside:(id)sender {
  
    [self showBusy:YES];
    
    [self pingLocalNetwork];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SearchInLan2InputDevicePassword"]) {
        self.hidesBottomBarWhenPushed = YES;
        
        InputDeviceInfoTableViewController *controller = segue.destinationViewController;
        if (controller) {
            controller.cameraId = self.cameraId;
        }
    }
}

#pragma mark - Show Busy

- (void)showBusy:(BOOL)busy
{
    if (busy) {
        [self textFieldResignFirstResponder];
        [NSTimer scheduledTimerWithTimeInterval:20.0f target:self selector:@selector(stopSearchDeviceViewAnimation) userInfo:nil repeats:NO];
    }
    
    scanQrCodeButton.enabled = !busy;
    searchCameraIdButton.enabled = !busy;
    cameraIdField.enabled = !busy;
    refreshButton.enabled = !busy;
    
    busyView.hidden = !busy;
    needStopSearchViews = busy;
    
    self.maskActivityIndicatorViewTop.hidden = !busy;
    
    if (busy) {
        [self.refreshButton setImage:nil forState:UIControlStateNormal];
        [self.activityIndicatorViewTop startAnimating];
    }
    else {
        [self.activityIndicatorViewTop stopAnimating];
        UIImage *refreshImage = [UIImage imageNamed:@"navigationbar_refresh_unselected"];
        [self.refreshButton setImage:refreshImage forState:UIControlStateNormal];
    }
}

#pragma mark - TextField

- (void) textFieldResignFirstResponder
{
    [cameraIdField resignFirstResponder];
}

- (IBAction)background_TouchDown:(id)sender
{
    [self textFieldResignFirstResponder];
}

- (void)cameraIdField_PressDone:(id)sender
{
    [self searchCameraIdButton_TouchUpInside:self];
}

#pragma mark - Button Function

- (IBAction)searchCameraIdButton_TouchUpInside:(id)sender
{
    [self textFieldResignFirstResponder];
    
    if (cameraIdField.text.length != 10 && cameraIdField.text.length != 15) {
        [self showError:NSLocalizedString(@"Please enter ten or fifteen numbers camera ID",
                                          @"Please enter ten or fifteen numbers camera ID")];
        return;
    }
    
    [self hideError];
    [self showBusy:YES];
    
    self.cameraId = cameraIdField.text;
    
    
    if (!_viewHasDisappear) {
        [self performSegueWithIdentifier:@"SearchInLan2InputDevicePassword" sender:self];
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
//停止视图的转动
- (void)stopSearchDeviceViewAnimation
{
    if (!needStopSearchViews) {
        return;
    }
    
    MAIN_GCD(^{
        [self showBusy:NO];
    });
    
}

#pragma mark - PingProtocol delegate
- (void)didFindTheDevice:(NSDictionary *)devInfoDict
{
    NSString *tempId = [devInfoDict objectForKey:kDeviceID];
    LOG(@"已经发现设备，设备ID:%@",tempId);
    needStopSearchViews = NO;
    if (![self.deviceList containsObject:tempId]) {
        
        [self.deviceList addObject:tempId];
    }
    
    __weak SearchDeviceInLanViewController *tempSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [tempSelf showBusy:NO];
        [tempSelf.tableView reloadData];
    });
}

@end
