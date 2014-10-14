

#import "DeviceWifiSettingTopCell.h"

@implementation DeviceWifiSettingTopCell

@synthesize titleLabel;
@synthesize wifiSwitch;
@synthesize activityIndicatorView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self awakeFromNib];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.wifiSwitch.backgroundColor = [UIColor clearColor];
    activityIndicatorView.hidden = YES;
    [activityIndicatorView stopAnimating];
}

@end
