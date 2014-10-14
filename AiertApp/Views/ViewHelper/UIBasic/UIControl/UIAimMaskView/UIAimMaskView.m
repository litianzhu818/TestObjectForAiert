

#import "UIAimMaskView.h"

#define kUIAimMaskViewColorStatic [UIColor colorWithRed:74/255.0f green:190/255.0f blue:231/255.0f alpha:1.0f]
#define kUIAimMaskViewColorMoving [UIColor colorWithRed:74/255.0f green:190/255.0f blue:231/255.0f alpha:1.0f]

#define kUIAimMaskViewBorderStatic 10
#define kUIAimMaskViewLineLengthStatic 20
#define kUIAimMaskViewLineWidthStatic 4
#define kUIAimMaskViewLineWidthMoving 2

#define kUIAimMaskViewTotalMovingCount 50

#define kUIAimMaskViewMovingTimeInterval 0.05f

@implementation UIAimMaskView

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
    //
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = YES;
    currentMovingLocation = -5;
    timerMoving = nil;
    
    [self redrawLayer];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self redrawLayer];
}

- (void)redrawLayer
{
    if (maskStaticLayer) {
        [maskStaticLayer removeFromSuperlayer];
        maskStaticLayer = nil;
    }
    maskStaticLayer = [self buildMaskStaticLayer];
    [self.layer insertSublayer:maskStaticLayer atIndex:1];
    
    
    if (maskMovingLayer) {
        [maskMovingLayer removeFromSuperlayer];
        maskMovingLayer = nil;
    }
    maskMovingLayer = [self buildMaskMovingLayer];
    [self.layer insertSublayer:maskMovingLayer atIndex:2];
    
    [self moveHandleToValue:currentMovingLocation animated:NO];
}

- (CALayer *)buildMaskStaticLayer
{
    CALayer *layer = [CALayer layer];
    layer.contentsScale = [UIScreen mainScreen].scale;
    layer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    layer.backgroundColor = [UIColor clearColor].CGColor;
    //
    int x1, x2, y1, y2;
    //
    for (y1 = kUIAimMaskViewBorderStatic;
         y1 <= self.frame.size.height - kUIAimMaskViewBorderStatic;
         y1 += self.frame.size.height - 2 * kUIAimMaskViewBorderStatic) {
        y2 = y1;
        //
        x1 = kUIAimMaskViewBorderStatic - kUIAimMaskViewLineWidthStatic/2;
        x2 = kUIAimMaskViewBorderStatic + kUIAimMaskViewLineLengthStatic;
        [layer addSublayer:[UIAimMaskView buildMarkStaticSubLayer:x1
                                                               x2:x2
                                                               y1:y1-kUIAimMaskViewLineWidthStatic/2
                                                               y2:y2-kUIAimMaskViewLineWidthStatic/2]];
        x1 = self.frame.size.width - (kUIAimMaskViewBorderStatic + kUIAimMaskViewLineLengthStatic);
        x2 = self.frame.size.width - kUIAimMaskViewBorderStatic + kUIAimMaskViewLineWidthStatic/2;;
        [layer addSublayer:[UIAimMaskView buildMarkStaticSubLayer:x1
                                                               x2:x2
                                                               y1:y1-kUIAimMaskViewLineWidthStatic/2
                                                               y2:y2-kUIAimMaskViewLineWidthStatic/2]];
    }
    //
    for (x1 = kUIAimMaskViewBorderStatic;
        x1 <= self.frame.size.width - kUIAimMaskViewBorderStatic;
        x1 += self.frame.size.width - 2 * kUIAimMaskViewBorderStatic) {
        x2 = x1;
        //
        y1 = kUIAimMaskViewBorderStatic;
        y2 = kUIAimMaskViewBorderStatic + kUIAimMaskViewLineLengthStatic;
        [layer addSublayer:[UIAimMaskView buildMarkStaticSubLayer:x1-kUIAimMaskViewLineWidthStatic/2
                                                               x2:x2-kUIAimMaskViewLineWidthStatic/2
                                                               y1:y1
                                                               y2:y2]];
        y1 = self.frame.size.height - (kUIAimMaskViewBorderStatic + kUIAimMaskViewLineLengthStatic);
        y2 = self.frame.size.height - kUIAimMaskViewBorderStatic;
        [layer addSublayer:[UIAimMaskView buildMarkStaticSubLayer:x1-kUIAimMaskViewLineWidthStatic/2
                                                               x2:x2-kUIAimMaskViewLineWidthStatic/2
                                                               y1:y1
                                                               y2:y2]];
    }
    
    //
    return layer;
}

+ (CALayer *)buildMarkStaticSubLayer:(int)x1 x2:(int)x2 y1:(int)y1 y2:(int)y2
{
    CALayer *layer = [CALayer layer];
    layer.contentsScale = [UIScreen mainScreen].scale;
    layer.frame = CGRectMake(MIN(x1, x2),
                             MIN(y1, y2),
                             MAX(abs(x2-x1),kUIAimMaskViewLineWidthStatic),
                             MAX(abs(y2-y1),kUIAimMaskViewLineWidthStatic));
    layer.backgroundColor = kUIAimMaskViewColorStatic.CGColor;
    return layer;
}

- (CALayer *)buildMaskMovingLayer
{
    CALayer *layer = [CALayer layer];
    layer.contentsScale = [UIScreen mainScreen].scale;
    layer.frame = CGRectMake(0, -kUIAimMaskViewLineWidthMoving / 2,
                             self.frame.size.width, kUIAimMaskViewLineWidthMoving);
    layer.backgroundColor = kUIAimMaskViewColorMoving.CGColor;
    //
    
    //
    return layer;
}

- (void)moveHandleToValue:(int)movingLocation animated:(BOOL)animated {
	
	CGFloat y = self.frame.size.height * movingLocation / kUIAimMaskViewTotalMovingCount;
	
	if(animated == NO) {
		[CATransaction begin];
		[CATransaction setValue:(id)kCFBooleanTrue
						 forKey:kCATransactionDisableActions];
	}
    
	//handleGradient.position = CGPointMake(x, (sliderGradient.bounds.size.height + sliderGradient.cornerRadius) / 2.0);
	maskMovingLayer.position = CGPointMake(maskMovingLayer.bounds.size.width / 2.0,
                                           y);
    
	if(animated == NO) {
		[CATransaction commit];
	}
}

- (void)stopMoving
{
    if (timerMoving) {
        [timerMoving invalidate];
        timerMoving = nil;
    }
}

- (void)startMoving
{
    [self stopMoving];
    timerMoving = [NSTimer scheduledTimerWithTimeInterval:kUIAimMaskViewMovingTimeInterval
                                                   target:self
                                                 selector:@selector(handleMovingTimer:)
                                                 userInfo:nil
                                                  repeats:YES];
}

- (void)handleMovingTimer:(NSTimer *)timer
{
    currentMovingLocation++;
    
    maskMovingLayer.hidden = (currentMovingLocation < 0);
    if (currentMovingLocation > kUIAimMaskViewTotalMovingCount) {
        currentMovingLocation = -5;
        maskMovingLayer.hidden = YES;
        [self moveHandleToValue:currentMovingLocation animated:NO];
    }
    else {
        [self moveHandleToValue:currentMovingLocation animated:YES];
    }

}

@end
