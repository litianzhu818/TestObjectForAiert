

#import "EnterPasswordView.h"

@interface EnterPasswordView ()
{
    void (^doneBlock)(void);
}

@end

@implementation EnterPasswordView

@synthesize passwordField;
@synthesize errorImageView;
@synthesize errorLabel;

- (void)setDoneBlock:(void (^)(void))block
{
    doneBlock = block;
}

+ (EnterPasswordView *)viewFromXibWithDoneBlock:(void (^)(void))block
{
    EnterPasswordView *passwordView = [[[NSBundle mainBundle]loadNibNamed:@"EnterPasswordView" owner:self options:nil]objectAtIndex:0];
    
    if (passwordView) {
        [passwordView setDoneBlock:block];
        
        passwordView.passwordField.placeholder = NSLocalizedString(@"Please enter password", @"Please enter password");
    }
    
    return passwordView;
}

- (void)passwordField_PressDone:(id)sender
{
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
