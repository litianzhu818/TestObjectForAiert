
#import <UIKit/UIKit.h>
#import "QuartzCore/QuartzCore.h"
#import "BasicDefine.h"
#import "UIButtonWithTouchDown.h"

@protocol PlayBottomViewDelegate <NSObject>

@optional
- (void)clickButtonAtPlayBottomView: (id)sender Index: (NSInteger)aIndex;

- (void)didLongPressBeganInPlayBottomView:(id)aData Tag:(NSInteger)aTag;

- (void)didLongPressEndInPlayBottomView:(id)aData Tag:(NSInteger)aTag;

@end

@interface  PlayBottomView : UIView<PlayBottomViewDelegate,UIButtonWithTouchDownDelegate> {
    UIView  *currentView;
    NSInteger lastIndex;
    NSInteger imageCount;
    
    NSInteger  _type;
}

@property (nonatomic,retain)UIView *currentView;
@property (nonatomic,assign)NSInteger qualityIndex;
@property (nonatomic,assign)id<PlayBottomViewDelegate> delegate;


- (id)initWithType:(CGRect)frame Type:(NSInteger)aType;
- (void)selectAtIndexWithOpenStatus:(NSInteger)aIndex OpenStatus:(BOOL)open;
- (void)selectAtQualityIndexWithSubIndex:(NSInteger)aSubIndex;

@end
