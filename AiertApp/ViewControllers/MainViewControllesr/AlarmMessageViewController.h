

#import <UIKit/UIKit.h>
#import "MessageInfo.h"

@interface AlarmMessageViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *alarmImageView;
@property (strong, nonatomic) MessageInfo *message;

@property (weak, nonatomic) IBOutlet UIButton *alarmVideoButton;
@property (weak, nonatomic) IBOutlet UIButton *liveButton;

- (IBAction)backButton_TouchUpInside:(id)sender;
- (IBAction)liveButtonClick:(UIButton *)sender;
- (IBAction)alarmVideoClick:(UIButton *)sender;
- (IBAction)deleteButtonClick:(id)sender;

@end
