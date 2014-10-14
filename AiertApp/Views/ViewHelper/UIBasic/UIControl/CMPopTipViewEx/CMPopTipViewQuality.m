

#import "CMPopTipViewQuality.h"

@implementation CMPopTipViewQuality

@synthesize qualityView;

- (id)initWithBackgroundColor:(UIColor *)color
{
    SelectQualityView *sqView = [SelectQualityView viewFromXib];
    
    self = [self initWithCustomView:sqView];
    if (self) {
        self.qualityView = sqView;
        
        self.hasGradientBackground = NO;
        self.backgroundColor = color;
        self.animation = CMPopTipAnimationPop;
        self.textColor = [UIColor whiteColor];
        self.has3DStyle = NO;
        self.borderWidth = 0;
        self.dismissTapAnywhere = YES;
        
        self.cornerPadding = 0;
        self.cornerRadius = 1.0;
        self.pointerSize = 6.0f;
        //self.topMargin = -1.0f;
    }
    return self;
}

@end
