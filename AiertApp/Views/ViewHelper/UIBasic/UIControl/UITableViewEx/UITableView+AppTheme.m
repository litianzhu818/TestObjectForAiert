

#import "UITableView+AppTheme.h"

@implementation UITableView (AppTheme)

- (void)hideExtraCellLine
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    [self setTableFooterView:view];
}

@end
