//
//  DisplayImageView.h
//  CameraStation
//
//  CCreated by Peter Lee on 14/9/13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import "GLView.h"



@protocol DisplayImageViewProtocol;

@interface DisplayImageView : UIView
@property (weak, nonatomic)id<DisplayImageViewProtocol>delegate;
- (void)processFrameBuffer:(id)frame;
@end

@protocol DisplayImageViewProtocol <NSObject>
- (void)displayImageViewTaped:(id)sender;
@end