//
//  AiertDeviceCoreDataStorage.h
//  AiertApp
//
//  Created by Peter Lee on 14/10/10.
//  Copyright (c) 2014年 爱尔特. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreDataStorage.h"
#import "AiertDeviceCoreDataManager.h"
#import "AiertDeviceCoreDataStorageObject.h"

#define AssertPrivateQueue() \
NSAssert(dispatch_get_specific(storageQueueTag), @"Private method: MUST run on storageQueue");

@interface AiertDeviceCoreDataStorage : CoreDataStorage<AiertDeviceCoreDataManagerStorage>

+ (instancetype)sharedInstance;

@end
