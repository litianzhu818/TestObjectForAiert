

#import "UISwitchEx.h"

@implementation UISwitchEx

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self awakeFromNib];
    }
    return self;
}

- (void)awakeFromNib
{
    self.onTintColor = [UIColor colorWithRed:76/255.0f
                                       green:189/255.0f
                                        blue:231/255.0f
                                       alpha:1.0f];
    self.inactiveColor = [UIColor colorWithRed:188/255.0f
                                          green:188/255.0f
                                           blue:188/255.0f
                                          alpha:1.0f];
}

@end
