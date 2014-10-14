//
//  DefineValues.h
//  ChatApp
//
//  Created by Peter Lee on 14/9/13.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#ifndef AiertApp__DefineValues_h
#define AiertApp__DefineValues_h

/*###########################################################################################################
 #################################################THE BEGIN##################################################
 ###########################################################################################################*/
    #define UserDefaults [NSUserDefaults standardUserDefaults]
    #define NotificationCenter [NSNotificationCenter defaultCenter]
    #define myAppDelegate ((AppDelegate *)[[UIApplication sharedApplication] delegate])


    // block self
    #define WEAKSELF typeof(self) __weak weakSelf = self;
    #define STRONGSELF typeof(weakSelf) __strong strongSelf = weakSelf;

    /*************************************常用方法***************************************/
    #define PNG_NAME(png_name) [UIImage imageNamed:png_name]

    #define VOID_BLOCK  void(^)(void)
    #define GLOBAL_GCD(block) dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block)
    #define MAIN_GCD(block) dispatch_async(dispatch_get_main_queue(),block)

    /*************************************System info***************************************/


    /*************************************User info***************************************/
    //get the left top origin's x,y of a view
    #define VIEW_TX(view) (view.frame.origin.x)
    #define VIEW_TY(view) (view.frame.origin.y)
    //get the width size of the view:width,height
    #define VIEW_W(view)  (view.frame.size.width)
    #define VIEW_H(view)  (view.frame.size.height)
    //get the right bottom origin's x,y of a view
    #define VIEW_BX(view) (view.frame.origin.x + view.frame.size.width)
    #define VIEW_BY(view) (view.frame.origin.y + view.frame.size.height )
    //get the x,y of the frame
    #define FRAME_TX(frame)  (frame.origin.x)
    #define FRAME_TY(frame)  (frame.origin.y)
    //get the size of the frame
    #define FRAME_W(frame)  (frame.size.width)
    #define FRAME_H(frame)  (frame.size.height)

    #define BOUNDS_W(bounds)  (bounds.size.width)
    #define BOUNDS_H(bounds)  (bounds.size.height)

    /*************************************User info***************************************/


    #define SYSTEM_BOUND [ UIScreen mainScreen ].bounds
    #define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    #define IOS_VERSION_7_OR_ABOVE (([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)? (YES):(NO))
    #define READ_PLIST(plistFileName) [[NSMutableDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:plistFileName ofType:@"plist"]]

/*************************************log system***************************************/
    #ifdef DEBUG

            #define LOG_HERE NSLog(@"<%@(line:%d method:%@)>:\n(null)\n<%@ %@>",[[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__,[NSString stringWithUTF8String:__func__],[NSString stringWithUTF8String:__DATE__],[NSString stringWithUTF8String:__TIME__])
            #define LOG(FORMAT,...)  NSLog(@"<%@(line:%d method:%@)>:\n%@\n<%@ %@>",[[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__,[NSString stringWithUTF8String:__func__], [NSString stringWithFormat:(FORMAT), ##__VA_ARGS__],[NSString stringWithUTF8String:__DATE__],[NSString stringWithUTF8String:__TIME__])
    #else
            #define LOG_HERE nil
            #define LOG(FORMAT,...) nil

    #endif
/*************************************启动信息和页面跳转***************************************/

/*************************************other***************************************/

/*###########################################################################################################
 ##################################################THE END*######################################################
 ###########################################################################################################*/
#endif
