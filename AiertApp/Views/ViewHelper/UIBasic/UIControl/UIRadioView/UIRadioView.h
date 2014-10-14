

#import <UIKit/UIKit.h>

@interface UIRadioView : UIControl
{
    BOOL _radioSelected;
    
    CALayer *radioLayer;
}

@property (nonatomic) BOOL radioSelected;

@end
