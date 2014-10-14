//
//  AiertDeviceCoreDataStorage.m
//  AiertApp
//
//  Created by Peter Lee on 14/10/10.
//  Copyright (c) 2014年 爱尔特. All rights reserved.
//

#import "AiertDeviceCoreDataStorage.h"

@implementation AiertDeviceCoreDataStorage

static AiertDeviceCoreDataStorage *sharedInstance;

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[AiertDeviceCoreDataStorage alloc] initWithDatabaseFilename:nil storeOptions:nil];
    });
    
    return sharedInstance;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Setup
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Overrides
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)commonInit
{
    autoAllowExternalBinaryDataStorage = YES;
    autoRecreateDatabaseFile = YES;
    [super commonInit];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Public methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (AiertDeviceCoreDataStorageObject *)deviceForID:(NSString *)id
                            managedObjectContext:(NSManagedObjectContext *)moc
{
    if (id == nil) return nil;
    if (moc == nil) return nil;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"AiertDeviceCoreDataStorageObject"
                                              inManagedObjectContext:moc];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"deviceID == %@", id];

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setIncludesPendingChanges:YES];
    [fetchRequest setFetchLimit:1];
    
    NSArray *results = [moc executeFetchRequest:fetchRequest error:nil];
    
    return (AiertDeviceCoreDataStorageObject *)[results lastObject];
}


#pragma mark -
#pragma mark - AiertDeviceCoreDataManagerStorage Methods

- (BOOL)configureWithParent:(AiertDeviceCoreDataManager *)aParent queue:(dispatch_queue_t)queue
{
    return [super configureWithParent:aParent queue:queue];
}
- (BOOL)addDeviceWithDeviceInfoDictionary:(NSDictionary *)dic
{
    NSDictionary *dictionary = [dic copy];
    
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        [AiertDeviceCoreDataStorageObject insertInManagedObjectContext:moc withDictionary:dictionary];
        
    }];
    return YES;
}

- (BOOL)deleteDeviceWithDeviceID:(NSString *)ID
{
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        
        AiertDeviceCoreDataStorageObject *device = [self deviceForID:ID managedObjectContext:moc];
        
        if (device){
            [moc deleteObject:device];
        }
    }];
    
    return YES;
}

- (BOOL)editDeviceWithDeviceInfoDictionary:(NSDictionary *)dic
{
    NSString *deviceID = [dic objectForKey:@"deviceID"];
    
    if (!dic) return NO;
    if (!deviceID) return NO;
    
    [self scheduleBlock:^{
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        
        AiertDeviceCoreDataStorageObject *device = [self deviceForID:deviceID managedObjectContext:moc];
        
        if (device){
            [device setDeviceID:deviceID];
            [device setDeviceName:[dic objectForKey:@"deviceName"]];
            [device setUserName:[dic objectForKey:@"userName"]];
            [device setUserPassword:[dic objectForKey:@"userPassword"]];
        }
    }];
    
    return YES;
}

@end
