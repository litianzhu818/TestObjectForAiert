//
//  AiertDeviceCoreDataManager.h
//  AiertApp
//
//  Created by Peter Lee on 14/10/12.
//  Copyright (c) 2014年 爱尔特. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDMulticastDelegate.h"
#import "AiertDeviceInfo.h"

@protocol AiertDeviceCoreDataManagerDelegate;
@protocol AiertDeviceCoreDataManagerStorage;

@interface AiertDeviceCoreDataManager : NSObject
{
    __strong id <AiertDeviceCoreDataManagerStorage> aiertDeviceCoreDataManagerStorage;
    
    dispatch_queue_t moduleQueue;
    void *moduleQueueTag;
    
    id multicastDelegate;
}

@property (readonly) dispatch_queue_t moduleQueue;
@property (readonly) void *moduleQueueTag;

- (id)initWithRoomStorage:(id <AiertDeviceCoreDataManagerStorage>)storage;
- (id)initWithRoomStorage:(id <AiertDeviceCoreDataManagerStorage>)storage dispatchQueue:(dispatch_queue_t)queue;

Single_interface(AiertDeviceCoreDataManager);

- (id)init;
- (id)initWithDispatchQueue:(dispatch_queue_t)queue;

- (void)addDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;
- (void)removeDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;
- (void)removeDelegate:(id)delegate;

- (NSString *)moduleName;


- (void)addDeviceWithDeviceInfo:(AiertDeviceInfo *)aiertDevice;
- (void)deleteDeviceWithDeviceID:(NSString *)ID;
- (void)editDeviceWithDeviceInfo:(AiertDeviceInfo *)aiertDevice;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol AiertDeviceCoreDataManagerStorage <NSObject>
@required

- (BOOL)configureWithParent:(AiertDeviceCoreDataManager *)aParent queue:(dispatch_queue_t)queue;
- (BOOL)addDeviceWithDeviceInfoDictionary:(NSDictionary *)dic;
- (BOOL)deleteDeviceWithDeviceID:(NSString *)ID;
- (BOOL)editDeviceWithDeviceInfoDictionary:(NSDictionary *)dic;

@optional


@end

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol AiertDeviceCoreDataManagerDelegate <NSObject>
@optional
- (void)aiertDeviceCoreDataManager:(AiertDeviceCoreDataManager *)aiertDeviceCoreDataManager willAddDeviceWithDictionary:(NSDictionary *)dic;
- (void)aiertDeviceCoreDataManager:(AiertDeviceCoreDataManager *)aiertDeviceCoreDataManager didAddDeviceWithDictionary:(NSDictionary *)dic;
- (void)aiertDeviceCoreDataManager:(AiertDeviceCoreDataManager *)aiertDeviceCoreDataManager didDeleteDeviceWithDeviceID:(NSString *)deviceID;
- (void)aiertDeviceCoreDataManager:(AiertDeviceCoreDataManager *)aiertDeviceCoreDataManager didEditDeviceWithDictionary:(NSDictionary *)dic;
@end