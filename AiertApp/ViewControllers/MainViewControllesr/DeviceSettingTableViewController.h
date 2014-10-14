

#import <UIKit/UIKit.h>

#import "UITextFieldEx.h"

@interface DeviceSettingTableViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, copy) NSString *currentDeviceName;
@property (nonatomic) BOOL modifyPasswordHidden;
@property (nonatomic) BOOL modifyDeviceNameHidden;

@property (weak, nonatomic) IBOutlet UILabel *modifyPasswordTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *modifyPasswordArrowImageView;
@property (weak, nonatomic) IBOutlet UILabel *modifyPasswordUserNameTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *modifyPasswordUserNameValueLablel;
@property (weak, nonatomic) IBOutlet UILabel *modifyPasswordOldPasswordTitleLabel;
@property (weak, nonatomic) IBOutlet UITextFieldEx *modifyPasswordOldPasswordField;
@property (weak, nonatomic) IBOutlet UILabel *modifyPasswordNewPasswordTitleLabel;
@property (weak, nonatomic) IBOutlet UITextFieldEx *modifyPasswordNewPasswordField;
@property (weak, nonatomic) IBOutlet UILabel *modifyPasswordConfirmPasswordTitleLabel;
@property (weak, nonatomic) IBOutlet UITextFieldEx *modifyPasswordComfirmPasswordField;
@property (weak, nonatomic) IBOutlet UIButton *modifyPasswordSubmitButton;
@property (weak, nonatomic) IBOutlet UIView *modifyPasswordBusyView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *modifyPasswordActivityIndicatorView;
@property (weak, nonatomic) IBOutlet UIImageView *modifyPasswordErrorImageView;
@property (weak, nonatomic) IBOutlet UILabel *modifyPasswordErrorLabel;

@property (weak, nonatomic) IBOutlet UILabel *modifyDeviceNameTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *modifyDeviceNameArrowImageView;
@property (weak, nonatomic) IBOutlet UILabel *modifyDeviceNameNewNameTitleLabel;
@property (weak, nonatomic) IBOutlet UITextFieldEx *modifyDeviceNameNewNameField;
@property (weak, nonatomic) IBOutlet UIButton *modifyDeviceNameSubmitButton;
@property (weak, nonatomic) IBOutlet UIView *modifyDeviceNameBusyView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *modifyDeviceNameActivityIndicatorView;
@property (weak, nonatomic) IBOutlet UIImageView *modifyDeviceNameErrorImageView;
@property (weak, nonatomic) IBOutlet UILabel *modifyDeviceNameErrorLabel;

@property (weak, nonatomic) IBOutlet UILabel *wifiSettingTitleLabel;


- (IBAction)modifyPasswordOldPasswordField_PressNext:(id)sender;
- (IBAction)modifyPasswordNewPasswordField_PressNext:(id)sender;
- (IBAction)modifyPasswordComfirmPasswordField_PressDone:(id)sender;

- (IBAction)modifyDeviceNameNewNameField_PressDone:(id)sender;

- (IBAction)modifyPasswordSubmitButton_TouchUpInside:(id)sender;
- (IBAction)modifyDeviceNameSubmitButton_TouchUpInside:(id)sender;

- (IBAction)backButton_TouchUpInside:(id)sender;

@end
