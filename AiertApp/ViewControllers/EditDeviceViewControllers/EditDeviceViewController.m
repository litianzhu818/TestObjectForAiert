//
//  editDeviceViewController.m
//  AiertApp
//
//  Created by Peter Lee on 14/10/12.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "EditDeviceViewController.h"

@interface EditDeviceViewController ()
{
    UITextField *activeField;
}

@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *backView;
@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UITextField *idTextField;
@property (strong, nonatomic) IBOutlet UITextField *userNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *userPwdTextField;
@property (strong, nonatomic) IBOutlet UIButton *deleteButton;

- (IBAction)saveAction:(id)sender;
- (IBAction)deleteAction:(id)sender;

@end

@implementation EditDeviceViewController

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
    // Do any additional setup after loading the view.
    [self initializationParameters];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [self addNotifications];
    [[myAppDelegate aiertDeviceCoreDataManager] addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self removeNotifications];
    [[myAppDelegate aiertDeviceCoreDataManager] removeDelegate:self delegateQueue:dispatch_get_main_queue()];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initializationParameters
{
    //Here initialization your parameters
    [self initializationUI];
    [self initializationData];
}

-(void)initializationUI
{
    //Here initialization your UI parameters
    [self.navigationItem setTitle:@"修改设备信息"];
    UIImage *image = PNG_NAME(@"btn_big");
    image = [image stretchableImageWithLeftCapWidth:floorf(image.size.width*0.5) topCapHeight:floorf(image.size.height*0.5)];
    [self.navigationController.navigationBar setBackgroundImage:PNG_NAME(@"6") forBarMetrics:UIBarMetricsDefault];
    
    _scrollView.contentSize = CGSizeMake(VIEW_W(self.view), VIEW_H(self.view)+50);
    
    _backView.layer.cornerRadius = 6.0f;
    _backView.layer.borderWidth = 0.2f;
    _backView.layer.borderColor = [_backView backgroundColor].CGColor;
    
    [_deleteButton setBackgroundColor:[UIColor redColor]];
    [_deleteButton setTintColor:[UIColor whiteColor]];
    _deleteButton.layer.cornerRadius = 6.0f;
    _deleteButton.layer.borderWidth = 0.2f;
    _deleteButton.layer.borderColor = [_deleteButton backgroundColor].CGColor;
    
}

-(void)initializationData
{
    //Here initialization your data parameters
    [_idTextField setText:self.device.deviceID];
    [_idTextField setEnabled:NO];
    
    [_nameTextField setText:self.device.deviceName];
    [_userNameTextField setText:self.device.userInfo.userName];
    [_userPwdTextField setText:self.device.userInfo.userPassword];
}

-(void)addNotifications
{
    [NotificationCenter addObserver:self
                           selector:@selector(keyboardWillShow:)
                               name:UIKeyboardWillShowNotification
                             object:nil];
    
    [NotificationCenter addObserver:self
                           selector:@selector(keyboardWillHide:)
                               name:UIKeyboardWillHideNotification
                             object:nil];
}

-(void)removeNotifications
{
    [NotificationCenter removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [NotificationCenter removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (IBAction)saveAction:(id)sender
{
    if ([self checkData]) {
        
        [self.device setDeviceName:self.nameTextField.text];
        [self.device.userInfo setUserName:self.userNameTextField.text];
        [self.device.userInfo setUserPassword:self.userPwdTextField.text];
        
        LOG(@"%@",self.device.deviceAdditionInfo.description);
        
//        AiertDeviceInfo *deviceInfo = [[AiertDeviceInfo alloc] initWithDeviceName:self.nameTextField.text
//                                                                         deviceID:self.device.deviceID
//                                                                         userName:self.userNameTextField.text
//                                                                     userPassword:self.userPwdTextField.text];
        [[myAppDelegate aiertDeviceCoreDataManager] editDeviceWithDeviceInfo:self.device];
        
    }else{
        [self showMessage:@"输入信息不能为空，请检查您的输入！" title:@"提示" cancelButtonTitle:@"提示" cancleBlock:^{
        }];
    }
}

- (IBAction)deleteAction:(id)sender
{
    [self showMessage:[NSString stringWithFormat:@"%@%@%@",@"您确定删设备ID为:",self.device.deviceID,@"的设备吗？"] title:@"提示" cancelButtonTitle:@"确定" cancleBlock:^{
        
        [[myAppDelegate aiertDeviceCoreDataManager] deleteDeviceWithDeviceID:self.device.deviceID];
        
    } otherButtonTitle:@"取消" otherBlock:^{
        
    }];
}

- (BOOL)checkData
{
    if (!self.nameTextField.text || [self.nameTextField.text isEqualToString:@""]) {
        return NO;
    }
    
    if (!self.userNameTextField.text || [self.userNameTextField.text isEqualToString:@""]) {
        return NO;
    }
    
    if (!self.userPwdTextField.text || [self.userPwdTextField.text isEqualToString:@""]) {
        return NO;
    }
    
    return YES;
}

// Called when the UIKeyboardWillShowNotification is sent.
- (void)keyboardWillShow:(NSNotification *)notification
{
    // Get the duration of the animation.
    NSValue *animationDurationValue = [[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
    
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    NSLog(@"这里是：%@", NSStringFromCGSize(keyboardSize));
    //调整scrollView的内含视图的size
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0);
    _scrollView.contentInset = contentInsets;
    _scrollView.scrollIndicatorInsets = contentInsets;
    
    [UIView commitAnimations];
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect activeRect = self.view.frame;
    activeRect.size.height -= keyboardSize.height;
    
    if (!CGRectContainsPoint(activeRect, activeField.frame.origin)) {
        //        CGPoint scrollPoint = CGPointMake(0.0, activeField.frame.origin.y-keyboardSize.height);
        //        [scrollView setContentOffset:scrollPoint animated:YES];
        [_scrollView scrollRectToVisible:activeField.frame animated:YES];
    }
}


// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillHide:(NSNotification *)notification
{
    NSDictionary* userInfo = [notification userInfo];
    
    /*
     Restore the size of the text view (fill self's view).
     Animate the resize so that it's in sync with the disappearance of the keyboard.
     */
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    //让scrollView恢复愿来的状态
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    _scrollView.contentInset = contentInsets;
    _scrollView.scrollIndicatorInsets = contentInsets;
    
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    activeField = textField;
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    activeField = nil;
    [textField resignFirstResponder];
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark -
#pragma mark - AiertDeviceCoreDataManagerDelegate Methods
- (void)aiertDeviceCoreDataManager:(AiertDeviceCoreDataManager *)aiertDeviceCoreDataManager didDeleteDeviceWithDeviceID:(NSString *)deviceID
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)aiertDeviceCoreDataManager:(AiertDeviceCoreDataManager *)aiertDeviceCoreDataManager didEditDeviceWithDictionary:(NSDictionary *)dic
{
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
