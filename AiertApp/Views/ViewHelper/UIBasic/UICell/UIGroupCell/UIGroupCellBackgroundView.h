

#import <UIKit/UIKit.h>

#define kUIGroupCellBorderLeftRight 14.0f

#define kUIGroupCellLineWidth  0.5f
#define kUIGroupCellLineCorner 3.0f

#define kUIGroupCellColorBackground [UIColor whiteColor]
#define kUIGroupCellColorLine [UIColor lightGrayColor]

typedef NS_ENUM(NSInteger, UIGroupCellTagType) {
    UIGroupCellTagTypeTop = 1,
    UIGroupCellTagTypeMiddle = 0,
    UIGroupCellTagTypeBottom = -1,
    UIGroupCellTagTypeSeparate = -2
};

@interface UIGroupCellBackgroundView : UIView
{
    CALayer *backgroundLayer;
}

- (id)initWithFrame:(CGRect)frame selectionColor:(UIColor *)selectionColor tag:(NSInteger) tag;

@property (nonatomic, strong) UIColor *selectionColor;

@end
