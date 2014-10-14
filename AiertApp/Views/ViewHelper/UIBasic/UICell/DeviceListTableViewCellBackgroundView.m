

#import "DeviceListTableViewCellBackgroundView.h"

#define DefaultCellBorder 10

@implementation DeviceListTableViewCellBackgroundView

@synthesize CellBorder;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        CellBorder = DefaultCellBorder;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame border:(int)border
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        CellBorder = border;
    }
    return self;
}

- (void)layoutSubviews{
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
    
    layer.frame = CGRectMake(CellBorder, CellBorder,
                             self.frame.size.width - CellBorder * 2,
                             self.frame.size.height - CellBorder * 2);
    layer.backgroundColor = [UIColor colorWithRed:208/255.0f green:208/255.0f blue:208/255.0f alpha:1.0].CGColor;
    
    return  layer;
}

@end
