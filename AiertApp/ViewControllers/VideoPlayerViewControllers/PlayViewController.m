
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
@property (assign, nonatomic) BOOL isStopPlaying;

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

}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //默认画质
    self.qualityType = VideoQualityTypeLD;
    
    //
    _enableSound = NO;
    _enableMicrophone = NO;
    

    //如果此时没有设备的videoNum信息，我们就设置位1
    if (self.device.deviceAdditionInfo.videoNum < 1) {
        DeviceAddition *deviceAddtion = [[DeviceAddition alloc] init];
        [deviceAddtion setVideoNum:1];
        [self.device setDeviceAdditionInfo:deviceAddtion];
    }

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
    [SVProgressHUD showWithStatus:@"正在连接..."];
    
    _showSomeMenu = YES;
    _verticalScreen = YES;
    self.enableMicrophone = NO;
    self.enableSound = NO;
    
    [self initUI];
    [self initData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setHidden:YES];
}

-(void)viewDidAppear:(BOOL)animated{
    
    [[UIDevice currentDevice] setValue:
     [NSNumber numberWithInteger: UIInterfaceOrientationLandscapeRight]
                                forKey:@"orientation"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if ([SVProgressHUD isVisible]){
        [SVProgressHUD dismiss];
    }
    
    [self.navigationController.navigationBar setHidden:NO];
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    [UIView animateWithDuration:duration animations:^{
        if(UIDeviceOrientationIsLandscape(toInterfaceOrientation)) {
            self.playerView.frame = CGRectMake(0, 20, self.height, self.width - 20);
        } else {
            self.playerView.frame = CGRectMake(0, 106, self.width, 268);
        }
    } completion:^(BOOL finished) {
        
    }];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Autorotate

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscapeRight ;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (void)viewWillLayoutSubviews
{
    if(UIDeviceOrientationIsLandscape(self.interfaceOrientation)) {
        self.playerView.frame = CGRectMake(0, 20, self.height, self.width - 20);
    } else {
        self.playerView.frame = CGRectMake(0, 106, self.width, 268);
    }
}

- (void)initUI
{
    CGRect playerViewFrame = CGRectZero;
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
    {
        playerViewFrame = CGRectMake(0, 106, self.width, 268);
    }else/* if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))*/{
        playerViewFrame = CGRectMake(0, 20, self.height, self.width - 20);
    }
    
    self.width = self.view.frame.size.width;
    self.height = self.view.frame.size.height;
    self.view.backgroundColor = [UIColor blackColor];
    [self.defaultImageView setImage:nil];
    self.defaultImageView.backgroundColor = [UIColor blackColor];
    self.playerView = [[PlayerView alloc] initWithFrame:playerViewFrame];
    self.playerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
    self.playerView.center = self.view.center;
    self.playerView.delegate = self;
    [self.view addSubview:self.playerView];
}
- (void)initData
{
    self.isStopPlaying = YES;
}

#pragma mark - PlayerViewDelegate methods
- (void)playerView:(PlayerView *)playerView touchDownInsideButtonAtIndex:(NSUInteger)index
{}
- (void)playerView:(PlayerView *)playerView touchUpInsideButtonAtIndex:(NSUInteger)index
{
    switch (index) {
        case 1:
            [self closeButton_TouchUpInside:nil];
            break;
        case 6:
//            [self closeButton_TouchUpInside:nil];
            break;
        case 9:
        {
            if (self.playerView.talkButton.hidden) {
                [self setEnableSound:NO];
            }else{
                [self setEnableSound:YES];
            }
            
        }
            break;
        default:
            break;
    }
}
- (void)playerView:(PlayerView *)playerView didSwitchTalkStatus:(BOOL)talking
{
    [self setEnableMicrophone:YES];
}
- (void)playerView:(PlayerView *)playerView didChangedVolumeWithValue:(float)value
{

}

#pragma mark - Navigation

- (IBAction)closeButton_TouchUpInside:(id)sender {
   
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
    
    if (![SVProgressHUD isVisible] && !self.isStopPlaying) {
        [SVProgressHUD showWithStatus:@"正在关闭..."];
    }
     
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
{
    _enableMicrophone = enableMicrophone;
}

#pragma mark - Switch LD SD HD

- (void)switchUIbyQualityType:(VideoQualityType)type
{
    [[LibCoreWrap sharedCore] changeStream:type];
}


//#pragma mark - Quality Change Delegate
//
//- (void)selectQualityView:(SelectQualityView *)selectQualityView
//          changeQualityTo:(VideoQualityType)newQualityType
//{
//    [self.playBottomView selectAtQualityIndexWithSubIndex:newQualityType];
//    
//    self.playBottomView.qualityIndex = newQualityType;
//    self.qualityType = newQualityType;
//    [self switchUIbyQualityType:self.qualityType];
//    [self.popupQualityView dismissAnimated:YES];
//}

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

//#pragma mark - Navigation
//
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    if ([segue.identifier isEqualToString:@"Play2Setting"]) {
//        
//        self.hidesBottomBarWhenPushed = YES;
//        
//        if (!_verticalScreen) {
//            [Utilities setMyViewControllerOrientation:_verticalScreen
//                                          Orientation:UIInterfaceOrientationPortrait];
//        }
//        
//        DeviceSettingTableViewController *viewController = segue.destinationViewController;
//        if (viewController) {
//            viewController.currentDeviceName = @"Device Test Name";
//        }
//    }else if ([segue.identifier isEqualToString:@"Play2AlarmList"])
//    {
//        AlarmListTableViewController *viewController = segue.destinationViewController;
//        if (viewController) {
//            //TODO Set Device Name
//            //Test
//            viewController.deviceId = self.device.deviceID;
//        }
//    }
//}


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
//                [self.navigationController popViewControllerAnimated:YES];
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
    self.isStopPlaying = YES;
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
    self.isStopPlaying = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([SVProgressHUD isVisible]) {
            [SVProgressHUD dismiss];
        }
        
    });
}
- (void)didStopPlayWithDeviceID:(NSString *)deviceID
{
    self.isStopPlaying = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [[LibCoreWrap sharedCore] unRegisterStreamObserverWithDeviceId:nil
                                                               channel:0
                                                        streamObserver:self];
        
        if ([SVProgressHUD isVisible]) {
            [SVProgressHUD dismiss];
        }
        
        if (self.navigationController) {
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [self dismissViewControllerAnimated:YES completion:^{}];
        }
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

        [self.playerView.playerView processFrameBuffer:data];
        
    });
}
- (void)didReceiveAudioData:(NSData *)data
{

    [AudioStreamer playAudioData:data];
}
#pragma mark - PlayBottomViewDelegate
//FIXME:这里是重点
- (void)clickButtonAtPlayBottomView:(id)sender Index:(NSInteger)aIndex {
    DLog(@" clickButtonAtPlayBottomView  aIndex:%d",aIndex);
    
    switch (aIndex) {
        case PlayBottomTypeVideo: { //录像
            
            if (CameraStateRecording & [AppData cameraState]) {
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
            
//            [self.playBottomView selectAtIndexWithOpenStatus:PlayBottomTypeTalk OpenStatus:self.enableMicrophone];
        }
            break;
        case PlayBottomTypeSound: { //声音
            self.enableSound = !self.enableSound;
            
//            [self.playBottomView selectAtIndexWithOpenStatus:PlayBottomTypeSound OpenStatus:self.enableSound];
        }
            break;
        case PlayBottomTypeQuality: { //品质
//            self.popupQualityView.qualityView.qualityType = self.qualityType;
//            [self.popupQualityView presentPointingAtView:sender inView:self.bkView animated:YES];
        }
            break;
    }
}

- (void)didLongPressBeganInPlayBottomView:(id)aData Tag:(NSInteger)aTag {
    if (self.enableMicrophone) {
        [[LibCoreWrap sharedCore] startTalkWithDeviceId:self.device.deviceID
                                                channel:_currentChannel];
    }
    
}

- (void)didLongPressEndInPlayBottomView:(id)aData Tag:(NSInteger)aTag {
    if (self.enableMicrophone) {
        [[LibCoreWrap sharedCore] stopTalkWithDeviceId:self.device.deviceID
                                               channel:_currentChannel];
    }
}



@end
