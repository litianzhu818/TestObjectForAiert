

#import "CXAlertView+AppTheme.h"

#import "UIColor+AppTheme.h"

@implementation CXAlertView (AppTheme)

- (void)appThemeSetting
{
    self.showBlurBackground = YES;
    self.showButtonLine = YES;
        
    if (self.contentView) {
        self.contentScrollViewMaxHeight = self.contentView.frame.size.height + 1;
    }
    
    self.cornerRadius = 4;
    self.shadowRadius = 4;
    
    //
    self.buttonColor = [UIColor blackColor];
    self.cancelButtonColor = [UIColor blackColor];
    self.cancelButtonFont = self.buttonFont;
    
    self.titleColor = [UIColor AppThemeSelectedTextColor];
    
    for (int i = 0; i < self.buttons.count; i++) {
        UIButton *button = [self.buttons objectAtIndex:i];
        //[button setBackgroundColor:[UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:1.0f]];
        //[button setTitleColor:[UIColor colorWithRed:204/255.0f green:204/255.0f blue:204/255.0f alpha:1.0f] forState:UIControlStateHighlighted];
        [button setTitleColor:[UIColor AppThemeSelectedTextColor] forState:UIControlStateHighlighted];
        //[button setBackgroundImage:[UIImage imageNamed:@"Dialog_botton_selected.png"] forState:UIControlStateHighlighted];
    }
    
}

@end
