

#import "AlarmMessageViewController.h"
#import "PlayViewController.h"
#import "Utilities.h"
#import "UIImageView+WebCache.h"

#import "UIButton+ImageAndLabel.h"
#import "ZSWebInterface.h"
#import "AppData.h"

@interface AlarmMessageViewController ()

@end

@implementation AlarmMessageViewController

@synthesize alarmVideoButton;
@synthesize liveButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Alarm messages", @"");
    [self.alarmVideoButton setImage:[UIImage imageNamed:@"alarmblue-alarmv"]
                          withTitle:NSLocalizedString(@"Alarm Video", @"")
                       withSpacting:10 forState:UIControlStateNormal];
    [self.liveButton setImage:[UIImage imageNamed:@"alarmblue-alarml"]
                          withTitle:NSLocalizedString(@"Live", @"")
                       withSpacting:10 forState:UIControlStateNormal];
    
    NSString *url = [_message.messageContent objectForKey:@"url"];
    url = [url stringByAppendingString:[NSString stringWithFormat:@"&tokenid=%@&size=L",[ZSWebInterface tokenId]]];
    [_alarmImageView setImageWithURL:[NSURL URLWithString:url]];
    _timeLabel.text = _message.createTime;
    _deviceNameLabel.text = _message.devName;
    
    if (IOS7_OR_LATER) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)liveButtonClick:(UIButton *)sender {
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[PlayViewController class]]) {
            [self.navigationController popToViewController:vc animated:YES];
        }
    }
}

- (IBAction)alarmVideoClick:(UIButton *)sender {
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[PlayViewController class]]) {
            [self.navigationController popToViewController:vc animated:YES];
//            [vc performSelector:@selector(PlaybackButton_TouchUpInside:)];
        }
    }
}

- (IBAction)deleteButtonClick:(id)sender {

    [ZSWebInterface deleteMessageWithMessageId:self.message.ID
                                   messageType:@"0"
                                       success:^(NSDictionary *data) {
                                           
                                       }
                                       failure:^(NSDictionary *data) {
                                           
                                       }];
    
    [[AppData alarmMessageList] removeObject:_message];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)backButton_TouchUpInside:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
