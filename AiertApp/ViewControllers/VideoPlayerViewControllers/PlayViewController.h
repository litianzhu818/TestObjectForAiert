

#import <UIKit/UIKit.h>

#import "CMPopTipViewQuality.H"
#import "BasicDefine.h"
#import "UIPageControlEx.h"
#import "UIButtonWithTouchDown.h"
#import "Utilities.h"
#import "ZMRecorderFileIndex.h"
#import "SVProgressHUD.h"
#import "ZMRecorderFileIndexManage.h"
#import "PlayBottomView.h"

@protocol PlayViewControllerDelegate <NSObject>

@optional
- (void)dismissViewControllerInPlayViewControlller:(BOOL)dismiss;

@end

@class ZMDevice;
@interface PlayViewController : UIViewController <SelectQualityViewDelegate, CMPopTipViewDelegate, UIScrollViewDelegate,PlayViewControllerDelegate,PlayBottomViewDelegate>
{
    BOOL _enableSound;
    BOOL _enableMicrophone;
    BOOL _pageControlUsed;
    
    BOOL _verticalScreen;
    
    CGRect _orgCameraNameLabelFrame;
    CGRect _orgAlarmMessageButtonFrame;
    CGRect _orgScrollVewFrame;
    CGRect _orgScrollViewFrameWithHorizontalScreen;
    CGRect _orgliveInformationHolderViewFrame;
    CGRect _orgPlayBottomViewFrame;
    
    BOOL   _showSomeMenu;
}

@property (strong, nonatomic) AiertDeviceInfo *device;

@property (weak, nonatomic) IBOutlet UILabel *cameraNameLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIView *liveInformationHolderView;
@property (weak, nonatomic) IBOutlet UILabel *liveSpeedLabel;
@property (weak, nonatomic) IBOutlet UILabel *liveTotalLabel;
@property (weak, nonatomic) IBOutlet UIPageControlEx *livePageControl;

@property (weak, nonatomic) IBOutlet UIView *alarmMessageButton;

@property (strong, nonatomic) CMPopTipViewQuality *popupQualityView;
@property (nonatomic) VideoQualityType qualityType;

@property (nonatomic) BOOL enableFourChannel;

@property (nonatomic) BOOL enableSound;
@property (nonatomic) BOOL enableMicrophone;
@property (nonatomic) NSInteger currentChannel;

@property (strong,nonatomic) UIImageView *talkImageView;

@property (strong,nonatomic) PlayBottomView *playBottomView;

@property (weak,nonatomic) IBOutlet UIView *bkView;

@property (weak, nonatomic) id<PlayViewControllerDelegate> delegatePlayViewController;

- (IBAction)backButton_TouchUpInside:(id)sender;
/*
- (IBAction)bottomLiveRecordButton_TouchUpInside:(id)sender;
 */

- (IBAction)livePageControl_ChangePage:(id)sender;

@end
