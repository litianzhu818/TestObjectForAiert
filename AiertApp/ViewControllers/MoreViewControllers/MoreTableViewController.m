

#import "MoreTableViewController.h"

#import "BasicDefine.h"
#import "UIColor+AppTheme.h"
//#import "UINavigationItem+Margin.h"

#import "UITableView+AppTheme.h"

@interface MoreTableViewController ()

@end

@implementation MoreTableViewController

@synthesize topTitleLabel;
@synthesize hardRadioView;
@synthesize hardButton;
@synthesize openglRadioView;
@synthesize openglButton;

@synthesize helpLabel;
@synthesize allRightLabel;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = YES;
    [self.tableView hideExtraCellLine];
    
    [self localizedSupport];
    
    /*
    //
    //修正IOS7下导航栏按钮边距大的问题
    if (IOS7_OR_LATER) {
        //看起来没执行，实际有意义，由于"UINavigationItem+Margin.h"
        self.navigationItem.leftBarButtonItem = self.navigationItem.leftBarButtonItem;
        self.navigationItem.rightBarButtonItem = self.navigationItem.rightBarButtonItem;
    }
    */
    
    //RealZYC - 修正ios7下tableview的分割线不顶头的bug
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    self.view.backgroundColor = [UIColor AppThemeTableViewBackgroundColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.decoderType = self.decoderType;
}

#pragma mark - Localized Support

- (void)localizedSupport
{
    self.title = NSLocalizedString(@"图片", @"More");
    //
    self.topTitleLabel.text = NSLocalizedString(@"Set Decoder", @"Set Decoder");
    [self.hardButton setTitle:NSLocalizedString(@"Hard decoding", @"Hard decoding") forState:UIControlStateNormal];
    [self.openglButton setTitle:NSLocalizedString(@"Opengles rendering decoding", @"Opengles rendering decoding") forState:UIControlStateNormal];
    //
    self.helpLabel.text = NSLocalizedString(@"Help", @"Help");
    self.allRightLabel.text = NSLocalizedString(@"All Right Reserved", @"All Right Reserved");
}

#pragma mark - Autorotate

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

#pragma mark - Table view delegate

//Need for iPad
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //解决在ipad上背景不透明的问题
    //http://www.myexception.cn/operating-system/1446505.html
    [cell setBackgroundColor:[UIColor clearColor]];
}

#pragma mark - Switch Radio

- (IBAction)hard_TouchUpInside:(id)sender
{
    self.decoderType = DecoderTypeHard;
}

- (IBAction)opengl_TouchUpInside:(id)sender
{
    self.decoderType = DecoderTypeOpenGLES;
}

#pragma mark - Switch Radio UI Core

- (DecoderType)decoderType
{
    return _decoderType;
}

- (void)setDecoderType:(DecoderType)decoderType
{
    _decoderType = decoderType;
    //
    switch (_decoderType) {
        case DecoderTypeHard:
            hardRadioView.radioSelected = YES;
            openglRadioView.radioSelected = NO;
            break;
            
        default:
            hardRadioView.radioSelected = NO;
            openglRadioView.radioSelected = YES;
            break;
    }
}

#pragma mark - Navigation

/*
// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
