

#import "DeviceWifiSettingCell.h"

#import "UIColor+AppTheme.h"

@interface DeviceWifiSettingCell()
{
    BOOL _showDescription;
}

@property (nonatomic) BOOL showDescription;

@property (weak, nonatomic) IBOutlet UILabel *titleLabelWithoutDescription;
@property (weak, nonatomic) IBOutlet UILabel *titleLabelWithDescription;

@end

@implementation DeviceWifiSettingCell

@synthesize titleLabelWithoutDescription;
@synthesize titleLabelWithDescription;
@synthesize descriptionLabel;
@synthesize imageView;

+ (DeviceWifiSettingCell *)cellFromXib
{
    DeviceWifiSettingCell *cell = [[[NSBundle mainBundle]loadNibNamed:@"DeviceWifiSettingCell" owner:self options:nil]objectAtIndex:0];
    
    if (cell) {
        [cell awakeFromNib];
    }
    
    return cell;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    //
    _showDescription = YES;
    self.showDescription = NO;
    
    self.descriptionLabel.textColor = [UIColor AppThemeSelectedTextColor];
    
    self.wifiStatus = DeviceWifiStatusDisconnetedWithoutPassword;
    
    self.descriptionLabel.text = NSLocalizedString(@"Connected", @"Connected");
}

- (UILabel *)titleLabel
{
    return _showDescription ? titleLabelWithDescription : titleLabelWithoutDescription;
}

- (DeviceWifiStatus)wifiStatus
{
    return _wifiStatus;
}

- (void)setWifiStatus:(DeviceWifiStatus)wifiStatus
{
    _wifiStatus = wifiStatus;
    
    UIImage *image = nil;
    BOOL showDes = NO;
    
    switch (_wifiStatus) {
        case DeviceWifiStatusConnetedWithoutPassword:
            image = [UIImage imageNamed:@"icon_wifi_selected.png"];
            showDes = YES;
            break;
        case DeviceWifiStatusConnetedWithPassword:
            image = [UIImage imageNamed:@"icon_wifi_lock_selected.png"];
            showDes = YES;
            break;
        case DeviceWifiStatusDisconnetedWithoutPassword:
            image = [UIImage imageNamed:@"icon_wifi_unselected.png"];
            showDes = NO;
            break;
        case DeviceWifiStatusDisconnetedWithPassword:
            image = [UIImage imageNamed:@"icon_wifi_lock_unselected.png"];
            showDes = NO;
            break;
            
        default:
            break;
    }
    
    self.imageView.image = image;
    self.showDescription = showDes;
}

-(BOOL)showDescription
{
    return _showDescription;
}

- (void)setShowDescription:(BOOL)showDescription
{
    if (_showDescription != showDescription) {
        _showDescription = showDescription;
        if (_showDescription) {
            titleLabelWithDescription.text = titleLabelWithoutDescription.text;
        }
        else {
            titleLabelWithoutDescription.text = titleLabelWithDescription.text;
        }
        
        //
        titleLabelWithDescription.hidden = !_showDescription;
        titleLabelWithoutDescription.hidden = _showDescription;
        descriptionLabel.hidden = !_showDescription;
    }
}

@end
