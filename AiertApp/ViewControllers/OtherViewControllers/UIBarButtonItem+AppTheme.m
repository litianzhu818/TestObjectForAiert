

#import "UIBarButtonItem+AppTheme.h"

@implementation UIBarButtonItem (AppTheme)

+ (UIBarButtonItem *)createBackBarButtonItemWithTarget:(id)target action:(SEL)sel
{    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(5, 0, 40, 44)];
    button.contentMode = UIViewContentModeScaleToFill;
    button.opaque = NO;
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    button.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                               UIViewAutoresizingFlexibleTopMargin);
    [button setImage:[UIImage imageNamed:@"navigationbar_back_unselected"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"navigationbar_back_selected"] forState:UIControlStateSelected];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    [button addTarget:target action:sel forControlEvents:UIControlEventTouchUpInside];
    
    return item;
}

@end
