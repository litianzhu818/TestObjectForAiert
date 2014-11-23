//
//  SuperViewController.m
//  FindLocationDemo
//
//  Created by 李天柱 on 14-4-15.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//
#import "BaseViewController.h"

@interface BaseViewController ()

@end


@implementation BaseViewController


//init方法最终还是要执行initWithNibName:bundle:方法，所以公共代码只需在该方法里添加即可
//Stortyboard中初始化不执行init和initWithNibName:bundle:方法，所以初始化全放viewDidLoad中
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addSelfToNotificationCenter];
    
    _netWorkStatusNotice = [NotificationView sharedInstance];
    _netWorkStatusNotice.delegate = self;
    
    
    _defaultImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.view insertSubview:_defaultImageView atIndex:0];
    [_defaultImageView setUserInteractionEnabled:YES];
    [_defaultImageView setImage:PNG_NAME(@"bg_big")];
    
    //自动布局约束
    [_defaultImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSMutableArray *tmpConstraints = [NSMutableArray array];
    [tmpConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_defaultImageView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_defaultImageView)]];
    [tmpConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_defaultImageView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_defaultImageView)]];
    [self.view addConstraints:tmpConstraints];
    
#if !__has_feature(objc_arc)
    
#endif

}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//IOS 5的方法
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
//IOS 6的方法
- (BOOL)shouldAutorotate
{
    return NO;
}
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

-(void)initStatusBar
{
    UIImageView * statusBarView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
    [statusBarView setImage:PNG_NAME(@"topBar")];
    [self.view addSubview:statusBarView];
}

/**
 *  添加消息监听
 */
-(void)addSelfToNotificationCenter
{
    //注册自己为消息通知的接收者
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getMessageWithNotification:) name:NEW_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getMessageWithNotification:) name:FIREND_ONLINE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getMessageWithNotification:) name:FIREND_OFFLINE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getMessageWithNotification:) name:RECEIVE_ADD_FIREND_REQUEST object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disconnectWithNet) name:DISCONNECT_NET object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectWithNetAgain) name:CONNECT_NET object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getRequestMessageNotification:) name:REQUEST_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getControlMessageNotification:) name:CONTROL_MESSAGE object:nil];
}


/**
 *  取消消息监听
 */
-(void)removeSelfFromNotificationCenter
{
    //将自己从消息中心注销
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NEW_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SEND_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FIREND_ONLINE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FIREND_OFFLINE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RECEIVE_ADD_FIREND_REQUEST object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DISCONNECT_NET object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CONNECT_NET object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NEW_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:REQUEST_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CONTROL_MESSAGE object:nil];
}

/*********************************Private方法********************************************/

/**
 *  断网
 */
-(void)disconnectWithNet
{
    //提示断网
    [self performSelector:@selector(showNetworkSratusNotification) withObject:nil afterDelay:0.1];
}
/**
 *  再次连接网络
 */
-(void)connectWithNetAgain
{
    //如果提示还没消失
 //   [MPNotificationView dissmissNotificationView];
    //重新连接代码
    [_netWorkStatusNotice dissmissNotificationView];
    [StatusBar dismiss];
}

-(void)showNetworkSratusNotification
{
    [_netWorkStatusNotice showViewWithText:@"notice" detail:@"There is no internet connection" image:PNG_NAME(@"no_internet.png")];
}

//- (void)cancel {
//    [BaseViewController cancelPreviousPerformRequestsWithTarget:self selector:@selector(showNetworkSratusNotification) object:nil];
//    [BaseViewController cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideBanner) object:nil];
//}
//


#pragma mark -
#pragma mark MPNotificationViewDelegate Methods
- (void)deleteNotificationView
{
    if ([[CheckNetStatus sharedInstance] getNowNetWorkStatus] == NotReachable) {
        [StatusBar showWithStatus:@"no internet…"];
    }
}

/*******************************Public方法***********************************************/

/**
 *  接收消息，用于向子类传递信息
 *
 *  @param notification 消息通知
 */
-(void)getMessageWithNotification:(NSNotification *)messageNotification
{
    //该方法需要子类重写，具体处理消息内容
}

-(void)getRequestMessageNotification:(NSNotification *)messageNotification
{
    //该方法需要子类重写，具体处理消息内容
}

-(void)getControlMessageNotification:(NSNotification *)messageNotification
{
    //该方法需要子类重写，具体处理消息内容
}
-(void)SendMessage:(NSNotification *)notification
{
    //该方法需要子类重写，具体处理消息内容
}
- (void)dealloc {
    [self removeSelfFromNotificationCenter];
#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}

/**
 *  弹出提示对话框
 *
 *  @param message 对话框显示的类容
 */
-(void)showMessage:(NSString *)message
             title:(NSString *)title
 cancelButtonTitle:(NSString *)cancelTitle
       cancleBlock:(void (^)(void))cancleBlock
  otherButtonTitle:(NSString *)otherButtonTitle
        otherBlock:(void (^)(void))otherBlock
{
    UICustomAlertView *alertView = [[UICustomAlertView alloc] initWithTitle:title
                                                                    message:message
                                                          cancelButtonTitle:cancelTitle
                                                                cancleBlock:cancleBlock
                                                           otherButtonTitle:otherButtonTitle
                                                                 otherBlock:otherBlock];
    [alertView show];
}

-(void)showMessage:(NSString *)message
             title:(NSString *)title
 cancelButtonTitle:(NSString *)cancelTitle
       cancleBlock:(void (^)(void))cancleBlock
{
    UICustomAlertView *alertView = [[UICustomAlertView alloc] initWithTitle:title
                                                                    message:message
                                                          cancelButtonTitle:cancelTitle
                                                                cancleBlock:cancleBlock];
    [alertView show];
}


@end
