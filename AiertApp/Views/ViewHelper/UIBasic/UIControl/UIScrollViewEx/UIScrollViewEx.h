

#import <UIKit/UIKit.h>

@protocol UIScrollViewExDelegate <NSObject>

@optional
- (void)didTouchesEndedAtUIScrollViewEx:(BOOL)touched;

@end

@interface UIScrollViewEx : UIScrollView <UIScrollViewExDelegate> {
    
}

@property (weak, nonatomic) id<UIScrollViewExDelegate> uiScrollViewExDelegate;

@end
