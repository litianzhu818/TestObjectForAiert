

#import "UIPageControlEx.h"

#import "UIColor+AppTheme.h"

@implementation UIPageControlEx

//@synthesize selectedImage;
//@synthesize unselectedImage;

- (void)updateDots
{
    for (int i = 0; i < [self.subviews count]; i++)
    {
        UIView* dot = [self.subviews objectAtIndex:i];
        if (i == self.currentPage) dot.backgroundColor = [UIColor AppThemeSelectedTextColor];
        else dot.backgroundColor = [UIColor lightGrayColor];
        dot.layer.cornerRadius = 0;
    }
}

- (void)setCurrentPage:(NSInteger)page
{
    [super setCurrentPage:page];
    [self updateDots];
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super endTrackingWithTouch:touch withEvent:event];
    [self updateDots];
}


@end
