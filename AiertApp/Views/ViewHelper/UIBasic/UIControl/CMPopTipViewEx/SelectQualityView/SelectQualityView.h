

#import <UIKit/UIKit.h>
#import "BasicDefine.h"

@class SelectQualityView;

@protocol SelectQualityViewDelegate < NSObject >

- (void) selectQualityView: (SelectQualityView*) selectQualityView
           changeQualityTo: (VideoQualityType) qualityType;

@end

@interface SelectQualityView : UIView
{
    VideoQualityType _qualityType;
}

@property (nonatomic) VideoQualityType qualityType;

@property (nonatomic, strong) IBOutlet UIButton *ldButton;
@property (nonatomic, strong) IBOutlet UIButton *sdButton;
@property (nonatomic, strong) IBOutlet UIButton *hdButton;

@property (nonatomic, assign) id<SelectQualityViewDelegate> delegate;

+ (SelectQualityView *) viewFromXib;

- (IBAction)ldButton_TouchDown:(id)sender;
- (IBAction)sdButton_TouchDown:(id)sender;
- (IBAction)hdButton_TouchDown:(id)sender;

@end
