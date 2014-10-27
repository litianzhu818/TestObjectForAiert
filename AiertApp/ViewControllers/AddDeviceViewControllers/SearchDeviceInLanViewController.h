

#import <UIKit/UIKit.h>
#import "PingLocalNetWorkProtocal.h"
#import "AiertDeviceCoreDataManager.h"

#define MARGIN_WIDTH 10.0f

@protocol SearchDeviceInLanDelegate;

@interface SearchDeviceInLanViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate ,PingLocalNetWorkProtocalDelegate>

@property (weak, nonatomic) IBOutlet UILabel *foundNoneDescriptionLabel;

//Sub view - move for keyboard
@property (weak, nonatomic) IBOutlet UIView *subView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIButton *refreshButton;

@property (assign, nonatomic) id<SearchDeviceInLanDelegate> delegate;

- (IBAction)background_TouchDown:(id)sender;
- (IBAction)refreshButton_TouchUpInside:(id)sender;

@end

@protocol SearchDeviceInLanDelegate <NSObject>

@optional

-(void)searchDeviceInLanController:(SearchDeviceInLanViewController *)controller didAddDevice:(AiertDeviceInfo *)device;

@end
