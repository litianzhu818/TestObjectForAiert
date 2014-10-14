

#import <UIKit/UIKit.h>

@interface AlarmMessageCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *alarmImage;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UIView *backView;

@property (nonatomic) BOOL ifRead;

@end
