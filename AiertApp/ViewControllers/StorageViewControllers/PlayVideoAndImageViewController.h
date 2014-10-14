

#import <UIKit/UIKit.h>
#import "StoragePlayBottomView.h"

@protocol PlayVideoAndImageViewControllerDelegate <NSObject>

@optional
- (void)deleteDataAtIndexInPlayVideoAndImageViewController:(NSInteger)aIndex;

@end

@interface PlayVideoAndImageViewController : UIViewController <StoragePlayBottomViewDelegate,PlayVideoAndImageViewControllerDelegate> {
    
    NSInteger _curIndex;
}

@property (strong, nonatomic) StoragePlayBottomView *playBottomView;
@property (weak, nonatomic) id<PlayVideoAndImageViewControllerDelegate> playVideoAndImageViewControllerDelegate;

- (IBAction)backButton_TouchUpInside:(id)sender;
- (void)initWithDataArr:(id)aData;

@end
