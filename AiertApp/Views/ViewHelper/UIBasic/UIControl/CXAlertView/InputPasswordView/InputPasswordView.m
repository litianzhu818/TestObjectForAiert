
#import "InputPasswordView.h"

@interface InputPasswordView ()
{
    void (^doneBlock)(void);
}

@end

@implementation InputPasswordView

@synthesize passwordField;
@synthesize password2Field;
@synthesize errorImageView;
@synthesize errorLabel;

- (void)setDoneBlock:(void (^)(void))block
{
    doneBlock = block;
}

+ (InputPasswordView *)viewFromXibWithDoneBlock:(void (^)(void))block
{
    InputPasswordView *passwordView = [[[NSBundle mainBundle]loadNibNamed:@"InputPasswordView" owner:self options:nil]objectAtIndex:0];
    
    if (passwordView) {
        [passwordView setDoneBlock:block];
        
        passwordView.passwordField.placeholder = NSLocalizedString(@"Enter new password", @"Enter new password");
        passwordView.password2Field.placeholder = NSLocalizedString(@"Re-enter new password", @"Re-enter new password");
    }
    
    return passwordView;
}

- (void)passwordField_PressNext:(id)sender
{
    [password2Field becomeFirstResponder];
    
}

- (void)password2Field_PressDone:(id)sender
{
    //[passwordField becomeFirstResponder];
    doneBlock();
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    doneBlock();
    return NO;
}

#pragma mark - Show and Hide Error
- (void)showError:(NSString *)message
{
    errorLabel.text = message;
    errorLabel.hidden = NO;
    errorImageView.hidden = NO;
}

- (void)hideError
{
    errorLabel.hidden = YES;
    errorImageView.hidden = YES;
}


@end
