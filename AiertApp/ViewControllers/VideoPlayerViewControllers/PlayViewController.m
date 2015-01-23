
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

#define DEFAULT_PLAYER_VIEW_WIDTH self.view.frame.size.width
#define DEFAULT_PLAYER_VIEW_HEIGHT DEFAULT_PLAYER_VIEW_WIDTH*3/4

#define IOS_VERSION_8_OR_ABOVE (([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)? (YES):(NO))

#define _IPHONE_VERSION_ABOVE_8_0 1

#define __IPHONE_CURRENT_MAX_VERSION_ALLOWED __IPHONE_7_1

@interface PlayViewController ()<DisplayImageViewProtocol>
{
    __block NSInteger _currentChannel;
    
    FILE *_fp;
    BOOL _isPlayerViewPortrait;
    
}
@property (strong, nonatomic) NSMutableArray *views;
@property (strong, nonatomic) ZMRecorderFileIndex *fileIndexItem;
@property (strong, nonatomic) NSData *currentVideoFrame;
@property (assign, nonatomic) BOOL isStopPlaying;
@property (assign, nonatomic) BOOL playingFailed;

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
    
    _verticalScreen = YES;
    _isPlayerViewPortrait = YES;
    self.enableMicrophone = NO;
    self.enableSound = NO;
    
    [self initData];
    [self initUI];
    
}

- (void)initUI

{
    self.view.backgroundColor = [UIColor blackColor];
    
    self.playerView = [[PlayerView alloc] initWithFrame:CGRectMake(0, 106, DEFAULT_PLAYER_VIEW_WIDTH, DEFAULT_PLAYER_VIEW_HEIGHT) minValue:0 maxValue:32];
    self.playerView.center = self.view.center;
    self.playerView.delegate = self;
    [self.view addSubview:self.playerView];
    [self.view bringSubviewToFront:self.playerView];
}

- (void)initData
{
    self.isStopPlaying = YES;
    self.playingFailed = NO;
    self.turnCameraSpeed = 15;
}

- (void)startPlayFullScreen
{
    if (!_isPlayerViewPortrait) {
        return;
    }
    
    CGAffineTransform transfrom = CGAffineTransformMakeRotation(M_PI/2);
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        
        //在这里设置view.transform需要匹配的旋转角度的大小就可以了。
        self.playerView.transform = transfrom;
        self.playerView.layer.position = CGPointMake(self.view.center.x, self.view.center.y+20);
        self.playerView.bounds = CGRectMake(0, 0, self.view.bounds.size.height-40, self.view.bounds.size.width);

    } completion:^(BOOL finished) {
        
        _isPlayerViewPortrait = NO;
        [self.view setNeedsDisplay];
    }];

}

- (void)resumeFromFullScreen
{
    if (_isPlayerViewPortrait) {
        return;
    }
    
    CGAffineTransform transfrom = CGAffineTransformIdentity;
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        
        //在这里设置view.transform需要匹配的旋转角度的大小就可以了。
        self.playerView.transform = transfrom;
        self.playerView.layer.position = CGPointMake(self.view.center.x, self.view.center.y);
        self.playerView.bounds = CGRectMake(0, 0, DEFAULT_PLAYER_VIEW_WIDTH, DEFAULT_PLAYER_VIEW_HEIGHT);
        self.playerView.frame = CGRectMake(0, 106, DEFAULT_PLAYER_VIEW_WIDTH, DEFAULT_PLAYER_VIEW_HEIGHT);
        self.playerView.center = self.view.center;
        
    } completion:^(BOOL finished) {
        _isPlayerViewPortrait = YES;
        [self.view setNeedsDisplay];
    }];
}

- (void)startAnimation
{
    if (_isPlayerViewPortrait) {
        [self startPlayFullScreen];
    }else{
        [self resumeFromFullScreen];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setHidden:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}

//支持自动旋转
- (BOOL)shouldAutorotate
{
    return NO;
}
//支持旋转的方向
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait; //否者只支持横屏
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([SVProgressHUD isVisible]){
        [SVProgressHUD dismiss];
    }
    
    [self.navigationController.navigationBar setHidden:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PlayerViewDelegate methods
- (void)playerView:(PlayerView *)playerView touchDownInsideButtonAtIndex:(NSUInteger)index
{
    switch (index) {
        case 4:
            [[LibCoreWrap sharedCore] setMirrorUpDown];
            break;
        case 5:
            [[LibCoreWrap sharedCore] setMirrorLeftRight];
            break;
        case 6:
            [[LibCoreWrap sharedCore] startTurnCameraWithSpeed:self.turnCameraSpeed type:CAMERA_TURN_TYPE_UP_DOWN];
            break;
        case 7:
            [[LibCoreWrap sharedCore] startTurnCameraWithSpeed:self.turnCameraSpeed type:CAMERA_TURN_TYPE_LEFT_RIGHT];
            break;
        case 13:
            [[LibCoreWrap sharedCore] setCamseraDefauleValue];
            break;
        default:
            break;
    }
}

- (void)playerView:(PlayerView *)playerView didChangedSettingWithValue:(float)value type:(SettingSliderType)type
{
    switch (type) {
        case SettingSliderTypeBrightness:
            [[LibCoreWrap sharedCore] setCameraBrightness:value];
            break;
        case SettingSliderTypeContrast:
            [[LibCoreWrap sharedCore] setCameraContrast:value];
            break;
        case SettingSliderTypeSaturation:
            [[LibCoreWrap sharedCore] setCameraSaturation:value];
            break;
        default:
            break;
    }
}
- (void)playerView:(PlayerView *)playerView touchUpInsideButtonAtIndex:(NSUInteger)index
{
    switch (index) {
        case 1:
            [self closeButton_TouchUpInside:nil];
            break;
        case 2:

            break;
        case 6:
        case 7:
            //[[LibCoreWrap sharedCore] stopTurnCamera];
            break;
        case 8:
            [self startAnimation];
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
        case 10:
        {
            [[LibCoreWrap sharedCore] setAudioStart:YES];
        }
            break;
        case 13:
            [[LibCoreWrap sharedCore] setCamseraDefauleValue];
            break;

        default:
            break;
    }
}
- (void)playerView:(PlayerView *)playerView didSwitchTalkStatus:(BOOL)talking
{
    [self setEnableMicrophone:talking];
    
    if (self.enableMicrophone) {
        [[LibCoreWrap sharedCore] startTalkWithDeviceId:self.device.deviceID
                                                channel:_currentChannel];
    }else{
        [[LibCoreWrap sharedCore] stopTalkWithDeviceId:self.device.deviceID
                                               channel:_currentChannel];
    }

}
- (void)playerView:(PlayerView *)playerView didChangedVolumeWithValue:(float)value
{
    self.turnCameraSpeed = value;
}

- (void)playerView:(PlayerView *)playerView didChangedQualityTypeWithValue:(VideoQualityType)newQualityType
{
    self.qualityType = newQualityType;
    [self switchUIbyQualityType:self.qualityType];
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
    
    
    if (self.playingFailed) {
        if (self.navigationController) {
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [self dismissViewControllerAnimated:YES completion:^{}];
        }
        
        if ([SVProgressHUD isVisible]) {
            [SVProgressHUD dismiss];
        }
    }else{
        [[LibCoreWrap sharedCore] stopRealPlayWithDeviceId:self.device.deviceID
                                                   channel:_currentChannel];
        if (![SVProgressHUD isVisible] && !self.isStopPlaying) {
            [SVProgressHUD showWithStatus:@"正在关闭..."];
        }
    }
    
    [AppData resetCameraState];

}

- (void)setEnableSound:(BOOL)enableSound
{
    if (enableSound) {
        
        if (CameraNetworkStateTransmitConnected == [AppData connectionState]) {
            [AudioStreamer startPlayAudio];
        }else
        {
            [AudioStreamer startPlayAudio];
            [[LibCoreWrap sharedCore] openSoundWithDeviceId:self.device.deviceID channel:_currentChannel];
        }
        [AudioStreamer startPlayAudio];
        [[LibCoreWrap sharedCore] openSoundWithDeviceId:self.device.deviceID channel:_currentChannel];

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
/*
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
*/

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
        
        [SVProgressHUD dismiss];
        UIAlertView *aiert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"连接失败！请检查设备连接后重试..."
                                                       delegate:self
                                              cancelButtonTitle:@"我知道了"
                                              otherButtonTitles:nil, nil];
        [aiert show];
        self.playingFailed = YES;
        self.device.deviceStatus = DeviceStatusOffline;
        [[myAppDelegate aiertDeviceCoreDataManager] editDeviceWithDeviceInfo:self.device];
        /*
        typeof(self) __weak weakObject = self;
        [weakObject showMessage:@"连接失败！请检查设备连接后重试..." title:@"提示" cancelButtonTitle:@"我知道了" cancleBlock:^{
            weakObject.playingFailed = YES;
            weakObject.device.deviceStatus = DeviceStatusOffline;
            [[myAppDelegate aiertDeviceCoreDataManager] editDeviceWithDeviceInfo:weakObject.device];
        }];
         */
        
    });
}

- (void)didStartPlayWithDeviceID:(NSString *)deviceID
{
    self.isStopPlaying = NO;
    [AppData setConnectionState:CameraNetworkStateP2pConnected];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //if ([SVProgressHUD isVisible]) {
            [SVProgressHUD dismiss];
        //}
        
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
        case PlayBottomTypeQuality: { //品质
//            self.popupQualityView.qualityView.qualityType = self.qualityType;
//            [self.popupQualityView presentPointingAtView:sender inView:self.bkView animated:YES];
        }
            break;
    }
}
@end
