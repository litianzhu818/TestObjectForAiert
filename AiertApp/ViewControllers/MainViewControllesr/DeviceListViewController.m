#import "DeviceListViewController.h"
#import "Utilities.h"
#import "P2PManager.h"


#define kDeviceListTableViewControllerPopupTipViewAutoDismissInterval 5.0f

@interface DeviceListViewController ()
{
    UIImageView *emptyDataImageView;
    //Count of tip view popuped
    int _popupTipShowCount;
    
    NSFetchedResultsController *fetchedResultsController_device;
    BOOL isEditing;
}

@property (strong, nonatomic) NSDictionary *deviceList;
@property (strong, nonatomic) NSArray *deviceIds;
@property (strong, nonatomic) CMPopTipView *popupTipView;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController_device;

@end

@implementation DeviceListViewController

@synthesize popupTipView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initUI];
    [self.tableView hideExtraCellLine];
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    self.tableView.backgroundColor = [UIColor whiteColor];
    _popupTipShowCount = 0;
    
    if (emptyDataImageView == nil) {
        CGFloat SubHeight = 0;
        /*if (IOS7_OR_LATER) {
            SubHeight = (self.navigationController.navigationBar.frame.size.height +
                         self.tabBarController.tabBar.frame.size.height);
        }*/
        emptyDataImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,
                                                                          self.tableView.frame.size.width,
                                                                           self.tableView.bounds.size.height - SubHeight)];
        emptyDataImageView.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                               UIViewAutoresizingFlexibleHeight- 49);
        emptyDataImageView.hidden = YES;
        emptyDataImageView.backgroundColor = [UIColor clearColor];
        emptyDataImageView.image = [UIImage imageNamed:@"camera_picture.png"];
        emptyDataImageView.contentMode = UIViewContentModeCenter;
        
        [self.tableView addSubview:emptyDataImageView];
    }
    
    self.deviceList = [AppData devices];
    self.deviceIds = [[self.deviceList allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return (NSComparisonResult)[obj1 compare:obj2];
    }];
    
    __weak DeviceListViewController *tempSelf = self;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"DevicesUpdated"
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      tempSelf.deviceIds = [[tempSelf.deviceList allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                                                          return (NSComparisonResult)[obj1 compare:obj2];
                                                      }];
                                                      
                                                      [tempSelf.tableView reloadData];
                                                  }];
    isEditing = NO;

}

-(void)initUI
{
    [self initStatusBar];
    
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    self.tableView.layer.cornerRadius = 6.0f;
    self.tableView.layer.borderWidth = 0.2f;
    self.tableView.layer.borderColor = [self.tableView backgroundColor].CGColor;
    self.tableView.layer.masksToBounds = YES;
    [self.tableView setRowHeight:44.0f];
    [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    //iOS7 新背景图片设置方法 高度 必需是 64
    [self.navigationController.navigationBar  setBackgroundImage:[UIImage imageNamed:@"6"] forBarPosition:UIBarPositionTopAttached barMetrics:UIBarMetricsDefault];
    //iOS7 阴影需单独设定 UIColor clearColor 是去掉字段 1像素阴影
    //[self.navigationController.navigationBar setShadowImage:[UIImage imageWithColor:[UIColor clearColor]]];
    //为UINavigationBar设置半透明的背景效果:
    [self.navigationController.navigationBar setTranslucent:YES];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 40, 40)];
    [leftButton setImage:PNG_NAME(@"left_camera") forState:UIControlStateNormal];
    [leftButton setEnabled:NO];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 160, 44)];
    UILabel *softName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 160, 22)];
    UILabel *complanyName  = [[UILabel alloc] initWithFrame:CGRectMake(0, 22, 160, 22)];
    [titleView setTintColor:[UIColor whiteColor]];
    [softName setTextColor:[UIColor whiteColor]];
    [complanyName setTextColor:[UIColor whiteColor]];
    [softName setFont:[UIFont systemFontOfSize:24.0]];
    [complanyName setFont:[UIFont systemFontOfSize:12.0]];
    [softName setText:@"aiert 安全有我"];
    [complanyName setText:@"厦门爱尔特电子有限公司"];
    [softName setTextAlignment:NSTextAlignmentCenter];
    [complanyName setTextAlignment:NSTextAlignmentCenter];
    [titleView addSubview:softName];
    [titleView addSubview:complanyName];
    
    [self.navigationItem setTitleView:titleView];
    
    [self.editButton setTitle:NSLocalizedString(@"编辑", @"")];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
    
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
   
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.hidesBottomBarWhenPushed = NO;
    isEditing = NO;
    [popupTipView dismissAnimated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)clikedOnEditButton:(id)sender
{
    isEditing ? [self.editButton setTitle:@"编辑"]:[self.editButton setTitle:@"完成"];
    
    [self.tableView setEditing:!isEditing animated:YES];
    
    isEditing = !isEditing;
}

#pragma mark - Autorotate

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[[self fetchedResultsController_device] sections] firstObject];
    NSUInteger count =  sectionInfo.numberOfObjects;
    
    tableView.separatorStyle = (count > 0) ? UITableViewCellSeparatorStyleSingleLine : UITableViewCellSeparatorStyleNone;
    tableView.bounces = (count > 0);
    
    //Show Empty Image View
    emptyDataImageView.hidden = (count > 0);
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        AiertDeviceCoreDataStorageObject *deviceInfo = [self.fetchedResultsController_device objectAtIndexPath:indexPath];
        [[myAppDelegate aiertDeviceCoreDataManager] deleteDeviceWithDeviceID:deviceInfo.deviceID];
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AiertDeviceCoreDataStorageObject *deviceInfo = [self.fetchedResultsController_device objectAtIndexPath:indexPath];
    
    if (!deviceInfo.userName  || !deviceInfo.userPassword) {//检查设备是否有用户信息
        [self showMessage:@"该设备没有登录用户名和密码，请重新配置该设备再尝试..." title:@"提示" cancelButtonTitle:@"提示" cancleBlock:^{
        }];
        
        return;
    }else if ([deviceInfo.deviceStatus integerValue] != 0){//检测设备是否在线
        WEAKSELF;
        [SVProgressHUD showWithStatus:@"正在查询状态" maskType:SVProgressHUDMaskTypeClear];
        [[P2PManager sharedInstance] checkConnectTypeWithDeviceInfo:[[AiertDeviceInfo alloc] initWithDeviceCoraDataObject:deviceInfo]
                                                 connectStatusBlock:^(AiertDeviceInfo *device, BOOL connectSucceed, NSError *error) {
                                                     
                                                     
                                                     if (connectSucceed) {
                                                         device.deviceStatus = DeviceStatusOnline;
                                                     }else{
                                                         device.deviceStatus = DeviceStatusOffline;
                                                     }
                                                     
                                                     MAIN_GCD(^{
                                                         
                                                         [SVProgressHUD dismiss];
                                                         [[myAppDelegate aiertDeviceCoreDataManager] editDeviceWithDeviceInfo:device];
                                                         
                                                     });
                                                     
                                                     [weakSelf.tableView reloadData];
                                                 }];
        return;
        
    }else{
        AiertDeviceInfo *device = [[AiertDeviceInfo alloc] initWithDeviceCoraDataObject:deviceInfo];
        
        [self performSegueWithIdentifier:@"DeviceList2Play"
                                  sender:device];
        
        /*
        PlayViewController *playController = [[PlayViewController alloc] init];
        playController.delegatePlayViewController = self;
        playController.device = device;
        [self presentViewController:playController animated:YES completion:^{}];
         */
    }
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    self.hidesBottomBarWhenPushed = YES;

    if ([segue.identifier isEqualToString:@"DeviceList2Play"]) {
        PlayViewController *playController = segue.destinationViewController;
        playController.delegatePlayViewController = self;
        playController.device = sender;
    }
    
    if ([segue.identifier isEqualToString:@"device_edit"]) {
        EditDeviceViewController *viewController = [segue destinationViewController];
        [viewController setValue:sender forKey:@"device"];
    }
}

#pragma Mark PlayViewControllerDelegate
- (void)dismissViewControllerInPlayViewControlller:(BOOL)dismiss {
    
    [Utilities setMyViewControllerOrientation:dismiss Orientation:UIInterfaceOrientationPortrait];
}

#pragma mark -
#pragma mark - AiertHeaderViewDelegate Methods
-(void)clikedOnAiertHeaderView:(AiertHeaderView *)aiertHeaderView
{
    [_headerView stopRefreshing];
    [self performSegueWithIdentifier:@"AddDevice" sender:nil];
}

-(void)clikedRefreshButtonOnAiertHeaderView:(AiertHeaderView *)aiertHeaderView
{
    //[aiertHeaderView stopRefreshing];
}

-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    AiertDeviceCoreDataStorageObject *device = [self.fetchedResultsController_device objectAtIndexPath:indexPath];
    AiertDeviceInfo *deviceInfo = [[AiertDeviceInfo alloc] initWithDeviceCoraDataObject:device];
    
    //MARK:we should do this here ...
    UIFont *font = [UIFont systemFontOfSize:14.0];
    CGRect frame = cell.contentView.frame;
    NSString *device_status = nil;
    UIColor *device_color = nil;
    switch (deviceInfo.deviceStatus) {
        case 0:
        {
            device_status = @"在线";
            device_color = [UIColor colorWithRed:0.122 green:0.475 blue:0.992 alpha:1.000];
        }
            break;
        case 2:
        {
            device_status = @"连接超时";
            device_color = [UIColor lightGrayColor];
        }
            break;
            
        default:
        {
            device_status = @"不在线";
            device_color = [UIColor redColor];
        }
            break;
    }
    
    //初始化三个UILabel
    UILabel *deviceStatus = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN_WIDTH, 0, FRAME_W(frame), FRAME_H(frame)/3)];
    UILabel *deviceName = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN_WIDTH, FRAME_H(frame)/3, FRAME_W(frame), FRAME_H(frame)/3)];
    UILabel *deviceID = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN_WIDTH, 2*FRAME_H(frame)/3, FRAME_W(frame), FRAME_H(frame)/3)];
    
    //设置设备名称的字体颜色
    NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@",@"名称:",deviceInfo.deviceName] attributes:@{NSForegroundColorAttributeName: [UIColor blackColor], NSFontAttributeName:font}];
    [attributedTitle addAttribute:NSForegroundColorAttributeName
                            value:[UIColor colorWithRed:0.122 green:0.475 blue:0.992 alpha:1.000]
                            range:[attributedTitle.string.lowercaseString rangeOfString:deviceInfo.deviceName.lowercaseString]];
    
    [deviceStatus setAttributedText:attributedTitle];
    
    //设置设备id的字体颜色
    NSMutableAttributedString *idTttributedTitle = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@",@"设备ID:",deviceInfo.deviceID] attributes:@{NSForegroundColorAttributeName: [UIColor blackColor], NSFontAttributeName:font}];
    [idTttributedTitle addAttribute:NSForegroundColorAttributeName
                            value:[UIColor colorWithRed:0.122 green:0.475 blue:0.992 alpha:1.000]
                            range:[idTttributedTitle.string.lowercaseString rangeOfString:deviceInfo.deviceID.lowercaseString]];
    
    [deviceName setAttributedText:idTttributedTitle];
    
    //设置设备状态的字体颜色
    NSMutableAttributedString *statusTttributedTitle = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@",@"设备状态:",device_status] attributes:@{NSForegroundColorAttributeName: [UIColor blackColor], NSFontAttributeName:font}];
    [statusTttributedTitle addAttribute:NSForegroundColorAttributeName
                              value:device_color
                              range:[statusTttributedTitle.string.lowercaseString rangeOfString:device_status.lowercaseString]];
    
    [deviceID setAttributedText:statusTttributedTitle];
    
    //添加并显示三个UILabel的视图
    [cell.contentView addSubview:deviceStatus];
    [cell.contentView addSubview:deviceName];
    [cell.contentView addSubview:deviceID];
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTag:indexPath.row];
    [button setFrame:CGRectMake(0, 0, 40, 40)];
    [button setBackgroundImage:PNG_NAME(@"video_14") forState:UIControlStateNormal];
    [button setBackgroundImage:PNG_NAME(@"video_14_selected") forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(editDevice:) forControlEvents:UIControlEventTouchUpInside];
    cell.accessoryView = button;
    
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
}

-(void)editDevice:(id)sender
{
    UIButton *btn = sender;
    //TODO:这里根据得到的index做相应处理
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:btn.tag inSection:0];
    AiertDeviceCoreDataStorageObject *device = [self.fetchedResultsController_device objectAtIndexPath:indexPath];
    AiertDeviceInfo *deviceInfo = [[AiertDeviceInfo alloc] initWithDeviceCoraDataObject:device];
    [self performSegueWithIdentifier:@"device_edit" sender:deviceInfo];
    
}
#pragma mark -
#pragma mark - NSFetchedResultsController Methods
//init the NSFetchedResultsController object
-(NSFetchedResultsController *)fetchedResultsController_device
{
    if (fetchedResultsController_device == Nil) {
    
        NSManagedObjectContext *moc = [[myAppDelegate aiertDeviceCoreDataStorage] mainThreadManagedObjectContext];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"AiertDeviceCoreDataStorageObject"
                                                  inManagedObjectContext:moc];
        
        NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:@"deviceName" ascending:YES];
        
        NSArray *sortDescriptors = [NSArray arrayWithObjects:sd, nil];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        [fetchRequest setEntity:entity];
        [fetchRequest setSortDescriptors:sortDescriptors];
        [fetchRequest setFetchBatchSize:20];
        
        fetchedResultsController_device = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                 managedObjectContext:moc
                                                                                   sectionNameKeyPath:nil
                                                                                            cacheName:@"Aiert_device"];
        NSError *error = nil;
        if (![fetchedResultsController_device performFetch:&error]){
            LOG(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }
    [fetchedResultsController_device setDelegate:self];
    return fetchedResultsController_device;
}

#pragma mark - NSFetchedResultsControllerDelegate methods

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}


@end
