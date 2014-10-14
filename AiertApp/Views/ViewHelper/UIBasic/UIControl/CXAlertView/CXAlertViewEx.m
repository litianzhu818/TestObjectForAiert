

#import "CXAlertViewEx.h"
#import "CXAlertView+AppTheme.h"

@implementation CXAlertViewEx

- (id)initWithTitle:(NSString *)title
            message:(NSString *)message
  submitButtonTitle:(NSString *)submitButtonTitle
      submitHandler:(CXAlertButtonHandler)submitHandler
  cancelButtonTitle:(NSString *)cancelButtonTitle
      cancelHandler:(CXAlertButtonHandler)cancelHandler
{
    self = [self initWithTitle:title message:message cancelButtonTitle:nil];
    //
    [self addButtonWithTitle:cancelButtonTitle
                        type:CXAlertViewButtonTypeCancel
                     handler:cancelHandler];
    [self addButtonWithTitle:submitButtonTitle
                        type:CXAlertViewButtonTypeDefault
                     handler:submitHandler];
    //
    [self appThemeSetting];
    //
    return self;
}

- (id)initWithMessage:(NSString *)message
    submitButtonTitle:(NSString *)submitButtonTitle
        submitHandler:(CXAlertButtonHandler)submitHandler
    cancelButtonTitle:(NSString *)cancelButtonTitle
        cancelHandler:(CXAlertButtonHandler)cancelHandler
{
    self = [self initWithTitle:nil message:message
             submitButtonTitle:submitButtonTitle submitHandler:submitHandler
             cancelButtonTitle:cancelButtonTitle cancelHandler:cancelHandler];
    
    self.topScrollViewMinHeight = 0;
    self.scrollViewPadding = 15;
    self.contentScrollViewMinHeight = 50;
    
    return self;
}

@end
