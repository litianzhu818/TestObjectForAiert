

#import <UIKit/UIKit.h>

#import "UITextFieldEx.h"

@interface InputPasswordView : UIControl <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UITextFieldEx *passwordField;
@property (nonatomic, strong) IBOutlet UITextFieldEx *password2Field;

@property (nonatomic, strong) IBOutlet UIImageView *errorImageView;
@property (nonatomic, strong) IBOutlet UILabel *errorLabel;

+ (InputPasswordView *) viewFromXibWithDoneBlock:(void (^)(void))doneBlock;

- (void)setDoneBlock:(void (^)(void))doneBlock;

- (IBAction)passwordField_PressNext:(id)sender;
- (IBAction)password2Field_PressDone:(id)sender;

- (void)showError:(NSString *)message;
- (void)hideError;

@end
