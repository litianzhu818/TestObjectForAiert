//
//  AiertDeviceCoreDataManager.m
//  AiertApp
//
//  Created by Peter Lee on 14/10/12.
//  Copyright (c) 2014年 爱尔特. All rights reserved.
//

#import "AiertDeviceCoreDataManager.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif


@implementation AiertDeviceCoreDataManager
Single_implementation(AiertDeviceCoreDataManager);


/**
 * Standard init method.
 **/
- (id)init
{
    return [self initWithDispatchQueue:NULL storage:nil];
}

/**
 * Designated initializer.
 **/
- (id)initWithDispatchQueue:(dispatch_queue_t)queue storage:(id <AiertDeviceCoreDataManagerStorage>)storage
{
    if ((self = [super init]))
    {
        if (queue)
        {
            moduleQueue = queue;
#if !OS_OBJECT_USE_OBJC
            dispatch_retain(moduleQueue);
#endif
        }
        else
        {
            const char *moduleQueueName = [NSStringFromClass([self class]) UTF8String];
            moduleQueue = dispatch_queue_create(moduleQueueName, NULL);
        }
        
        if ([storage configureWithParent:self queue:moduleQueue])
        {
            aiertDeviceCoreDataManagerStorage = storage;
        }
        else
        {
            LOG(@"Unable to configure storage!");
        }
        
        moduleQueueTag = &moduleQueueTag;
        dispatch_queue_set_specific(moduleQueue, moduleQueueTag, moduleQueueTag, NULL);
        
        multicastDelegate = [[GCDMulticastDelegate alloc] init];
        
        
    }
    return self;
}

- (id)initWithRoomStorage:(id <AiertDeviceCoreDataManagerStorage>)storage
{
    return [self initWithRoomStorage:storage dispatchQueue:NULL];
}

- (id)initWithRoomStorage:(id <AiertDeviceCoreDataManagerStorage>)storage dispatchQueue:(dispatch_queue_t)queue
{
    NSParameterAssert(storage != nil);
    return [self initWithDispatchQueue:queue storage:storage];
}


- (void)dealloc
{
#if !OS_OBJECT_USE_OBJC
    dispatch_release(moduleQueue);
#endif
}

- (dispatch_queue_t)moduleQueue
{
    return moduleQueue;
}

- (void *)moduleQueueTag
{
    return moduleQueueTag;
}

- (void)addDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue
{
    // Asynchronous operation (if outside xmppQueue)
    
    dispatch_block_t block = ^{
        [multicastDelegate addDelegate:delegate delegateQueue:delegateQueue];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

- (void)removeDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue synchronously:(BOOL)synchronously
{
    dispatch_block_t block = ^{
        [multicastDelegate removeDelegate:delegate delegateQueue:delegateQueue];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else if (synchronously)
        dispatch_sync(moduleQueue, block);
    else
        dispatch_async(moduleQueue, block);
    
}
- (void)removeDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue
{
    // Synchronous operation (common-case default)
    
    [self removeDelegate:delegate delegateQueue:delegateQueue synchronously:YES];
}

- (void)removeDelegate:(id)delegate
{
    // Synchronous operation (common-case default)
    
    [self removeDelegate:delegate delegateQueue:NULL synchronously:YES];
}

- (NSString *)moduleName
{
    // Override me (if needed) to provide a customized module name.
    // This name is used as the name of the dispatch_queue which could aid in debugging.
    
    return NSStringFromClass([self class]);
}

#pragma mark -
#pragma mark - Ptrvate Methods

-(void)addDeviceWithDictionary:(NSDictionary *)dic
{
    NSAssert(dispatch_get_specific(moduleQueueTag), @"Invoked on incorrect queue");
    
    if ([aiertDeviceCoreDataManagerStorage addDeviceWithDeviceInfoDictionary:dic]) {
        [multicastDelegate aiertDeviceCoreDataManager:self didAddDeviceWithDictionary:dic];
    }
}

-(void)deleteDeviceWithID:(NSString *)deviceID
{
    NSAssert(dispatch_get_specific(moduleQueueTag), @"Invoked on incorrect queue");
    
    [aiertDeviceCoreDataManagerStorage deleteDeviceWithDeviceID:deviceID];
    [multicastDelegate aiertDeviceCoreDataManager:self didDeleteDeviceWithDeviceID:deviceID];
}

-(void)editDeviceWithDeviceInfoDictionary:(NSDictionary *)dic
{
     NSAssert(dispatch_get_specific(moduleQueueTag), @"Invoked on incorrect queue");
    
    if ([aiertDeviceCoreDataManagerStorage editDeviceWithDeviceInfoDictionary:dic]) {
        [multicastDelegate aiertDeviceCoreDataManager:self didEditDeviceWithDictionary:dic];
    }
    
}

#pragma mark -
#pragma mark - Action Methods
- (void)addDeviceWithDeviceInfo:(AiertDeviceInfo *)aiertDevice
{
    if (!aiertDevice || !aiertDevice.deviceID) {
        return;
    }
    
    __block NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    dispatch_block_t block = ^{@autoreleasepool {
        
        [dic setObject:aiertDevice.deviceID forKey:@"deviceID"];
        if (aiertDevice.deviceName) {
            [dic setObject:aiertDevice.deviceName forKey:@"deviceName"];
        }
        if (aiertDevice.deviceStatus) {
            [dic setObject:[NSNumber numberWithInt:aiertDevice.deviceStatus] forKey:@"deviceStatus"];
        }
        if (aiertDevice.userInfo.userName) {
            [dic setObject:aiertDevice.userInfo.userName forKey:@"userName"];
        }
        if (aiertDevice.userInfo.userPassword) {
            [dic setObject:aiertDevice.userInfo.userPassword forKey:@"userPassword"];
        }
        
        if (aiertDevice.deviceAdditionInfo) {
            [dic setObject:aiertDevice.deviceAdditionInfo forKey:@"deviceAdditionInfo"];
        }
        
        [self addDeviceWithDictionary:dic];
        [multicastDelegate aiertDeviceCoreDataManager:self willAddDeviceWithDictionary:dic];
        
        }
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

- (void)deleteDeviceWithDeviceID:(NSString *)ID
{
    if (!ID) return;
    
    NSString *deviceID = [ID copy];
    
    dispatch_block_t block = ^{@autoreleasepool {
        
        [self deleteDeviceWithID:deviceID];
        
        }
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);

}

- (void)editDeviceWithDeviceInfo:(AiertDeviceInfo *)aiertDevice
{
    if (!aiertDevice) {
        return;
    }
    
    __block NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    dispatch_block_t block = ^{@autoreleasepool {
        
        [dic setObject:aiertDevice.deviceID forKey:@"deviceID"];
        [dic setObject:aiertDevice.deviceName forKey:@"deviceName"];
        [dic setObject:[NSNumber numberWithInteger:aiertDevice.deviceStatus] forKey:@"deviceStatus"];
        [dic setObject:aiertDevice.userInfo.userName forKey:@"userName"];
        [dic setObject:aiertDevice.userInfo.userPassword forKey:@"userPassword"];
        if (aiertDevice.deviceAdditionInfo) {
            [dic setObject:aiertDevice.deviceAdditionInfo forKey:@"deviceAdditionInfo"];
        }
        
        [self editDeviceWithDeviceInfoDictionary:dic];
        //TODO:这里可以增加一个回掉方法
        
        }
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
 
}
@end
