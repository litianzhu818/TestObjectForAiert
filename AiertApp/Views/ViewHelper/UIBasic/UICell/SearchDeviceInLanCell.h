

#import <UIKit/UIKit.h>

@interface SearchDeviceInLanCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *mainImageView;

//
+ (SearchDeviceInLanCell *)cellFromXib;

@end
