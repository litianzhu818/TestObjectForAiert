

#import <UIKit/UIKit.h>

#import "ZBarSDK.h"
#import "UIAimMaskView.h"

typedef void(^FinishBlock)(AiertDeviceInfo *deviceInfo);

@interface ScanQrCodeViewController : BaseViewController<ZBarReaderViewDelegate>

@property (weak, nonatomic) IBOutlet ZBarReaderView *readerView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIAimMaskView *maskView;
@property (weak, nonatomic) IBOutlet UIButton *helpButton;

@property (weak, nonatomic) IBOutlet UIImageView *errorImageView;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;

@property (strong, nonatomic) FinishBlock finishBlock;
@property (strong, nonatomic) AiertDeviceInfo* deviceInfo;

- (IBAction)backButton_TouchUpInside:(id)sender;
- (IBAction)helpButton_TouchUpInside:(id)sender;

@end
