
#import "DragButton.h"

#define kTags                             100001
//#define kShow_SelectAll_Button            1
//#define kShow_Delete_Button               1

@implementation DragButton
@synthesize dragButtonDelegate = dragButtonDelegate_;
@synthesize selectedImageView = selectedImageView_;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
       
    }
    return self;
}

- (id)initWithFrameWithType:(CGRect)frame Type:(NSInteger)aType
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIView *bkView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, self.bounds.size.width- 10.0, self.bounds.size.height - 10.0)];
        [bkView setBackgroundColor:[UIColor clearColor]];
        bkView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:bkView];
        
        UITapGestureRecognizer *singleRecognizer;
        singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapFrom:)];
        singleRecognizer.numberOfTapsRequired = 1;
        [bkView addGestureRecognizer:singleRecognizer];
        
        UITapGestureRecognizer *doubleRecognizer;
        doubleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapFrom:)];
        doubleRecognizer.numberOfTapsRequired = 2;
        [bkView addGestureRecognizer:doubleRecognizer];

       
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressDrag:)];
        [self addGestureRecognizer:longPress];
        
        
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.selectedImageView = imageView;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:imageView];
        
#ifdef kShow_Delete_Button
        UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(-5, -5, 20, 20)];
        [button setBackgroundImage:[UIImage imageNamed:@"del.png"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = kTags;
        [button setBackgroundColor:[UIColor clearColor]];
        [self addSubview:button];
#endif

        
#ifdef kShow_SelectAll_Button
        UIButton* selectedButton = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width- 15,-5, 20, 20)];
        [selectedButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        selectedButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        selectedButton.tag = kTags + 1;
        [self addSubview:selectedButton];
#endif
        
        _bChoiced = NO;
        _bLongPressed = NO;
    }
    return self;
}


- (void)setDragButtonBackgroundImage:(UIImage *)image forState:(UIControlState)state {
    [super setBackgroundImage:image forState:state];
    
}

- (void)addDragButtonTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents {
    [super addTarget:target action:action forControlEvents:controlEvents];
}

- (void)showDelButton:(BOOL)bShow {
    
    UIButton *button = (UIButton *)[self viewWithTag:kTags];
    if (bShow) {
        button.alpha = 1.0;
    }
    else {
        button.alpha = 0.0;
    }
    
}
- (void)buttonAction:(id)sender {
    UIButton *button = (UIButton *)sender;
    int nTag = button.tag;
    switch (nTag) {
        case kTags: {
            if (dragButtonDelegate_ && [(id)dragButtonDelegate_ respondsToSelector:@selector(delButtonAtIndexInDragButton:)]) {
                [dragButtonDelegate_ delButtonAtIndexInDragButton:self.tag];
            }
        }
            return;
            break;
        case kTags + 1: {
            _bChoiced = !_bChoiced;
            [button setBackgroundImage:[UIImage imageNamed:@"MorView_Select.png"] forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage imageNamed:@"MorView_Select.png"] forState:UIControlStateHighlighted];

            
        }
            return;
            break;
        default:
            break;
    }
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UIButton class]]) {
        return NO;
    }
    return YES;
}

- (void)longPressDrag:(UILongPressGestureRecognizer *)sender {
    if (_bChoiced) {
        return;
    }
    switch (sender.state) {
        case UIGestureRecognizerStateBegan: {
            if (dragButtonDelegate_ && [(id)dragButtonDelegate_ respondsToSelector:@selector(didLongPressDrag:)]) {
                [dragButtonDelegate_ didLongPressDrag:nil];
            }
            
            //////////////
            //长按支持选中
            if (dragButtonDelegate_ && [(id)dragButtonDelegate_ respondsToSelector:@selector(singleClickAtIndexInDragButton:)]) {
                [dragButtonDelegate_ singleClickAtIndexInDragButton:self.tag];
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
            break;
        default:
            break;
    }
}


- (void)handleSingleTapFrom:(UITapGestureRecognizer *)sender {
    if (dragButtonDelegate_ && [(id)dragButtonDelegate_ respondsToSelector:@selector(singleClickAtIndexInDragButton:)]) {
        [dragButtonDelegate_ singleClickAtIndexInDragButton:self.tag];
    }
}

- (void)handleDoubleTapFrom:(UITapGestureRecognizer *)sender {
    /*if (dragButtonDelegate_ && [(id)dragButtonDelegate_ respondsToSelector:@selector(doubleClickAtIndexInDragButton:)]) {
     [dragButtonDelegate_ doubleClickAtIndexInDragButton:self.tag];
     }*/
}


- (void)didSelectImageView:(BOOL)bSelect {
    if (bSelect) {
        self.selectedImageView.image = [UIImage imageNamed:@"picture_cell_select.png"];
    }
    else {
        self.selectedImageView.image = [UIImage imageNamed:@"picture_cell.png"];
    }
}

- (void)didChoiceAllButton:(BOOL)bChoice {
    _bChoiced = bChoice;
    UIButton *button = (UIButton *)[self viewWithTag:kTags +1];
    if (bChoice) {
        [button setBackgroundImage:[UIImage imageNamed:@"MorView_Select.png"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"MorView_Select.png"] forState:UIControlStateHighlighted];
    }
    else {
        [button setBackgroundImage:nil forState:UIControlStateNormal];
    }
}


@end
