

#import <UIKit/UIKit.h>

#import "CMPopTipViewQuality.H"
#import "BasicDefine.h"
#import "UIButtonWithTouchDown.h"
#import "Utilities.h"
#import "ZMRecorderFileIndex.h"
#import "SVProgressHUD.h"
#import "ZMRecorderFileIndexManage.h"

#import "PlayerView.h"


@protocol PlayViewControllerDelegate <NSObject>

@optional
- (void)dismissViewControllerInPlayViewControlller:(BOOL)dismiss;

@end

@class ZMDevice;
@interface PlayViewController : BaseViewController <SelectQualityViewDelegate, CMPopTipViewDelegate, UIScrollViewDelegate,PlayViewControllerDelegate>
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
@property (assign, nonatomic) CGFloat width;
@property (assign, nonatomic) CGFloat height;
@property (assign, nonatomic) int turnCameraSpeed;

@property (strong, nonatomic) PlayerView *playerView;

@property (nonatomic) VideoQualityType qualityType;

@property (nonatomic) BOOL enableFourChannel;

@property (nonatomic) BOOL enableSound;
@property (nonatomic) BOOL enableMicrophone;
@property (nonatomic) NSInteger currentChannel;


@property (weak, nonatomic) id<PlayViewControllerDelegate> delegatePlayViewController;

- (IBAction)closeButton_TouchUpInside:(id)sender;
/*
- (IBAction)bottomLiveRecordButton_TouchUpInside:(id)sender;
 */

- (IBAction)livePageControl_ChangePage:(id)sender;

@end
