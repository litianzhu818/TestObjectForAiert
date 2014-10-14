

#import <UIKit/UIKit.h>

@protocol DragButtonDelegate <NSObject>

@optional
- (void)didLongPressDrag:(id)aData;

- (void)delButtonAtIndexInDragButton:(NSInteger)aIndex;

- (void)doubleClickAtIndexInDragButton:(NSInteger)aIndex;

- (void)singleClickAtIndexInDragButton:(NSInteger)aIndex;

@end

@interface DragButton : UIButton<DragButtonDelegate> {
    BOOL _bChoiced;
    BOOL _bLongPressed;
}
- (id)initWithFrameWithType:(CGRect)frame Type:(NSInteger)aType;

- (void)setDragButtonBackgroundImage:(UIImage *)image forState:(UIControlState)state;

- (void)addDragButtonTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

- (void)showDelButton:(BOOL)bShow;

- (void)didSelectImageView:(BOOL)bSelect;

- (void)didChoiceAllButton:(BOOL)bChoice;


@property(nonatomic,assign) id<DragButtonDelegate> dragButtonDelegate;
@property(nonatomic,retain) UIImageView *selectedImageView;

@end
