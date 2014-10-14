

#import "CXAlertViewExEnterPassword.h"

#import "CXAlertView+AppTheme.h"
#import "EnterPasswordView.h"

@interface CXAlertView ()

- (void)resetOnOrientation:(UIInterfaceOrientation)toInterfaceOrientation;

@end

@interface CXAlertViewExEnterPassword ()
{
    CXAlertButtonHandler submitHandler;
}

@property (nonatomic, strong) EnterPasswordView *passwordView;

@end

@implementation CXAlertViewExEnterPassword

@synthesize passwordView;

- (id)initWithTitle:(NSString *)title
  submitButtonTitle:(NSString *)submitButtonTitle
      submitHandler:(CXAlertButtonHandler)aSubmitHandler
  cancelButtonTitle:(NSString *)cancelButtonTitle
      cancelHandler:(CXAlertButtonHandler)cancelHandler
{
    //
    passwordView = [EnterPasswordView viewFromXibWithDoneBlock:^{
        [self doneInputPasswordWith:self button:nil];
    }];
    
    self = [self initWithTitle:title contentView:passwordView cancelButtonTitle:nil];
    
    submitHandler = aSubmitHandler;
    
    __weak typeof(self) weakSelf = self;
    //
    [self addButtonWithTitle:cancelButtonTitle
                        type:CXAlertViewButtonTypeCancel
                     handler:cancelHandler];
    [self addButtonWithTitle:submitButtonTitle
                        type:CXAlertViewButtonTypeDefault
                     handler:^(CXAlertView *alertView, CXAlertButtonItem *button) {
                         [weakSelf doneInputPasswordWith:alertView button:button];
                     }];
    //
    [self appThemeSetting];
    
    [self.passwordView addTarget:self action:@selector(textFieldresignFirstResponder) forControlEvents:UIControlEventTouchDown];
    
    return self;
}

- (void)doneInputPasswordWith:(CXAlertView *)alertView button:(CXAlertButtonItem *)button
{
    if (passwordView.passwordField.text.length == 0) {
        [self shake];
        [passwordView showError:NSLocalizedString(@"Please enter password",@"Please enter password")];
        return;
    }
    //
    self.password = passwordView.passwordField.text;
    
    submitHandler(alertView, button);
}

- (void)show
{
    [super show];
    
    //Keyboard
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
#ifdef __IPHONE_5_0
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 5.0) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
#endif
    
}

- (void)dismiss
{
    [self textFieldresignFirstResponder];
    
    //Keyboard
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dismiss];
}

- (void)resetOnOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    [super resetOnOrientation:toInterfaceOrientation];
    
    [self performSelector:@selector(textFieldresignFirstResponder) withObject:nil afterDelay:0.5f];
    //[self.passwordView.passwordField becomeFirstResponder];
}

- (void)textFieldresignFirstResponder
{
    [self.passwordView.passwordField resignFirstResponder];
}

#pragma mark - Keyboard

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    
    if (keyboardRect.origin.x < 0) {
        return;
    }
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    UIViewAnimationCurve curve;
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&curve];
    
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    //CGFloat size = MIN(keyboardRect.size.height, keyboardRect.size.width);
    //// Animate the resize of the text view's frame in sync with the keyboard's appearance.
    CGFloat size = [self convertRect:keyboardRect fromView:nil].size.height; //
    
    //
    CGRect frame = self.frame;
    frame.origin = CGPointMake(0, 0);
    self.frame = frame;
    
    CGRect frameNew = [self convertRect:frame fromView:nil];
    
    CGFloat screenHight = [self convertRect:[UIScreen mainScreen].bounds fromView:nil].size.height;
    
    CGFloat y = ((screenHight - size)
                 - frameNew.size.height) / 2;
    
    if (frameNew.size.height != frame.size.height){//横屏幕
        y += (y > 0) ? 15 : -15;
    }
    
    frameNew.origin = CGPointMake(frameNew.origin.x, y);
    CGRect frameBack = [self convertRect:frameNew toView:nil];
    
    if (frameBack.origin.x == 0 || frameBack.origin.y == 0) {
        //
        [UIView beginAnimations:@"Curl"context:nil];//动画开始
        [UIView setAnimationDuration:animationDuration];
        [UIView setAnimationCurve:curve];
        [UIView setAnimationDelegate:self];
        [self setFrame:frameBack];
        [UIView commitAnimations];
    }
    
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    UIViewAnimationCurve curve;
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&curve];
    
    //
    CGRect frame = self.frame;
    if (frame.origin.y != 0 || frame.origin.x != 0) {
        frame.origin = CGPointMake(0, 0);
        //
        [UIView beginAnimations:@"Curl"context:nil];//动画开始
        [UIView setAnimationDuration:animationDuration];
        [UIView setAnimationCurve:curve];
        [UIView setAnimationDelegate:self];
        [self setFrame:frame];
        [UIView commitAnimations];
    }
    
}


@end
