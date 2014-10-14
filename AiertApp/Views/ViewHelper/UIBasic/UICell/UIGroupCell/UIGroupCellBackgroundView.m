

#import "UIGroupCellBackgroundView.h"

@implementation UIGroupCellBackgroundView

@synthesize selectionColor;

- (id)initWithFrame:(CGRect)frame selectionColor:(UIColor *)aSelectionColor tag:(NSInteger)aTag
{
    self = [self initWithFrame:frame];
    if (self) {
        self.selectionColor = aSelectionColor;
        self.tag = aTag;
    }
    return self;
}

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
    self.backgroundColor = [UIColor clearColor];
    selectionColor = [UIColor clearColor];
}

- (void)layoutSubviews{
    //[super layoutSubviews];
    [self redrawLayer];
}

- (void)redrawLayer
{
    if (backgroundLayer) {
        [backgroundLayer removeFromSuperlayer];
    }
    backgroundLayer = [self buildBackgroundLayer];
    [self.layer insertSublayer:backgroundLayer atIndex:1];
}

- (CALayer *)buildBackgroundLayer
{
    CALayer *layer = [CALayer layer];
    layer.contentsScale = [UIScreen mainScreen].scale;
    layer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
    //
    CALayer *l1 = nil;
    CALayer *l2 = nil;
    switch (self.tag) {
        case UIGroupCellTagTypeMiddle:
            l1 = [CALayer layer];
            l1.contentsScale = [UIScreen mainScreen].scale;
            l1.frame = CGRectMake(kUIGroupCellBorderLeftRight, 0,
                                  self.frame.size.width - 2 * kUIGroupCellBorderLeftRight,
                                  self.frame.size.height + 1);
            l1.borderWidth = kUIGroupCellLineWidth;
            l1.backgroundColor = selectionColor.CGColor;
            l1.borderColor = kUIGroupCellColorLine.CGColor;
            
            [layer addSublayer:l1];
            break;
        case UIGroupCellTagTypeTop:
            l1 = [CALayer layer];
            l1.contentsScale = [UIScreen mainScreen].scale;
            l1.frame = CGRectMake(kUIGroupCellBorderLeftRight, 0,
                                  self.frame.size.width - 2 * kUIGroupCellBorderLeftRight,
                                  self.frame.size.height + 1 + kUIGroupCellLineCorner);
            l1.borderWidth = kUIGroupCellLineWidth;
            l1.backgroundColor = selectionColor.CGColor;
            l1.borderColor = kUIGroupCellColorLine.CGColor;
            l1.cornerRadius = kUIGroupCellLineCorner;
            
            [layer addSublayer:l1];
            break;
        case UIGroupCellTagTypeBottom:
            l1 = [CALayer layer];
            l1.contentsScale = [UIScreen mainScreen].scale;
            l1.frame = CGRectMake(kUIGroupCellBorderLeftRight, - (1 + kUIGroupCellLineCorner),
                                  self.frame.size.width - 2 * kUIGroupCellBorderLeftRight,
                                  self.frame.size.height + 1 + kUIGroupCellLineCorner);
            l1.borderWidth = kUIGroupCellLineWidth;
            l1.backgroundColor = selectionColor.CGColor;
            l1.borderColor = kUIGroupCellColorLine.CGColor;
            l1.cornerRadius = kUIGroupCellLineCorner;
            
            [layer addSublayer:l1];
            //
            l2 = [CALayer layer];
            l2.contentsScale = [UIScreen mainScreen].scale;
            l2.frame = CGRectMake(kUIGroupCellBorderLeftRight, 0,
                                  self.frame.size.width - 2 * kUIGroupCellBorderLeftRight,
                                  kUIGroupCellLineWidth);
            l2.borderWidth = 0;
            l2.backgroundColor = kUIGroupCellColorLine.CGColor;
            
            [layer addSublayer:l2];
            break;
        case UIGroupCellTagTypeSeparate:
            l1 = [CALayer layer];
            l1.contentsScale = [UIScreen mainScreen].scale;
            l1.frame = CGRectMake(kUIGroupCellBorderLeftRight, 0,
                                  self.frame.size.width - 2 * kUIGroupCellBorderLeftRight,
                                  self.frame.size.height);
            l1.borderWidth = kUIGroupCellLineWidth;
            l1.backgroundColor = selectionColor.CGColor;
            l1.borderColor = kUIGroupCellColorLine.CGColor;
            l1.cornerRadius = kUIGroupCellLineCorner;
            
            [layer addSublayer:l1];
            break;
        default:
            break;
    }
    
    return layer;
}

@end
