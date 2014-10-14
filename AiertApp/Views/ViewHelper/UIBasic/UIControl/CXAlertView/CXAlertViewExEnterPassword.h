
#import "CXAlertView.h"

@interface CXAlertViewExEnterPassword : CXAlertView

@property (nonatomic, strong) NSString *password;

- (id)initWithTitle:(NSString *)title
  submitButtonTitle:(NSString *)submitButtonTitle
      submitHandler:(CXAlertButtonHandler)submitHandler
  cancelButtonTitle:(NSString *)cancelButtonTitle
      cancelHandler:(CXAlertButtonHandler)cancelHandler;

- (void)show;
- (void)dismiss;

@end
