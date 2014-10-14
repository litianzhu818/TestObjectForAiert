
#import <UIKit/UIKit.h>

@interface DeviceWifiSettingTableViewController : UITableViewController
{
    BOOL _wifiOn;
}

@property (nonatomic) BOOL wifiOn;

- (IBAction)backButton_TouchUpInside:(id)sender;

@end
