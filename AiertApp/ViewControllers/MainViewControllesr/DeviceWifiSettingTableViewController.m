

#import "DeviceWifiSettingTableViewController.h"

#import "BasicDefine.h"
#import "UIColor+AppTheme.h"

#import "UISwitchEx.h"
#import "DeviceWifiSettingTopCell.h"
#import "DeviceWifiSettingCell.h"

#import "UITableView+AppTheme.h"

#import "CXAlertViewExEnterPassword.h"

@interface DeviceWifiSettingTableViewController ()
{
    NSMutableArray *wifiList;
    
    BOOL _viewHasDisappear;
    
    BOOL _busy;
}

@property (weak, nonatomic) DeviceWifiSettingTopCell *topCell;

@end

@implementation DeviceWifiSettingTableViewController

@synthesize topCell;

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
    
    //
    wifiList = [[NSMutableArray alloc] initWithCapacity:100];
    
    _viewHasDisappear = YES;
    
    self.topCell = nil;
    
    _busy = NO;
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
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //激活 事件
    [self setWifiOn:self.wifiOn animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _viewHasDisappear = YES;
    
    [self showBusy:NO];
}

#pragma mark - Localized Support

- (void)localizedSupport
{
    self.title = NSLocalizedString(@"Wi-Fi Setting", @"Wi-Fi Setting");
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    // Test
    return wifiList.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        static NSString *CellIdentifierTop = @"DeviceWifiSettingTopCell";
        //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        DeviceWifiSettingTopCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierTop];
        
        // Configure the cell...
        if (self.topCell) {
            [self.topCell.wifiSwitch removeTarget:self action:@selector(wifiSwitch_ValueChanged:) forControlEvents:UIControlEventValueChanged];
            [self.topCell.activityIndicatorView stopAnimating];
        }
        self.topCell = cell;
        [cell.wifiSwitch addTarget:self action:@selector(wifiSwitch_ValueChanged:) forControlEvents:UIControlEventValueChanged];
        [cell.wifiSwitch setOn:self.wifiOn animated:NO];
        cell.titleLabel.text = NSLocalizedString(@"WLAN", @"WLAN");
        [self showBusy:_busy];
        
        return cell;
    }
    else
    {
        static NSString *CellIdentifier = @"DeviceWifiSettingCell";
        //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        DeviceWifiSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [DeviceWifiSettingCell cellFromXib];
        }
        
        //TODO Core Load Wifi
        cell.titleLabel.text = @"爱尔特_abc_dfdg";
        switch (indexPath.row) {
            case 1:
                cell.wifiStatus = DeviceWifiStatusConnetedWithPassword;
                break;
            case 2:
                cell.wifiStatus = DeviceWifiStatusConnetedWithoutPassword;
                break;
            case 3:
                cell.wifiStatus = DeviceWifiStatusDisconnetedWithPassword;
                break;
                
            default:
                cell.wifiStatus = DeviceWifiStatusDisconnetedWithoutPassword;
                break;
        }
        
        return cell;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row > 0) {
        
        //TODO Input Password
        CXAlertViewExEnterPassword *alart = [[CXAlertViewExEnterPassword alloc] initWithTitle:NSLocalizedString(@"Enter Password", @"Enter Password")
                           submitButtonTitle:NSLocalizedString(@"OK",@"OK")
                           submitHandler:^(CXAlertView *alertView, CXAlertButtonItem *button) {
                               //TODO Handle Password
                               self.title = ((CXAlertViewExEnterPassword*)alertView).password;
                               //
                               
                               [alertView dismiss];
                           }
                           cancelButtonTitle:NSLocalizedString(@"Cancel",@"Cancel")
                           cancelHandler:^(CXAlertView *alertView, CXAlertButtonItem *button) {
                               //
                               NSLog(@"CXAlertViewEx - Press Cancel");
                               [alertView dismiss];
                           }];
        [alart show];
        
        
        //
        [self.tableView selectRowAtIndexPath:nil animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
}

//Need for iPad
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //解决在ipad上背景不透明的问题
    //http://www.myexception.cn/operating-system/1446505.html
    [cell setBackgroundColor:[UIColor clearColor]];
}

#pragma mark - WIFI On Off

- (BOOL)wifiOn
{
    return _wifiOn;
}

- (void)setWifiOn:(BOOL)wifiOn animated:(BOOL)animated
{
    _wifiOn = wifiOn;
    if (topCell) {
        if (!_viewHasDisappear) {
            if (topCell.wifiSwitch.on != _wifiOn) {
                [topCell.wifiSwitch setOn:_wifiOn animated:animated];
            }
            
            //Core
            if (!_wifiOn) {
                [wifiList removeAllObjects];
                [self.tableView reloadData];
                [self showBusy:NO];
            }
            else
            {
                [self showBusy:YES];
                //搜索wifi
                //清空记录
                [wifiList removeAllObjects];
                [self.tableView reloadData];
                //搜索wifi
                //TODO Code
                //Test
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if (!_viewHasDisappear) {
                        //Test
                        [wifiList removeAllObjects];
                        [wifiList addObject:@"1"];
                        [wifiList addObject:@"1"];
                        [wifiList addObject:@"1"];
                        [wifiList addObject:@"1"];
                        [wifiList addObject:@"1"];
                        [wifiList addObject:@"1"];
                        
                        [self.tableView reloadData];
                        
                        [self showBusy:NO];
                    }
                });
            }
        }
    }
}

- (void)wifiSwitch_ValueChanged:(id)sender
{
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setWifiOn:topCell.wifiSwitch.on animated:YES];
    });
    
}

- (void)setWifiOn:(BOOL)wifiOn
{
    [self setWifiOn:wifiOn animated:NO];
}

#pragma mark - Show Busy

- (void)showBusy:(BOOL)busy
{
    _busy = busy;
    if (topCell) {
        topCell.wifiSwitch.hidden = busy;
        
        topCell.activityIndicatorView.hidden = !busy;
        if (busy) {
            [topCell.activityIndicatorView startAnimating];
        }
        else {
            [topCell.activityIndicatorView stopAnimating];
        }
    }
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


/*
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ScanQrCode2InputDevicePassword"]) {
        self.hidesBottomBarWhenPushed = YES;
    }
}
*/

@end
