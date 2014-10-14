
#import <UIKit/UIKit.h>

#import "UIRadioView.h"
#import "BasicDefine.h"

@interface MoreTableViewController : UITableViewController
{
    DecoderType _decoderType;
}

@property (nonatomic) DecoderType decoderType;

@property (weak, nonatomic) IBOutlet UILabel *topTitleLabel;
@property (weak, nonatomic) IBOutlet UIRadioView *hardRadioView;
@property (weak, nonatomic) IBOutlet UIButton *hardButton;
@property (weak, nonatomic) IBOutlet UIRadioView *openglRadioView;
@property (weak, nonatomic) IBOutlet UIButton *openglButton;

@property (weak, nonatomic) IBOutlet UILabel *helpLabel;
@property (weak, nonatomic) IBOutlet UILabel *allRightLabel;

- (IBAction)hard_TouchUpInside:(id)sender;
- (IBAction)opengl_TouchUpInside:(id)sender;

@end
