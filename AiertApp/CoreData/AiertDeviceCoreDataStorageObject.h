//
//  AiertDeviceCoreDataStorageObject.h
//  AiertApp
//
//  Created by Peter Lee on 14/10/10.
//  Copyright (c) 2014年 爱尔特. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DeviceAddition.h"


@interface AiertDeviceCoreDataStorageObject : NSManagedObject

@property (nonatomic, retain) NSString * deviceID;
@property (nonatomic, retain) NSString * deviceName;
@property (nonatomic, retain) NSNumber * deviceStatus;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSString * userPassword;
@property (nonatomic, retain) DeviceAddition *deviceAdditionInfo;

- (void)updateWithDictionary:(NSDictionary *)dic;

+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                    withDictionary:(NSDictionary *)dic;
//+ (id)insertOrUpdateManagedObjectContext:(NSManagedObjectContext *)moc
//                          withDictionary:(NSDictionary *)dic;
@end
