

#import "CMPopTipView.h"

#import "SelectQualityView.h"

@interface CMPopTipViewQuality : CMPopTipView

@property (nonatomic, strong) SelectQualityView *qualityView;

- (id)initWithBackgroundColor:(UIColor *)color;

@end
