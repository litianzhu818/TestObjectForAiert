

#import "UIGroupCell.h"
#import "UIGroupCellBackgroundView.h"

@interface UIGroupCell()

@property (nonatomic, strong) CALayer *backgroundLayer;

@end

@implementation UIGroupCell

@synthesize backgroundLayer;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self awakeFromNib];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setSelectionStyle:(UITableViewCellSelectionStyle)selectionStyle
{
    [super setSelectionStyle:selectionStyle];
    [self loadSelectionView];
    
}

- (void)loadSelectionView
{
    switch (self.selectionStyle) {
        case UITableViewCellSelectionStyleNone:
            [super setSelectedBackgroundView:nil];
            break;
        case UITableViewCellSelectionStyleBlue:
        case UITableViewCellSelectionStyleDefault:
            [super setSelectedBackgroundView:[[UIGroupCellBackgroundView alloc]
                                              initWithFrame:self.frame
                                              selectionColor:[UIColor colorWithRed:75/255.0f
                                                                             green:189/255.0f
                                                                              blue:231/255.0f alpha:1]
                                              tag:self.tag]];
            break;
        case UITableViewCellSelectionStyleGray:
            [super setSelectedBackgroundView:[[UIGroupCellBackgroundView alloc]
                                              initWithFrame:self.frame
                                              selectionColor:[UIColor lightGrayColor]
                                              tag:self.tag]];
            break;
        default:
            break;
    }
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor clearColor];
    backgroundLayer = nil;
    self.clipsToBounds = YES;
    
    [self loadSelectionView];
    
    [self redrawLayer];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self redrawLayer];
}

- (void)redrawLayer
{
    if (backgroundLayer) {
        [backgroundLayer removeFromSuperlayer];
        backgroundLayer = nil;
    }
    backgroundLayer = [self buildBackgroundLayer];
    [self.layer insertSublayer:backgroundLayer atIndex:0];
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
            l1.backgroundColor = kUIGroupCellColorBackground.CGColor;
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
            l1.backgroundColor = kUIGroupCellColorBackground.CGColor;
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
            l1.backgroundColor = kUIGroupCellColorBackground.CGColor;
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
            l1.backgroundColor = kUIGroupCellColorBackground.CGColor;
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
