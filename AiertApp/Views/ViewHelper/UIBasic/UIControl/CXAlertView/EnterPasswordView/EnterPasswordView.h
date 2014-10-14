

#import <UIKit/UIKit.h>

#import "UITextFieldEx.h"

@interface EnterPasswordView : UIControl <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UITextFieldEx *passwordField;

@property (nonatomic, strong) IBOutlet UIImageView *errorImageView;
@property (nonatomic, strong) IBOutlet UILabel *errorLabel;

+ (EnterPasswordView *) viewFromXibWithDoneBlock:(void (^)(void))doneBlock;

- (void)setDoneBlock:(void (^)(void))doneBlock;

- (IBAction)passwordField_PressDone:(id)sender;

- (void)showError:(NSString *)message;
- (void)hideError;

@end