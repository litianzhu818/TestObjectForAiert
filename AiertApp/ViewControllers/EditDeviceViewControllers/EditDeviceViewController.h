//
//  editDeviceViewController.h
//  AiertApp
//
//  Created by Peter Lee on 14/10/12.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "BaseViewController.h"

@interface EditDeviceViewController : BaseViewController<UITextFieldDelegate,UIScrollViewDelegate>

@property(strong, nonatomic) AiertDeviceInfo *device;

@end
