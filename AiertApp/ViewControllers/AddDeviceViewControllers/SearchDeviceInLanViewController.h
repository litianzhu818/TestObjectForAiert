

#import <UIKit/UIKit.h>
#import "PingLocalNetWorkProtocal.h"

@interface SearchDeviceInLanViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate ,PingLocalNetWorkProtocalDelegate>

@property (weak, nonatomic) IBOutlet UILabel *foundNoneDescriptionLabel;

//Sub view - move for keyboard
@property (weak, nonatomic) IBOutlet UIView *subView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIButton *scanQrCodeButton;
@property (weak, nonatomic) IBOutlet UIButton *searchCameraIdButton;

@property (weak, nonatomic) IBOutlet UIImageView *errorImageView;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;

@property (weak, nonatomic) IBOutlet UITextField *cameraIdField;

@property (weak, nonatomic) IBOutlet UIView *busyView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@property (weak, nonatomic) IBOutlet UIButton *refreshButton;

- (IBAction)background_TouchDown:(id)sender;
- (IBAction)cameraIdField_PressDone:(id)sender;
- (IBAction)refreshButton_TouchUpInside:(id)sender;

@end
