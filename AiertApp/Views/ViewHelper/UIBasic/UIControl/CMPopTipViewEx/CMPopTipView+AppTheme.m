

#import "CMPopTipView+AppTheme.h"

@implementation CMPopTipView (AppTheme)

- (id)initWithMessage:(id)contentMessage
      backgroundColor:(UIColor *)color
{
    self = [self initWithMessage:contentMessage];
    if (self) {
        self.hasGradientBackground = NO;
        self.backgroundColor = color;
        self.animation = CMPopTipAnimationPop;
        self.textColor = [UIColor whiteColor];
        self.has3DStyle = NO;
        self.borderWidth = 0;
        self.dismissTapAnywhere = YES;
        
        self.cornerPadding = 10;
        self.cornerRadius = 2.0;
        self.pointerSize = 6.0f;
        //self.topMargin = -1.0f;
    }
    return self;
}

@end
