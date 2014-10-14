

#import <UIKit/UIKit.h>

@interface UIAimMaskView : UIView
{
    CALayer *maskStaticLayer;
    CALayer *maskMovingLayer;
    int currentMovingLocation;
    
    NSTimer *timerMoving;
}

- (void) startMoving;

- (void) stopMoving;

@end
