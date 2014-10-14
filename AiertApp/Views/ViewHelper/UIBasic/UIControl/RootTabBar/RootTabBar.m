

#import "RootTabBar.h"

#import "BasicDefine.h"


#define kRootTabBarBackground [UIColor colorWithRed:53/255.0f green:53/255.0f blue:53/255.0f alpha:1.0f]
#define kRootTabBarBackgroundLine1 [UIColor colorWithRed:34/255.0f green:34/255.0f blue:34/255.0f alpha:1.0f]
#define kRootTabBarBackgroundLine2 [UIColor colorWithRed:73/255.0f green:73/255.0f blue:73/255.0f alpha:1.0f]
#define kRootTabBarSelectedBack [UIColor colorWithRed:36/255.0f green:36/255.0f blue:36/255.0f alpha:1.0f]
#define kRootTabBarSelectedBorder [UIColor colorWithRed:76/255.0f green:189/255.0f blue:231/255.0f alpha:1.0f]

#define kRootTabBarBackgroundLineTop 1
#define kRootTabBarBackgroundLineWidth 1

@interface RootTabBar ()
{
    /*
    int lastSelectedIndex;
    //Last Selected Tab Bar Layer
    CALayer *selectedLayer;
    //Background Layer
    CALayer *backgroundLayer;
     */
}

@end

@implementation RootTabBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
- (void)awakeFromNib
{
    [super awakeFromNib];
    lastSelectedIndex = 0;
    selectedLayer = nil;
    backgroundLayer = nil;
    
    [self redrawLayer];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self redrawLayer];
}
*/

#pragma mark -
#pragma mark No Hightlight on Select

- (void)setSelectedItem:(UITabBarItem *)selectedItem
{
    [super setSelectedItem:selectedItem];
    if (! IOS7_OR_LATER) {
        [self setNoHighlightTabBar];
    }
}

- (void)setNoHighlightTabBar
{
    int tabCount = [self.items count] > 5 ? 5 : [self.items count];
    NSArray * tabBarSubviews = [self subviews];
    for(int i = [tabBarSubviews count] - 1; i >= [tabBarSubviews count] - tabCount - 1; i--)
    {
        for(UIView * v in [[tabBarSubviews objectAtIndex:i] subviews])
        {
            //NSLog(@"%@",NSStringFromClass([v class]));
            if(v && [NSStringFromClass([v class]) isEqualToString:@"UITabBarSelectionIndicatorView"])
            {//the v is the highlight view.
                [v removeFromSuperview];
                break;
            }
        }
    }
}

/*
#pragma mark -
#pragma mark Item to Index

- (int)indexOfItem:(UITabBarItem *)item
{
    int index = 0;
    for (index = 0; index < self.items.count; index++) {
        if (self.items[index] == item) {
            break;
        }
    }
    return index;
}


#pragma mark -
#pragma mark Layer

- (void)redrawLayer
{
    //
    if (backgroundLayer) {
        [backgroundLayer removeFromSuperlayer];
    }
    backgroundLayer = [self buildLayerBackground];
    [self.layer insertSublayer:backgroundLayer atIndex:1];
    
    //
    if (selectedLayer) {
        [selectedLayer removeFromSuperlayer];
    }
    lastSelectedIndex = [self indexOfItem:[self selectedItem]];
    selectedLayer = [self buildLayerAtIndex:lastSelectedIndex];
    [self.layer insertSublayer:selectedLayer atIndex:2];
}

- (CALayer *)buildLayerBackground
{
    CALayer *layer = [CALayer layer];
    layer.contentsScale = [UIScreen mainScreen].scale;
    layer.borderWidth = 0;
    layer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    layer.backgroundColor = kRootTabBarBackground.CGColor;
    
    //
    float width = self.frame.size.width / MAX(1, self.items.count);
    for (int i = 1; i < self.items.count; i++) {
        float left = i * width;
        //
        CALayer *layerLine1 = [CALayer layer];
        layerLine1.contentsScale = [UIScreen mainScreen].scale;
        layerLine1.backgroundColor = kRootTabBarBackgroundLine1.CGColor;
        layerLine1.borderWidth = 0;
        layerLine1.frame = CGRectMake(left - kRootTabBarBackgroundLineWidth,
                                     kRootTabBarBackgroundLineTop,
                                     kRootTabBarBackgroundLineWidth,
                                     self.frame.size.height - kRootTabBarBackgroundLineTop);
        [layer addSublayer:layerLine1];
        //
        CALayer *layerLine2 = [CALayer layer];
        layerLine2.contentsScale = [UIScreen mainScreen].scale;
        layerLine2.backgroundColor = kRootTabBarBackgroundLine2.CGColor;
        layerLine2.borderWidth = 0;
        layerLine2.frame = CGRectMake(left,
                                      kRootTabBarBackgroundLineTop,
                                      kRootTabBarBackgroundLineWidth,
                                      self.frame.size.height - kRootTabBarBackgroundLineTop);
        [layer addSublayer:layerLine2];
    }
    
    
    return layer;
}

- (CALayer *)buildLayerAtIndex:(int)index
{
    float width = self.frame.size.width / MAX(1, self.items.count);
    float left = index * width;
    
    CALayer *layer = [CALayer layer];
    layer.contentsScale = [UIScreen mainScreen].scale;
    layer.borderWidth = 0;
    layer.frame = CGRectMake(left, 0, width, self.frame.size.height);
    
    //==================
    CALayer *layerBack = [CALayer layer];
    layerBack.contentsScale = [UIScreen mainScreen].scale;
    layerBack.backgroundColor = kRootTabBarSelectedBack.CGColor;
    layerBack.borderWidth = 0;
    layerBack.frame = CGRectMake(0, 0, width, self.frame.size.height);
    [layer addSublayer:layerBack];
    
    //==================
    CALayer *layerTop = [CALayer layer];
    layerTop.contentsScale = [UIScreen mainScreen].scale;
    layerTop.backgroundColor = kRootTabBarSelectedBorder.CGColor;
    layerTop.borderWidth = 0;
    layerTop.frame = CGRectMake(0, 1, width, 5);
    [layer addSublayer:layerTop];
    
    return layer;
}
 */

@end
