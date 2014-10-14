

#import <UIKit/UIKit.h>

@protocol UIButtonWithTouchDownDelegate <NSObject>

@optional
- (void)didLongPressBeganInUIButtonWithTouchDown:(id)aData Tag:(NSInteger)aTag;

- (void)didLongPressEndInUIButtonWithTouchDown:(id)aData Tag:(NSInteger)aTag;

@end

@interface UIButtonWithTouchDown : UIButton <UIButtonWithTouchDownDelegate>
/*
@property(copy, nonatomic)void(^touchDown)(id);
@property(copy, nonatomic)void(^touchUp)(id);*/
@property(weak, nonatomic)id<UIButtonWithTouchDownDelegate> buttonWithTouchDownDelegate;

/*- (id)initWithTouchDownBlock:(void(^)(id))touchDownBlock
                touchUpBlock:(void(^)(id))touchUpBlock;*/
@end
