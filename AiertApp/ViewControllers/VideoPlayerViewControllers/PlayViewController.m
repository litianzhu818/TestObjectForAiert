
#import "PlayViewController.h"

#import "ZMDevice.h"
#import "BasicDefine.h"
#import "UIColor+AppTheme.h"
#import "CXAlertViewEx.h"
#import "CXAlertViewExModifyPassword.h"
#import "DeviceSettingTableViewController.h"
#import "AlarmListTableViewController.h"
#import "DisplayImageView.h"
#import "LibCoreWrap.h"
#include "AppData.h"
#import "AudioStreamer.h"
#import "Utilities.h"
#import "AQRecorderWarp.h"
#import "ZMRecorderFileIndex.h"

#define kBottomLiveBkView_HorizontalScreenHeight                       30.0
#define kLiveInfoHolderView_HorizontalScreenHeight                     25.0
#define kBottomLiveBkView_HorizontalScreenHeightWithPageCtrl           50.0
#define kBottomLiveBkView_VerticalScreenHeightWithPageCtrl             49.0

@interface PlayViewController ()<DisplayImageViewProtocol>
{
    __block NSInteger _currentChannel;
    
    FILE *_fp;
    
}
@property (strong, nonatomic) NSMutableArray *views;
@property (strong, nonatomic) ZMRecorderFileIndex *fileIndexItem;
@property (strong, nonatomic) NSData *currentVideoFrame;


@end

@implementation PlayViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceOrientationDidChangeNotification
                                                  object:nil];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor AppThemeTableViewBackgroundColor];
    
    [UIViewController attemptRotationToDeviceOrientation];
    
    self.popupQualityView = [[CMPopTipViewQuality alloc] initWithBackgroundColor:self.alarmMessageButton.backgroundColor];
    self.popupQualityView.qualityView.delegate = self;
    self.popupQualityView.delegate = self;
    
    //默认画质
    self.qualityType = VideoQualityTypeLD;
    
    //设置scrollview减速参数
    self.scrollView.decelerationRate = 0.1f; //0 to 1
    
    //
    _enableSound = NO;
    _enableMicrophone = NO;
    
    //如果此时没有设备的videoNum信息，我们就设置位1
    if (self.device.deviceAdditionInfo.videoNum < 1) {
        DeviceAddition *deviceAddtion = [[DeviceAddition alloc] init];
        [deviceAddtion setVideoNum:1];
        [self.device setDeviceAdditionInfo:deviceAddtion];
    }
    
    [self.livePageControl setNumberOfPages:self.device.deviceAdditionInfo.videoNum];
    
    if (1 == self.device.deviceAdditionInfo.videoNum) {
        [self.livePageControl setHidden:YES];
    }
    
    [self.scrollView setBackgroundColor:[UIColor blackColor]];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * self.device.deviceAdditionInfo.videoNum,
                                             self.scrollView.frame.size.height);
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.scrollsToTop = NO;
    
    self.scrollView.delegate = self;
    
    self.views = [[NSMutableArray alloc] initWithCapacity:self.device.deviceAdditionInfo.videoNum];
    
    for (int i=0; i<self.device.deviceAdditionInfo.videoNum; ++i) {
        
        DisplayImageView *view = [[DisplayImageView alloc] initWithFrame:CGRectOffset(self.scrollView.frame,
                                                                                      self.scrollView.frame.size.width * i,
                                                                                      -self.scrollView.frame.origin.y)];
        [view setDelegate:self];
        [self.scrollView addSubview:view];
        [self.views addObject:view];
    }
    
    [self loadScrollViewWithPage:0];
    [self loadScrollViewWithPage:1];
    
    
    
    UIImage *talkImage = [UIImage imageNamed:@"talk_show.png"];
    CGSize talkImageSize = talkImage.size;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((_scrollView.bounds.size.width - talkImageSize.width) / 2 , (_scrollView.bounds.size.height - talkImageSize.height ) / 2, talkImageSize.width, talkImageSize.height)];
    imageView.image = talkImage;
    self.talkImageView = imageView;
    [self.scrollView addSubview:imageView];
    imageView.alpha = 0.0;
    
    
    float bottomView_Height = 49.0;
    float navigation_Height = 44.0;
    if (IOS7_OR_LATER) {
        navigation_Height += 20.0;
    }
    PlayBottomView *bottomView = [[PlayBottomView alloc] initWithType:CGRectMake(0, self.bkView.bounds.size.height - bottomView_Height - navigation_Height, self.bkView.bounds.size.width, bottomView_Height) Type:1];
    bottomView.delegate = self;
    bottomView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.playBottomView = bottomView;
    [self.bkView addSubview:bottomView];
    
    [[LibCoreWrap sharedCore] registerEventObserver:self];
    [[LibCoreWrap sharedCore] registerStreamObserverWithDeviceId:nil
                                                         channel:0
                                                  streamObserver:self];
    
    
    [[LibCoreWrap sharedCore] startRealPlayWithDeviceId:self.device.deviceID
                                                channel:_currentChannel
                                              mediaType:VideoQualityTypeLD
                                               userName:self.device.userInfo.userName
                                               password:self.device.userInfo.userPassword
                                                timeout:0];
    [SVProgressHUD showWithStatus:@"正在连接..." maskType:SVProgressHUDMaskTypeClear];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_orientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    [self orgSomeViewFrame];
    
    _showSomeMenu = YES;
    _verticalScreen = YES;
    self.enableMicrophone = NO;
    self.enableSound = NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
//    [[LibCoreWrap sharedCore] closeConnection];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Autorotate

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeRight;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeRight;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
    [self.popupQualityView dismissAnimated:NO];
    [self popTipViewWasDismissedByUser:self.popupQualityView];
    
}


- (void)_orientationDidChange:(NSNotification*)notify
{
    [self _shouldRotateToOrientation:(UIDeviceOrientation)[UIApplication sharedApplication].statusBarOrientation];
}

- (void)_shouldRotateToOrientation:(UIDeviceOrientation)orientation {
    
    if (orientation == UIDeviceOrientationPortrait ||orientation == UIDeviceOrientationPortraitUpsideDown) {
        // 竖屏
        
        NSLog(@"----- - - -- - - - -- --竖屏-");
        _verticalScreen = YES;
        _showSomeMenu = YES;
        
        self.cameraNameLabel.frame = _orgCameraNameLabelFrame;
        
        self.alarmMessageButton.frame = _orgAlarmMessageButtonFrame;
        
        self.scrollView.frame = _orgScrollVewFrame;
        
        self.liveInformationHolderView.frame = _orgliveInformationHolderViewFrame;
        

        self.playBottomView.frame = _orgPlayBottomViewFrame;
        
        CGRect frame = self.talkImageView.frame;
        frame.origin.x = (self.scrollView.frame.size.width - frame.size.width) / 2;
        frame.origin.y = (self.scrollView.frame.size.height - frame.size.height) / 2;
        self.talkImageView.frame = frame;
                
        [self hiddenSomeView:NO];
        
        
        //重新设置DisplayImage视图的frame
        [self resetDisplayImageViewFrame];
        
        [self.view setBackgroundColor:[UIColor AppThemeTableViewBackgroundColor]];
        self.cameraNameLabel.textColor = [UIColor blackColor];
    }
    else {
        // 横屏
        NSLog(@"----- - - -- - - - -- --横屏-");
        _verticalScreen = NO;
        if (!_showSomeMenu) {
            return;
        }
        
        float origY = 0.0;
        //CameraNameLabel
        CGRect frame = self.cameraNameLabel.frame;
        frame.origin.y = origY;
        self.cameraNameLabel.frame = frame;
        
        frame = self.alarmMessageButton.frame;
        frame.origin.x = self.bkView.bounds.size.width - frame.size.width;
        frame.origin.y = origY;
        self.alarmMessageButton.frame = frame;
        
        //playBottomView
        float playBottomView_height = kBottomLiveBkView_HorizontalScreenHeight;
        frame = self.playBottomView.frame;
        frame.origin.y = self.bkView.bounds.size.height - playBottomView_height - origY;
        frame.size.height = playBottomView_height;
        frame.size.width = self.bkView.bounds.size.width;
        self.playBottomView.frame = frame;
        
        //liveInfomationHolderView
        float liveInfomationHolderView_height = kLiveInfoHolderView_HorizontalScreenHeight;
        if (self.device.deviceAdditionInfo.videoNum > 1) {
            liveInfomationHolderView_height = kBottomLiveBkView_HorizontalScreenHeightWithPageCtrl - origY;
        }
        float liveInfomationHolderView_OrgY = self.bkView.bounds.size.height - playBottomView_height - liveInfomationHolderView_height - origY;
        
        frame = self.liveInformationHolderView.frame;
        frame.origin.x = 0.0;
        frame.size.height = liveInfomationHolderView_height;
        frame.origin.y = liveInfomationHolderView_OrgY;
        self.liveInformationHolderView.frame = frame;
        
        
        //ScrollView
        frame = self.scrollView.frame;
        frame.origin.x = 0.0;
        frame.origin.y = self.cameraNameLabel.frame.size.height + origY;
        frame.size.width = self.bkView.bounds.size.width;
        frame.size.height = liveInfomationHolderView_OrgY - frame.origin.y;
        self.scrollView.frame = frame;
        
        
        frame = self.talkImageView.frame;
        frame.origin.x = (self.scrollView.frame.size.width - frame.size.width) / 2;
        frame.origin.y = (self.scrollView.frame.size.height - frame.size.height) / 2;
        self.talkImageView.frame = frame;
        

        //重新设置DisplayImage视图的frame
        [self resetDisplayImageViewFrame];
        
        _orgScrollViewFrameWithHorizontalScreen = self.scrollView.frame;
    }
}
#pragma mark - Page Change Delegate

- (IBAction)livePageControl_ChangePage:(id)sender
{
    DLog(@"%@ : %@",NSStringFromSelector(_cmd),self);
    int page = self.livePageControl.currentPage;
	
    //    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    //    [self loadScrollViewWithPage:page - 1];
    //    [self loadScrollViewWithPage:page];
    //    [self loadScrollViewWithPage:page + 1];
    
	// update the scroll view to the appropriate page
    CGRect frame = self.scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [self.scrollView scrollRectToVisible:frame animated:YES];
    
	// Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
    _pageControlUsed = YES;
}
#pragma mark - ScrollView delegate

- (void)loadScrollViewWithPage:(int)page
{
    if (page < 0)
        return;
    if (page >= self.device.deviceAdditionInfo.videoNum)
        return;
    
    UIView *view = [self.views objectAtIndex:page];
    NSAssert(nil != view,@"page is Nil !");
    if (view.superview == nil)
    {
        [self.scrollView addSubview:view];
    }
    // add the controller's view to the scroll view
}

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    // We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
    // which a scroll event generated from the user hitting the page control triggers updates from
    // the delegate method. We use a boolean to disable the delegate logic when the page control is used.
    if (_pageControlUsed)
    {
        // do nothing - the scroll was initiated from the page control, not the user dragging
        return;
    }
	
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth*0.5f) / pageWidth) + 1;
    
    DLog(@"%@ : %@ , page: %d",NSStringFromSelector(_cmd),self,_currentChannel);
    
    if (page == _currentChannel) {
        return;
    }
    
    [self.views[_currentChannel] setFrame:[self.views[_currentChannel] frame]];
    _currentChannel = page;
    self.livePageControl.currentPage = page;
    
    [[LibCoreWrap sharedCore] changeChannel:page];
    
}

// At the begin of scroll dragging, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _pageControlUsed = NO;
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _pageControlUsed = NO;
}

#pragma mark - Navigation

- (IBAction)backButton_TouchUpInside:(id)sender {
   
    
    if (CameraStateRecording&[AppData cameraState]) {
        
        [AppData removeCameraState:CameraStateRecording];
        
        NSString *date = [Utilities dateToStringWithFormat:@"yyyyMMdd" date:[NSDate date]];
        
        NSString *currentDateTime = [NSString stringWithFormat:@"%@%@",date,[self timeFromVideoFrame]];
        
        self.fileIndexItem.endTime = currentDateTime;
        
        [ZMRecorderFileIndexManage addRecorderFileIndex:self.fileIndexItem];
        
        fclose (_fp);

    }
    
    [[LibCoreWrap sharedCore] stopRealPlayWithDeviceId:self.device.deviceID
                                               channel:_currentChannel];
    
    [AppData resetCameraState];
    
    if (![SVProgressHUD isVisible]) {
        [SVProgressHUD showWithStatus:@"正在关闭..." maskType:SVProgressHUDMaskTypeClear];
    }
    
    DLog(@"%d",[AppData cameraState]);
    
    DLog(@"------------------------------------------------------> 1 stop playing !");
     
}

- (void)setEnableSound:(BOOL)enableSound
{
    if (enableSound) {
        
        if (CameraNetworkStateTransmitConnected == [AppData connectionState]) {
            [AudioStreamer startPlayAudio];
        }else
        {
            [[LibCoreWrap sharedCore] openSoundWithDeviceId:self.device.deviceID channel:_currentChannel];
        }

    }else
    {
        [AudioStreamer stopPlayAudio];
        [[LibCoreWrap sharedCore] closeSoundWithDeviceId:self.device.deviceID channel:_currentChannel];
    }
    
    
    _enableSound = enableSound;
}

- (void)setEnableMicrophone:(BOOL)enableMicrophone
{    _enableMicrophone = enableMicrophone;
}

#pragma mark - Switch LD SD HD

- (void)switchUIbyQualityType:(VideoQualityType)type
{
    [[LibCoreWrap sharedCore] changeStream:type];
    
}


#pragma mark - Quality Change Delegate

- (void)selectQualityView:(SelectQualityView *)selectQualityView
          changeQualityTo:(VideoQualityType)newQualityType
{
    [self.playBottomView selectAtQualityIndexWithSubIndex:newQualityType];
    
    self.playBottomView.qualityIndex = newQualityType;
    self.qualityType = newQualityType;
    [self switchUIbyQualityType:self.qualityType];
    [self.popupQualityView dismissAnimated:YES];
}

- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView
{
    //
    /*  self.bottomLiveQualityButton.selected = NO;*/
}


#pragma mark - Change Password

- (void)askTochangeDevicePassword
{
    CXAlertViewEx *alart = [[CXAlertViewEx alloc] initWithMessage:NSLocalizedString(@"Password is not safe. For safety, please change the default password!",
                                                                                    @"Password is not safe. For safety, please change the default password!")
                                                submitButtonTitle:NSLocalizedString(@"OK",@"OK")
                                                    submitHandler:^(CXAlertView *alertView, CXAlertButtonItem *button) {
                                                        [alertView dismiss];
                                                        [self performSelector:@selector(changeDevicePassword) withObject:nil afterDelay:0.5f];
                                                    }
                                                cancelButtonTitle:NSLocalizedString(@"Cancel",@"Cancel")
                                                    cancelHandler:^(CXAlertView *alertView, CXAlertButtonItem *button) {
                                                        //
                                                        //NSLog(@"CXAlertViewEx - Press Cancel");
                                                        [alertView dismiss];
                                                    }];
    [alart show];
}

- (void)changeDevicePassword
{
    //
    CXAlertViewExModifyPassword *alart2 = [[CXAlertViewExModifyPassword alloc] initWithTitle:NSLocalizedString(@"Modify Password", @"Modify Password")
                                                                           submitButtonTitle:NSLocalizedString(@"OK",@"OK")
                                                                               submitHandler:^(CXAlertView *alertView, CXAlertButtonItem *button) {
                                                                                   self.title = ((CXAlertViewExModifyPassword*)alertView).password;
                                                                                   [alertView dismiss];
                                                                               }
                                                                           cancelButtonTitle:NSLocalizedString(@"Cancel",@"Cancel")
                                                                               cancelHandler:^(CXAlertView *alertView, CXAlertButtonItem *button) {
                                                                                   //
                                                                                   //NSLog(@"CXAlertViewEx - Press Cancel");
                                                                                   [alertView dismiss];
                                                                               }];
    [alart2 show];
    
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Play2Setting"]) {
        
        self.hidesBottomBarWhenPushed = YES;
        
        if (!_verticalScreen) {
            [Utilities setMyViewControllerOrientation:_verticalScreen
                                          Orientation:UIInterfaceOrientationPortrait];
        }
        
        DeviceSettingTableViewController *viewController = segue.destinationViewController;
        if (viewController) {
            viewController.currentDeviceName = @"Device Test Name";
        }
    }else if ([segue.identifier isEqualToString:@"Play2AlarmList"])
    {
        AlarmListTableViewController *viewController = segue.destinationViewController;
        if (viewController) {
            //TODO Set Device Name
            //Test
            viewController.deviceId = self.device.deviceID;
        }
    }
}


#pragma mark - LibCore Event observer

- (void)didReceiveEvent:(NSInteger)code
                content:(NSString *)content
               deviceId:(NSString *)deviceId
                channel:(NSInteger)channel
{
    switch (code) {
        case LibCoreEventCodePlayStoped:
        {
            [[LibCoreWrap sharedCore] unRegisterEventObserver:self];
            [AudioStreamer stopPlayAudio];
            
            if (_delegatePlayViewController && [(id) _delegatePlayViewController respondsToSelector:@selector(dismissViewControllerInPlayViewControlller:)]) {
                [_delegatePlayViewController dismissViewControllerInPlayViewControlller:_verticalScreen];
            }
            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.navigationController popToRootViewControllerAnimated:YES];
//            });

        }
            break;
        case LibCoreEventCodeAudioResponseSuccess:
        {
            if (_enableSound) {
                
                DLog(@"-------------------------------------> open audio successful !");

                [AudioStreamer startPlayAudio];
                
                [AppData addCameraState:CameraStateAudioPlaying];
            }else
            {
                [AudioStreamer stopPlayAudio];
                
                [AppData removeCameraState:CameraStateAudioPlaying];
            }
        }
            break;
        case LibCoreEventCodeAudioResoponseFailed:
            break;
        case LibCoreEventCodeOpenMicSuccess:
            break;
        case LibCoreEventCodeMicResponseFailed:
            break;
        case LibCoreEventCodeMicResponseBusy:
            break;
    }
}

- (NSString *)timeFromVideoFrame
{
    const char *pData = [_currentVideoFrame bytes];
    
    char hms[3];
    NSMutableString *timeString = [[NSMutableString alloc] init];
    
    for (int i=0; i<3; ++i) {
        memcpy(&hms[i], pData+8+i, 1);
        
        DLog(@"%d",hms[i]);
        
        if (hms[i] < 10) {
            [timeString appendString:[NSString stringWithFormat:@"0%d",hms[i]]];
        }else
        {
            [timeString appendString:[NSString stringWithFormat:@"%d",hms[i]]];
        }
    }
    
    DLog(@"timeString: ---------------------- -------- --------> %@",timeString);
    return timeString;
    
}

#pragma mark - LibCore Stream observer
- (void)didFailedPlayWithDeviceID:(NSString *)deviceID
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([SVProgressHUD isVisible]) {
            [SVProgressHUD dismiss];
        }
        
        [self showMessage:@"连接失败！请检查设备连接后重试..." title:@"提示" cancelButtonTitle:@"我知道了" cancleBlock:^{

        }];
        
    });
}

- (void)didStartPlayWithDeviceID:(NSString *)deviceID
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([SVProgressHUD isVisible]) {
            [SVProgressHUD dismiss];
        }
        
    });
}
- (void)didStopPlayWithDeviceID:(NSString *)deviceID
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [[LibCoreWrap sharedCore] unRegisterStreamObserverWithDeviceId:nil
                                                               channel:0
                                                        streamObserver:self];
        
        if ([SVProgressHUD isVisible]) {
            [SVProgressHUD dismiss];
        }
        
        [self.navigationController popToRootViewControllerAnimated:YES];
    });
}

- (void)didReceiveRawData:(NSData *)data tag:(NSInteger)tag;
{
    
    if (!(CameraStateRecording&[AppData cameraState])) {
        
        return;
    }
    
    int nLen = 0;
    
    memcpy(&nLen, [data bytes]+4, 4);
    
    DLog(@"%@ : length : %d, tag : %d, length from header : %d",NSStringFromSelector(_cmd),[data length],tag,nLen);
    
    NSString *date = [Utilities dateToStringWithFormat:@"yyyyMMdd" date:[NSDate date]];
    
    NSString *currentDateTime;
    
    
    if (RawDataTagVideoBody == tag) {
        
        _currentVideoFrame = data;
        
        if (!_fileIndexItem) {
            
            
            currentDateTime = [NSString stringWithFormat:@"%@%@",date,[self timeFromVideoFrame]];
            
            self.fileIndexItem = [[ZMRecorderFileIndex alloc] initWithRecordDeviceId:self.device.deviceID
                                                                             channel:self.currentChannel
                                                                           startTime:currentDateTime
                                                                       fileExtension:@"h264"
                                                                                type:1];
            
            __block UIImage *image;
            
            while (!image) {
                
                DLog(@"getImage ------------------------------------");
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    image = (UIImage *)[[LibCoreWrap sharedCore] currentFrame];
                });
            }
            
            
            
            //begin small_image
            UIImage *smallImage = [Utilities generatePhotoThumbnail:image Width:75.0 Height:60.0];
            
            NSString *smallImageName = [NSString stringWithFormat:@"%@_small.png",self.fileIndexItem.recorderId];
            
            NSData *smallImageData = UIImagePNGRepresentation(smallImage);
            
            [smallImageData writeToFile:[Utilities documentsPathWithFolder:[[AppData lastLoginUser] userId] fileName:smallImageName] atomically:NO];
            
            //end small_image
            

        }
        
    }
    
    if (!_fp) {
        
        NSString *recordFilePath = [Utilities documentsPathWithFolder:[[AppData lastLoginUser] userId] fileName:self.fileIndexItem.recorderId];
        
        DLog(@"recordFilePath : --------------------------------------> %@",recordFilePath);
        _fp = fopen ([recordFilePath UTF8String],"wb");
        
        if (!_fp) {
            return;
        }
    }
    
    
    fwrite ([data bytes],[data length],1,_fp);
    
}
- (void)didReceiveImageData:(id)data
{
    //DLog(@"%@,%@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.views[_currentChannel] processFrameBuffer:data];
        
    });
}
- (void)didReceiveAudioData:(NSData *)data
{

    [AudioStreamer playAudioData:data];
}

- (void)orgSomeViewFrame {
    //记录各个视图开始的frame信息,竖屏的时候方便恢复
    _orgCameraNameLabelFrame = self.cameraNameLabel.frame;
    
    _orgAlarmMessageButtonFrame = self.alarmMessageButton.frame;
    
    _orgliveInformationHolderViewFrame = self.liveInformationHolderView.frame;
    
    _orgScrollVewFrame = self.scrollView.frame;
    
    _orgPlayBottomViewFrame = self.playBottomView.frame;
}

- (void)hiddenSomeView:(BOOL)bYes {
    
    self.navigationController.navigationBarHidden = bYes;
    
    self.liveInformationHolderView.hidden = bYes;
    
    self.playBottomView.hidden = bYes;
}

- (void)resetDisplayImageViewFrame {
    
    for (int i = 0; i < [self.views count]; ++i) {
        DisplayImageView *view = (DisplayImageView *)[self.views objectAtIndex:i];
        view.frame = CGRectOffset(self.scrollView.frame,
                                  self.scrollView.frame.size.width * i,
                                  -self.scrollView.frame.origin.y);
    }
}

#pragma mark - DisplayImageViewDelegate
- (void)displayImageViewTaped:(id)sender
{
    if (!_verticalScreen) {
     //横屏情况下,才会显示和隐藏菜单
        _showSomeMenu = !_showSomeMenu;
        
        float origY = 0.0;
        if (IOS7_OR_LATER) {
            origY = 20.0;
        }
        if (_showSomeMenu) {
            //显示菜单
            
            [self hiddenSomeView:NO];
        
            self.scrollView.frame = _orgScrollViewFrameWithHorizontalScreen;
            
            [self.view setBackgroundColor:[UIColor AppThemeTableViewBackgroundColor]];
            CGRect frame = self.cameraNameLabel.frame;
            frame.origin.y = 0.0;
            self.cameraNameLabel.frame = frame;
            
            
            frame = self.talkImageView.frame;
            frame.origin.x = (self.scrollView.frame.size.width - frame.size.width) / 2;
            frame.origin.y = (self.scrollView.frame.size.height - frame.size.height) / 2;
            self.talkImageView.frame = frame;
        }
        else {
            //隐藏菜单
             [self hiddenSomeView:YES];
            
    
            CGRect frame = self.cameraNameLabel.frame;
            frame.origin.y = origY;
            self.cameraNameLabel.frame = frame;
            origY += frame.size.height;
     
            //重新设置scrollView的高度
            frame = self.scrollView.frame;
            frame.origin.y = origY;
            frame.size.height = self.bkView.bounds.size.height - origY ;
            self.scrollView.frame = frame;
            
            [self.view setBackgroundColor:[UIColor blackColor]];
        }
        //重新设置DisplayImage视图的frame
        [self resetDisplayImageViewFrame];
    }
}


#pragma mark - PlayBottomViewDelegate
- (void)clickButtonAtPlayBottomView:(id)sender Index:(NSInteger)aIndex {
    DLog(@" clickButtonAtPlayBottomView  aIndex:%d",aIndex);
    
    switch (aIndex) {
        case PlayBottomTypeVideo: { //录像
            
            if (CameraStateRecording&[AppData cameraState]) {
                [AppData removeCameraState:CameraStateRecording];
                
                NSString *date = [Utilities dateToStringWithFormat:@"yyyyMMdd" date:[NSDate date]];

                NSString *currentDateTime = [NSString stringWithFormat:@"%@%@",date,[self timeFromVideoFrame]];
                
                self.fileIndexItem.endTime = currentDateTime;
                
                [ZMRecorderFileIndexManage addRecorderFileIndex:self.fileIndexItem];
                
                fclose (_fp);
                
            }else
            {
                [AppData addCameraState:CameraStateRecording];
            }
        }
            break;
        case PlayBottomTypeGrab: { //抓图
            
            UIImage *image;
            
            while (!image) {
                
                image = (UIImage *)[[LibCoreWrap sharedCore] currentFrame];
            }
            
            if ([ZMRecorderFileIndexManage saveScreenShotImage:image 
                                                      deviceId:self.device.deviceID
                                                       channel:_currentChannel]) {
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Grab Image OK",
                                                                       @"Grab Image OK")];
            }
        }
            break;
        case PlayBottomTypeTalk: { //对讲
            self.enableMicrophone = !self.enableMicrophone;
            
            [self.playBottomView selectAtIndexWithOpenStatus:PlayBottomTypeTalk OpenStatus:self.enableMicrophone];
        }
            break;
        case PlayBottomTypeSound: { //声音
            self.enableSound = !self.enableSound;
            
            [self.playBottomView selectAtIndexWithOpenStatus:PlayBottomTypeSound OpenStatus:self.enableSound];
        }
            break;
        case PlayBottomTypeQuality: { //品质
            self.popupQualityView.qualityView.qualityType = self.qualityType;
            [self.popupQualityView presentPointingAtView:sender inView:self.bkView animated:YES];
        }
            break;
    }
}

- (void)didLongPressBeganInPlayBottomView:(id)aData Tag:(NSInteger)aTag {
    if (self.enableMicrophone) {
        self.talkImageView.alpha = 1.0;
        [[LibCoreWrap sharedCore] startTalkWithDeviceId:self.device.deviceID
                                                channel:_currentChannel];
    }
    
}

- (void)didLongPressEndInPlayBottomView:(id)aData Tag:(NSInteger)aTag {
    if (self.enableMicrophone) {
        self.talkImageView.alpha = 0.0;
        [[LibCoreWrap sharedCore] stopTalkWithDeviceId:self.device.deviceID
                                               channel:_currentChannel];
    }
}



@end
