

#import <UIKit/UIKit.h>

#import "UISwitchEx.h"

@interface DeviceWifiSettingTopCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UISwitchEx *wifiSwitch;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@end
