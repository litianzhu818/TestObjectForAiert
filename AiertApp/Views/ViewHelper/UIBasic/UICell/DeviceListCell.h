

#import <UIKit/UIKit.h>

@interface DeviceListCell : UITableViewCell
@property (strong, nonatomic) UILabel *titleLabel;

+ (DeviceListCell *)cellWithIdentifier:(NSString *)identifier
                                 frame:(CGRect)frame
                          channelCount:(NSInteger)channelCount;
@end
