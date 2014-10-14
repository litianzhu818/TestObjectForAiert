

#import <UIKit/UIKit.h>

@interface AddDeviceMainViewController : BaseViewController

//Sub view - move for keyboard
@property (nonatomic, strong) IBOutlet UIView *subView;

@property (nonatomic, strong) IBOutlet UILabel *firstMethodTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel *firstMethodDescriptionLabel;
@property (nonatomic, strong) IBOutlet UILabel *secondMethodTitleLabel;

@property (nonatomic, strong) IBOutlet UIButton *scanQrCodeButton;
@property (nonatomic, strong) IBOutlet UIButton *searchCameraIdButton;
@property (nonatomic, strong) IBOutlet UIButton *scanDeviceInLanButton;

@property (nonatomic, strong) IBOutlet UIImageView *errorImageView;
@property (nonatomic, strong) IBOutlet UILabel *errorLabel;

@property (nonatomic, strong) IBOutlet UITextField *cameraIdField;

@property (nonatomic, strong) IBOutlet UIView *busyView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicatorView;

//- (IBAction)backButton_TouchUpInside:(id)sender;
- (IBAction)cameraIdField_PressDone:(id)sender;
- (IBAction)background_TouchDown:(id)sender;

- (IBAction)searchCameraIdButton_TouchUpInside:(id)sender;

@end
