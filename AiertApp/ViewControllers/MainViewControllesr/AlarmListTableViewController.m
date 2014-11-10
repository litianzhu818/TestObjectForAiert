

#import "AlarmListTableViewController.h"

#import "BasicDefine.h"
#import "UIColor+AppTheme.h"

#import "UITableView+AppTheme.h"
#import "LoadMoreTableFooterView.h"

#import "MessageInfo.h"
#import "AlarmMessageCell.h"
#import "UIImageView+WebCache.h"
#import "DeviceListTableViewCellBackgroundView.h"
#import "AppData.h"
#import "ZSWebInterface.h"

@interface AlarmListTableViewController ()<LoadMoreTableFooterDelegate>
{
    NSDate *_lastUpdateDate;
    NSMutableArray *_messageArray;
    NSInteger _pageNumber;
    EGORefreshTableHeaderView *_refreshView;
    NSString *_tokenID;
    BOOL _isFreshing;
    UIButton *_moreButton;
    UIActivityIndicatorView *_indicatorView;
    LoadMoreTableFooterView *_loadMoreView;
}
@end

@implementation AlarmListTableViewController

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
    [self.navigationController.navigationBar setBackgroundImage:PNG_NAME(@"6") forBarMetrics:UIBarMetricsDefault];
    
    _pageNumber = 0;
    _messageArray = [[NSMutableArray alloc]init];
    
    _refreshView = [[EGORefreshTableHeaderView alloc]initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
    [_refreshView setBackgroundColor:[UIColor clearColor] textColor:[UIColor blackColor] arrowImage:[UIImage imageNamed:@"grayArrow"]];
    
    _refreshView.delegate = (id)self;
    [self.tableView addSubview:_refreshView];
    
    
    [_refreshView refreshLastUpdatedDate];
    
    _loadMoreView = [[LoadMoreTableFooterView alloc] initWithFrame:CGRectMake(0, self.tableView.bounds.size.height, self.tableView.bounds.size.width, self.tableView.bounds.size.height)];
    _loadMoreView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    _loadMoreView.delegate = self;
    CGFloat visibleTableDiffBoundsHeight = (self.tableView.bounds.size.height - MIN(self.tableView.bounds.size.height, self.tableView.contentSize.height));
    
    CGRect loadMoreFrame = _loadMoreView.frame;
    loadMoreFrame.origin.y = self.tableView.contentSize.height + visibleTableDiffBoundsHeight;
    _loadMoreView.frame = loadMoreFrame;
    
    [self.tableView addSubview:_loadMoreView];
    
    if (IOS7_OR_LATER) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
    }
    [self downloadMessage];
    [_refreshView startAnimatingWithScrollView:self.tableView];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)downloadMessage
{
    [ZSWebInterface listDeviceMessageWithDeviceId:self.deviceId
                                      messageType:0
                                            start:_pageNumber
                                            count:20
                                          success:^(NSDictionary *data) {
                                              _lastUpdateDate = [NSDate date];
                                              
                                              NSArray *datas = [data objectForKey:@"data"];
                                              NSMutableArray *array = [NSMutableArray array];
                                              for (NSDictionary *data in datas) {
                                                  MessageInfo *messageInfo = [[MessageInfo alloc]init];
                                                  messageInfo.ID = [data objectForKey:@"id"];
                                                  messageInfo.toID = [data objectForKey:@"to_id"];
                                                  NSString *message = [data objectForKey:@"message_content"];
                                                  NSData *jsonData = [message dataUsingEncoding:NSUTF8StringEncoding];
                                                  messageInfo.messageContent = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
                                                  
                                                  messageInfo.messageType = [data objectForKey:@"message_type"];
                                                  messageInfo.ifRead = [data objectForKey:@"if_read"];
                                                  messageInfo.createTime = [data objectForKey:@"create_time"];
                                                  messageInfo.fromID = [data objectForKey:@"from_id"];
                                                  messageInfo.devName = [data objectForKey:@"device_name"];
                                                  [array addObject:messageInfo];
                                                  //[messageInfo release];
                                                  messageInfo = nil;
                                              }
                                              if (_isFreshing) {
                                                  [_messageArray removeAllObjects];
                                              }
                                              [_messageArray addObjectsFromArray:array];
                                              [_refreshView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
                                              [self.tableView reloadData];
                                              
                                              //add
                                              [_loadMoreView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
                                              CGFloat visibleTableDiffBoundsHeight = (self.tableView.bounds.size.height - MIN(self.tableView.bounds.size.height, self.tableView.contentSize.height));
                                              
                                              CGRect loadMoreFrame = _loadMoreView.frame;
                                              loadMoreFrame.origin.y = self.tableView.contentSize.height + visibleTableDiffBoundsHeight;
                                              _loadMoreView.frame = loadMoreFrame;
                                              //add
                                              _isFreshing = NO;
                                              _pageNumber = _messageArray.count;
                                          }
                                          failure:^(NSDictionary *data) {
                                              
                                          }];
    [AppData setAlarmMessageList:_messageArray];
}


#pragma mark egoRefreshDelegate
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
    _isFreshing = YES;
    _pageNumber = 0;
    [self downloadMessage];
}


- (void)loadMoreTableFooterDidTriggerLoadMore:(LoadMoreTableFooterView *)view{
    _pageNumber = _messageArray.count;
    [_loadMoreView startAnimatingWithScrollView:self.tableView];
    [self downloadMessage];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view
{
    return _isFreshing;
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view
{
    return _lastUpdateDate;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_refreshView egoRefreshScrollViewDidScroll:scrollView];
    [_loadMoreView egoRefreshScrollViewDidScroll:scrollView];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_refreshView egoRefreshScrollViewDidEndDragging:scrollView];
    [_loadMoreView egoRefreshScrollViewDidEndDragging:scrollView];
}
#pragma mark - Localized Support

- (void)localizedSupport
{
    self.title = NSLocalizedString(@"Alarm", @"Alarm");
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
    return _messageArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 190;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AlarmMessageCell";
    AlarmMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    //cell.backgroundColor = [UIColor colorWithRed:238.0/255 green:238.0/255 blue:238.0/255 alpha:1];
    MessageInfo *message = [_messageArray objectAtIndex:indexPath.row];
    cell.timeLabel.text = message.createTime;
    cell.messageLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"Receive alarm message from", @"Receive alarm message from"),message.devName];
    
    NSString *url = [message.messageContent objectForKey:@"url"];
    url = [url stringByAppendingString:[NSString stringWithFormat:@"&tokenid=%@&size=L",_tokenID]];
    [cell.alarmImage setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"s.png"]];
    
    cell.selectedBackgroundView = [[DeviceListTableViewCellBackgroundView alloc] initWithFrame:cell.frame border:10];
    
    cell.ifRead = [message.ifRead isEqualToString:@"1"];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageInfo *message = [_messageArray objectAtIndex:indexPath.row];
    
    if ([message.ifRead isEqualToString:@"0"]) {
        [UIApplication sharedApplication].applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber - 1;
        message.ifRead = @"1";
    }
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];

    [ZSWebInterface readMessageWithMessageId:message.ID
                                     success:^(NSDictionary *data) {
                                     
                                     }
                                     failure:^(NSDictionary *data) {
                                     
                                     }];
    [self performSegueWithIdentifier:@"AlarmMessage" sender:message];
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

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AlarmMessage"]) {
        
        [segue.destinationViewController setValue:sender forKey:@"message"];
        [(UIViewController*)segue.destinationViewController setHidesBottomBarWhenPushed:YES];
    }
}

@end
