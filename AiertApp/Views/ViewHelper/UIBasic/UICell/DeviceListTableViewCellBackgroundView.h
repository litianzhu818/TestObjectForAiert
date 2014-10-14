

#import <UIKit/UIKit.h>

@interface DeviceListTableViewCellBackgroundView : UIView
{
    CALayer *backgroundLayer;
}

@property (nonatomic) int CellBorder;

- (id)initWithFrame:(CGRect)frame border:(int)border;

@end
