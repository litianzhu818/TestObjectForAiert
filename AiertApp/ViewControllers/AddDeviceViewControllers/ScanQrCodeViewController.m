

#import "ScanQrCodeViewController.h"

#import "QuartzCore/QuartzCore.h"

#import "BasicDefine.h"
#import "UIColor+AppTheme.h"
#import "InputDeviceInfoTableViewController.h"

@interface NSString (Contains)

- (BOOL)existedSubString:(NSString*)subString;

@end

@implementation NSString (Contains)

- (BOOL)existedSubString:(NSString*)subString
{
    NSRange range = [self rangeOfString:subString];
    return range.length != 0;
}

@end

@interface ScanQrCodeViewController ()
{
    NSString *qrCode;
    
    BOOL _viewHasDisappear;
}
@property (nonatomic) BOOL bLightOpen;
@end

@implementation ScanQrCodeViewController

@synthesize readerView;
@synthesize titleLabel;
@synthesize backgroundView;
@synthesize helpButton;
@synthesize maskView;

@synthesize errorImageView;
@synthesize errorLabel;

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
    
    [self localizedSupport];
    
    self.view.backgroundColor = [UIColor AppThemeTableViewBackgroundColor];
    
    self.backgroundView.layer.cornerRadius = 5;

    readerView.readerDelegate = self;
    readerView.scanCrop = self.readerView.bounds;
    readerView.trackingColor = [UIColor colorWithRed:75.0f/255.0f
                                               green:189.0f/255.0f
                                                blue:231.0f/255.0f
                                               alpha:1.0f];
    
    qrCode = @"";
    self.deviceInfo = [[AiertDeviceInfo alloc] init];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    _viewHasDisappear = NO;
    
    [self.readerView start];
    [self.maskView startMoving];
    [super viewDidAppear:animated];
    
    [self hideError];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    _viewHasDisappear = YES;
    
    [super viewWillDisappear:animated];
    [self.readerView stop];
    [self.maskView stopMoving];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Localized Support

- (void)localizedSupport
{
    self.title = NSLocalizedString(@"扫描二维码", @"Scan QR Code");
    self.titleLabel.text = NSLocalizedString(@"请将二维码放置于扫描框中间位置，等待读取",
                                             @"Aim camera aperture at QR code area, auto scanning is available");
}

#pragma mark - Core

- (void)readerView:(ZBarReaderView*)view didReadSymbols:(ZBarSymbolSet*)syms fromImage:(UIImage*)img
{
    qrCode=@"";
    for(ZBarSymbol *sym in syms) {
        qrCode = sym.data;
        DLog(@"%@",sym.data);
        break;
    }
    
    //TODO:这里需要检查二维码并跳转回去
    if ([self parseDataFromQRValue:qrCode destinationDeviceInfo:self.deviceInfo]){
        
        if (self.finishBlock) {
            self.finishBlock(self.deviceInfo);
        }
        //跳转回去
        [self.navigationController popViewControllerAnimated:YES];
        
    }else{
        [self showError:@"不是正确的设备条形码或者二维码"];
    }
}

//解析得到的数据
-(BOOL)parseDataFromQRValue:(NSString *)value destinationDeviceInfo:(AiertDeviceInfo *)deviceInfo
{
    BOOL result = NO;
    //FIXME:这里需要解析判断，并填充deviceInfo的值
    //扫描字符串格式：ID:V7X1WR7K45BRX4LWCNCJUSER:adminPASSW:111111
    if (value && ![value isEqualToString:@""] && [value existedSubString:@"ID:"] && [value existedSubString:@"USER:"] && [value existedSubString:@"PASSW:"]) {
        result = YES;
        
        NSString *userStr = @"USER:";
        NSString *pwdStr = @"PASSW:";
        NSRange range1 = [value rangeOfString:userStr];
        NSRange range2 = [value rangeOfString:pwdStr];
        
        deviceInfo.deviceID = [value substringWithRange:NSMakeRange(3, range1.location - 3)];
        deviceInfo.userInfo = [[AiertUserInfo alloc] initWithUserName:[value substringWithRange:NSMakeRange(range1.location+5, range2.location - range1.location - 5)] userPassword:[value substringWithRange:NSMakeRange(range2.location+6, value.length - (range2.location + 6))]];
    }
    
    return result;
}

#pragma mark - Show and Hide Error
- (void)showError:(NSString *)message
{
    errorLabel.text = message;
    errorLabel.hidden = NO;
    errorImageView.hidden = NO;
    titleLabel.hidden = YES;
}

- (void)hideError
{
    errorLabel.hidden = YES;
    errorImageView.hidden = YES;
    titleLabel.hidden = NO;
}

#pragma mark - Autorotate

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

#pragma mark - Navigation

- (IBAction)backButton_TouchUpInside:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

//- (IBAction)helpButton_TouchUpInside:(id)sender {
//    
//    self.readerView.torchMode = !self.bLightOpen;
//    self.bLightOpen = !self.bLightOpen;
//}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ScanQrCode2InputDevicePassword"]) {
        self.hidesBottomBarWhenPushed = YES;
        
        InputDeviceInfoTableViewController *controller = segue.destinationViewController;
        if (controller) {
            controller.cameraId = qrCode;
        }
    }
}

@end
