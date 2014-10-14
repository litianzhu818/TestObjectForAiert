

#import "UIScrollViewEx.h"

@implementation UIScrollViewEx

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    

}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    if (_uiScrollViewExDelegate  && [_uiScrollViewExDelegate respondsToSelector:@selector(didTouchesEndedAtUIScrollViewEx:)]) {
        [_uiScrollViewExDelegate didTouchesEndedAtUIScrollViewEx:YES];
    }
    
}

@end
