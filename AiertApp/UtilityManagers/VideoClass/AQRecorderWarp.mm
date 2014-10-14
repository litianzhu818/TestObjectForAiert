//
//  AQRecoderWarp.m
//  爱尔特 Aiert
//
//  Created by Peter Lee on 14/9/13.
//  Copyright (c) 2014年 爱尔特. All rights reserved.
//

#import "AQRecorderWarp.h"
#include "AQRecorder.h"
#import "LibCoreWrap.h"

@interface AQRecorderWarp ()
{
    AQRecorder *_recorder;
}
@end

@implementation AQRecorderWarp

static void hasDataCallBack(void *tocken, BytePtr pBuffer, int nBufferLen)
{
    DLog(@"hasDataCallBack _______________________________ %d",nBufferLen);
    AQRecorderWarp *THIS = (__bridge AQRecorderWarp*)tocken;
    
    [THIS sendMicData:pBuffer length:nBufferLen];
}

+ (AQRecorderWarp *)sharedRecorder
{
    static  AQRecorderWarp *sharedInstance = nil ;
    static  dispatch_once_t onceToken;
    dispatch_once (& onceToken, ^ {
        sharedInstance = [[self alloc]init];
        
    });
    return sharedInstance;
}

- (void)dealloc
{
    delete _recorder;
    
}

- (id)init
{
    if (self = [super init]) {
        
        _recorder = new AQRecorder();
        _recorder->delegate = (__bridge void *)self;
        _recorder->pHasDataCallBack = hasDataCallBack;

    }
    
    return self;
}

+ (void)startRecord
{
    [AQRecorderWarp sharedRecorder]->_recorder->StartRecord();
}

+ (void)stopRecord
{
    [AQRecorderWarp sharedRecorder]->_recorder->StopRecord();
}

- (void)sendMicData:(BytePtr)pBuffer length:(int)nBufferLen
{
   [[LibCoreWrap sharedCore] talkSendDataWithDeviceId:nil
                                              channel:0
                                                data:pBuffer
                                               length:nBufferLen];
}
@end
