

#import "SelectQualityView.h"

@implementation SelectQualityView

@synthesize ldButton;
@synthesize sdButton;
@synthesize hdButton;
@synthesize delegate;

+ (SelectQualityView *)viewFromXib
{
    SelectQualityView *selectQualityView = [[[NSBundle mainBundle]loadNibNamed:@"SelectQualityView" owner:self options:nil]objectAtIndex:0];
    
    return selectQualityView;
}

- (VideoQualityType)qualityType
{
    return _qualityType;
}

- (void)setQualityType:(VideoQualityType)qualityType
{
    _qualityType = qualityType;
    
    [self updateUI];
}

- (IBAction)ldButton_TouchDown:(id)sender
{
    [self changeQualityTo:VideoQualityTypeLD];
}

- (IBAction)sdButton_TouchDown:(id)sender
{
    [self changeQualityTo:VideoQualityTypeSD];
}

- (IBAction)hdButton_TouchDown:(id)sender
{
    [self changeQualityTo:VideoQualityTypeHD];
}

- (void)changeQualityTo:(VideoQualityType)newQualityType
{
    self.qualityType = newQualityType;
    if (delegate) {
        [delegate selectQualityView:self changeQualityTo:self.qualityType];
    }
}

- (void)updateUI
{
    UIButton *on = nil;
    UIButton *off1 = nil;
    UIButton *off2 = nil;
    switch (self.qualityType) {
        case VideoQualityTypeLD:
            on = ldButton;
            off1 = sdButton;
            off2 = hdButton;
            break;
        case VideoQualityTypeSD:
            off1 = ldButton;
            on = sdButton;
            off2 = hdButton;
            break;
        case VideoQualityTypeHD:
            off1 = ldButton;
            off2 = sdButton;
            on = hdButton;
            break;
        default:
            break;
    }
    on.selected = YES;
    off1.selected = NO;
    off2.selected = NO;
}

@end
