

#import <UIKit/UIKit.h>

#import "BasicDefine.h"

@interface DeviceWifiSettingCell : UITableViewCell
{
    DeviceWifiStatus _wifiStatus;
}

@property (weak, nonatomic, readonly) UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (nonatomic) DeviceWifiStatus wifiStatus;

//
+ (DeviceWifiSettingCell *)cellFromXib;

@end
