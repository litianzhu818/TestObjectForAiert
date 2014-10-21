

#import <UIKit/UIKit.h>
#import "BasicDefine.h"
#import "DeviceListCell.h"
#import "UIColor+AppTheme.h"
#import "CMPopTipView+AppTheme.h"
#import "UITableView+AppTheme.h"
#import "AppData.h"
#import "ZSWebInterface.h"
#import "SVProgressHUD.h"
#import "ZMDevice.h"
#import "PlayViewController.h"
#import "AiertHeaderView.h"
#import "AiertDeviceCoreDataStorage.h"
#import "EditDeviceViewController.h"

#define MARGIN_WIDTH 10.0f

@interface DeviceListViewController : BaseViewController <PlayViewControllerDelegate>
{
    
}
@property (weak, nonatomic) IBOutlet AiertHeaderView *headerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;

-(IBAction)clikedOnEditButton:(id)sender;

@end
