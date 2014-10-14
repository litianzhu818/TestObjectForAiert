

#import "UIButtonWithTouchDown.h"

@implementation UIButtonWithTouchDown

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressDrag:)];
        [self addGestureRecognizer:longPress];
    }
    return self;
}
/*
- (id)initWithTouchDownBlock:(void(^)(id))touchDownBlock
                touchUpBlock:(void(^)(id))touchUpBlock
{
    if (self = [super init]) {
       // self.touchDown = touchDownBlock;
      //  self.touchUp = touchUpBlock;
    }
    
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
   // _touchDown(self);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
   // _touchUp(self);
}
*/

- (void)longPressDrag:(UILongPressGestureRecognizer *)sender {
    switch (sender.state) {
        case UIGestureRecognizerStateBegan: {
            if (_buttonWithTouchDownDelegate && [(id)_buttonWithTouchDownDelegate respondsToSelector:@selector(didLongPressBeganInUIButtonWithTouchDown: Tag:)]) {
                [_buttonWithTouchDownDelegate didLongPressBeganInUIButtonWithTouchDown:nil Tag:self.tag];
            }
        }
            break;
        case UIGestureRecognizerStateEnded: {
            if (_buttonWithTouchDownDelegate && [(id)_buttonWithTouchDownDelegate respondsToSelector:@selector(didLongPressEndInUIButtonWithTouchDown: Tag:)]) {
                [_buttonWithTouchDownDelegate didLongPressEndInUIButtonWithTouchDown:nil Tag:self.tag];
            }
        }
            break;
        default:
            break;
    }
}


@end
