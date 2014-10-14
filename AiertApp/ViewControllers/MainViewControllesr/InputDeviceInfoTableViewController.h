

#import <UIKit/UIKit.h>

#import "UITextFieldEx.h"

@interface InputDeviceInfoTableViewController : UITableViewController

@property (nonatomic, copy) NSString *cameraId;

@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;
@property (weak, nonatomic) IBOutlet UITextFieldEx *deviceNameField;
@property (weak, nonatomic) IBOutlet UILabel *passwordLabel;
@property (weak, nonatomic) IBOutlet UITextFieldEx *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UIImageView *errorImageView;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;

- (IBAction)deviceNameField_PressNext:(id)sender;
- (IBAction)passwordTextField_PressDone:(id)sender;
- (IBAction)submitButton_TouchUpInside:(id)sender;
- (IBAction)backButton_TouchUpInside:(id)sender;
- (IBAction)input_TextChanged:(id)sender;
@end
