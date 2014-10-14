

#import "UIRadioView.h"

#import "UIColor+AppTheme.h"

#define kUIRadioViewL1 20
#define kUIRadioViewL2 10
#define kUIRadioViewC1 [UIColor colorWithRed:103/255.0f green:103/255.0f blue:103/255.0f alpha:1.0]
#define kUIRadioViewC2 [UIColor AppThemeSelectedTextColor]

@implementation UIRadioView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self awakeFromNib];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor clearColor];
    
    _radioSelected = NO;
    radioLayer = nil;
    [self redrawLayer];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self redrawLayer];
}

- (BOOL)radioSelected
{
    return _radioSelected;
}

- (void)setRadioSelected:(BOOL)radioSelected
{
    _radioSelected = radioSelected;
    [self layoutSubviews];
}

- (void)redrawLayer
{
    if (radioLayer) {
        [radioLayer removeFromSuperlayer];
        radioLayer = nil;
    }
    radioLayer = [self buildRadioLayer];
    [self.layer insertSublayer:radioLayer atIndex:3];
}

- (CALayer *)buildRadioLayer
{
    CALayer *layer = [CALayer layer];
    layer.contentsScale = [UIScreen mainScreen].scale;
    layer.frame = CGRectMake((self.frame.size.width - kUIRadioViewL1) / 2, (self.frame.size.height - kUIRadioViewL1) / 2, kUIRadioViewL1, kUIRadioViewL1);
    layer.backgroundColor = [UIColor clearColor].CGColor;
    layer.borderWidth = 2;
    layer.borderColor = kUIRadioViewC1.CGColor;
    layer.cornerRadius = kUIRadioViewL1 / 2;
    
    if (_radioSelected) {
        CALayer *layer2 = [CALayer layer];
        layer2.contentsScale = [UIScreen mainScreen].scale;
        layer2.frame = CGRectMake((kUIRadioViewL1 - kUIRadioViewL2) / 2, (kUIRadioViewL1 - kUIRadioViewL2) / 2, kUIRadioViewL2, kUIRadioViewL2);
        layer2.backgroundColor = kUIRadioViewC2.CGColor;
        layer2.borderWidth = 0;
        layer2.cornerRadius = kUIRadioViewL2 / 2;
        
        [layer addSublayer:layer2];
    }
    
    return layer;
}

@end
