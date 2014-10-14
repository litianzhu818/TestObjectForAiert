
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>





@interface GradientView : UIView {
}

// Returns the view's layer. Useful if you want to access CAGradientLayer-specific properties
// because you can omit the typecast.
@property (nonatomic, readonly) CAGradientLayer *gradientLayer;

// Gradient-related properties are forwarded to layer.
// colors also accepts array of UIColor objects (in addition to array of CGColorRefs).
@property (nonatomic, retain) NSArray *colors;
@property (nonatomic, retain) NSArray *locations;
@property (nonatomic) CGPoint startPoint;
@property (nonatomic) CGPoint endPoint;
@property (nonatomic, copy) NSString *type;

@end
