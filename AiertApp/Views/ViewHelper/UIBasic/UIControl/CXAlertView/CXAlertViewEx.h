

#import "CXAlertView.h"

@interface CXAlertViewEx : CXAlertView

- (id)initWithTitle:(NSString *)title
            message:(NSString *)message
  submitButtonTitle:(NSString *)submitButtonTitle
      submitHandler:(CXAlertButtonHandler)submitHandler
  cancelButtonTitle:(NSString *)cancelButtonTitle
      cancelHandler:(CXAlertButtonHandler)cancelHandler;

- (id)initWithMessage:(NSString *)message
    submitButtonTitle:(NSString *)submitButtonTitle
        submitHandler:(CXAlertButtonHandler)submitHandler
    cancelButtonTitle:(NSString *)cancelButtonTitle
        cancelHandler:(CXAlertButtonHandler)cancelHandler;

@end
