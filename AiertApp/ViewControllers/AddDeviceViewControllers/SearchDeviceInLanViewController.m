

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

    [self refreshButton_TouchUpInside:nil];
    
    self.deviceList = [NSMutableArray array];
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
        
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self showTableView:YES];
    
    _viewHasDisappear = NO;
    [[myAppDelegate aiertDeviceCoreDataManager] addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
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
    [[myAppDelegate aiertDeviceCoreDataManager] removeDelegate:self delegateQueue:dispatch_get_main_queue()];
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
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    tableView.separatorStyle = (self.deviceList.count > 0) ? UITableViewCellSeparatorStyleSingleLine : UITableViewCellSeparatorStyleNone;
    // Return the number of sections.
    return self.deviceList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65.0;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    
    //remove all subview into
    for(UIView *subView in cell.contentView.subviews){
        [subView removeFromSuperview];
    }

    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *dictionary = [self.deviceList objectAtIndex:indexPath.row];
    AiertDeviceInfo *deviceInfo = [dictionary objectForKey:@"device"];
    BOOL deviceTag = [(NSNumber *)[dictionary objectForKey:@"deviceTag"] integerValue] > 0;
    
    UIFont *font = [UIFont systemFontOfSize:14.0];
    CGRect frame = cell.contentView.frame;
    NSString *device_status = nil;
    
    UILabel *deviceName = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN_WIDTH, MARGIN_WIDTH, FRAME_W(frame), FRAME_H(frame)/2)];
    UILabel *deviceID = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN_WIDTH,MARGIN_WIDTH + FRAME_H(frame)/2, FRAME_W(frame), FRAME_H(frame)/2)];
    [deviceName setText:[NSString stringWithFormat:@"%@%@",@"NAME:",deviceInfo.deviceName]];
    NSString *IDTitle = [NSString stringWithFormat:@"%@%@",@"ID:",deviceInfo.deviceID];
    [deviceName setFont:font];
    [deviceID setFont:font];
    
    NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:IDTitle attributes:@{NSForegroundColorAttributeName: [UIColor blackColor], NSFontAttributeName:font}];
    [attributedTitle addAttribute:NSForegroundColorAttributeName
                            value:[UIColor colorWithRed:0.122 green:0.475 blue:0.992 alpha:1.000]
                            range:[attributedTitle.string.lowercaseString rangeOfString:deviceInfo.deviceID.lowercaseString]];
    [deviceID setAttributedText:attributedTitle];
    
    [cell.contentView addSubview:deviceName];
    [cell.contentView addSubview:deviceID];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTag:indexPath.row];
    [button setFrame:CGRectMake(0, 0, 60, 40)];
    [button setTintColor:[UIColor whiteColor]];
    button.layer.borderWidth = 0.2f;
    button.layer.cornerRadius = 6.0f;
    button.layer.borderColor = button.backgroundColor.CGColor;
    if (deviceTag){
        [button setBackgroundColor:[UIColor lightGrayColor]];
        [button setTitle:@"已添加" forState:UIControlStateNormal];
    }
    else{
        [button setBackgroundColor:[UIColor redColor]];
        [button setTitle:@"添加" forState:UIControlStateNormal];
    }
    [button setEnabled:!deviceTag];
    [button addTarget:self action:@selector(addDevice:) forControlEvents:UIControlEventTouchUpInside];
    cell.accessoryView = button;
    
    cell.selectionStyle = UITableViewCellEditingStyleNone;

}

-(void)addDevice:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    NSMutableDictionary *dictionary = [self.deviceList objectAtIndex:btn.tag];
    AiertDeviceInfo *deviceInfo = [dictionary objectForKey:@"device"];
    
    [SVProgressHUD showWithStatus:@"正在添加..." maskType:SVProgressHUDMaskTypeBlack];
    
    [[myAppDelegate aiertDeviceCoreDataManager] addDeviceWithDeviceInfo:deviceInfo];
    
    [btn setBackgroundColor:[UIColor lightGrayColor]];
    [btn setTitle:@"已添加" forState:UIControlStateNormal];
    [btn setEnabled:NO];
    [dictionary setValue:[NSNumber numberWithInt:1] forKey:@"deviceTag"];
    
    if (_delegate && [_delegate respondsToSelector:@selector(searchDeviceInLanController:didAddDevice:)]) {
        [_delegate searchDeviceInLanController:self didAddDevice:deviceInfo];
    }
}

#pragma mark - Show and Hide Error
/*
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
*/
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

#pragma mark - Show Busy

- (void)showBusy:(BOOL)busy
{
    if (busy) {
        [self textFieldResignFirstResponder];
        [NSTimer scheduledTimerWithTimeInterval:20.0f target:self selector:@selector(stopSearchDeviceViewAnimation) userInfo:nil repeats:NO];
    }
    
    refreshButton.enabled = !busy;
    
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
    
}

- (IBAction)background_TouchDown:(id)sender
{
    [self textFieldResignFirstResponder];
}

#pragma mark - Button Function

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
- (void)aiertDeviceCoreDataManager:(AiertDeviceCoreDataManager *)aiertDeviceCoreDataManager didAddDeviceWithDictionary:(NSDictionary *)dic
{
    
    [SVProgressHUD dismissWithSuccess:@"添加成功"];
    
}
#pragma mark - PingProtocol delegate
- (void)didFindTheDeviceWithInfo:(AiertDeviceInfo *)device
{
    if ([self deviceHasBeenExistWithID:device.deviceID]) {
        return;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:device,@"device",[NSNumber numberWithBool:[self deviceHasBeenAddedWithID:device.deviceID]],@"deviceTag", nil];
    [self.deviceList addObject:dic];
    
    __weak SearchDeviceInLanViewController *tempSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [tempSelf showBusy:NO];
        [tempSelf.tableView reloadData];
    });

}

-(BOOL)deviceHasBeenExistWithID:(NSString *)deviceID
{
    __block BOOL result = NO;
    [self.deviceList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSMutableDictionary *dictionary = obj;
        AiertDeviceInfo *deviceInfo = [dictionary objectForKey:@"device"];
        if ([deviceInfo.deviceID isEqualToString:deviceID]) {
            result = YES;
            *stop = YES;
        }
    }];
    
    return result;
}

-(BOOL)deviceHasBeenAddedWithID:(NSString *)deviceID
{
    __block BOOL result = NO;
    NSArray *array = [self getAllDeviceInfo];
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSMutableDictionary *dictionary = obj;
        AiertDeviceInfo *deviceInfo = obj;
        if ([deviceInfo.deviceID isEqualToString:deviceID]) {
            result = YES;
            *stop = YES;
        }
    }];
    
    return result;
}


-(NSArray *)getAllDeviceInfo
{
    AiertDeviceCoreDataStorage *aiertDeviceCoreDataStorage = [AiertDeviceCoreDataStorage sharedInstance];
    
    NSManagedObjectContext *moc = [aiertDeviceCoreDataStorage mainThreadManagedObjectContext];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"AiertDeviceCoreDataStorageObject"
                                              inManagedObjectContext:moc];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    
    NSArray *fetchedObjects = [moc executeFetchRequest:fetchRequest error:&error];
    
    if (error) {
        LOG(@"Fetched device list error:%@",error.description);
        return nil;
    }
    
    return fetchedObjects;
}

@end
