//
//  AiertDeviceCoreDataStorageObject.m
//  AiertApp
//
//  Created by Peter Lee on 14/10/10.
//  Copyright (c) 2014年 爱尔特. All rights reserved.
//

#import "AiertDeviceCoreDataStorageObject.h"


@implementation AiertDeviceCoreDataStorageObject

@dynamic deviceID;
@dynamic deviceName;
@dynamic deviceStatus;
@dynamic userName;
@dynamic userPassword;

#pragma mark -
#pragma mark - Getters and seters Methods
- (NSString *)deviceID
{
    [self willAccessValueForKey:@"deviceID"];
    NSString *value = [self primitiveValueForKey:@"deviceID"];
    [self didAccessValueForKey:@"deviceID"];
    return value;
}
            
- (void)setDeviceID:(NSString *)value
{
    [self willChangeValueForKey:@"deviceID"];
    [self setPrimitiveValue:value forKey:@"deviceID"];
    [self didChangeValueForKey:@"deviceID"];
}

- (NSString *)deviceName
{
    [self willAccessValueForKey:@"deviceName"];
    NSString *value = [self primitiveValueForKey:@"deviceName"];
    [self didAccessValueForKey:@"deviceName"];
    return value;
}

- (void)setDeviceName:(NSString *)value
{
    [self willChangeValueForKey:@"deviceName"];
    [self setPrimitiveValue:value forKey:@"deviceName"];
    [self didChangeValueForKey:@"deviceName"];
}

- (NSNumber *)deviceStatus
{
    [self willAccessValueForKey:@"deviceStatus"];
    NSString *value = [self primitiveValueForKey:@"deviceStatus"];
    [self didAccessValueForKey:@"deviceStatus"];
    return value;
}

- (void)setDeviceStatus:(NSString *)value
{
    [self willChangeValueForKey:@"deviceStatus"];
    [self setPrimitiveValue:value forKey:@"deviceStatus"];
    [self didChangeValueForKey:@"deviceStatus"];
}

- (NSString *)userName
{
    [self willAccessValueForKey:@"userName"];
    NSString *value = [self primitiveValueForKey:@"userName"];
    [self didAccessValueForKey:@"userName"];
    return value;
}

- (void)setUserName:(NSString *)value
{
    [self willChangeValueForKey:@"userName"];
    [self setPrimitiveValue:value forKey:@"userName"];
    [self didChangeValueForKey:@"userName"];
}

- (NSString *)userPassword
{
    [self willAccessValueForKey:@"userPassword"];
    NSString *value = [self primitiveValueForKey:@"userPassword"];
    [self didAccessValueForKey:@"userPassword"];
    return value;
}

- (void)setUserPassword:(NSString *)value
{
    [self willChangeValueForKey:@"userPassword"];
    [self setPrimitiveValue:value forKey:@"userPassword"];
    [self didChangeValueForKey:@"userPassword"];
}

#pragma mark -
#pragma mark - public Methods

+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc
                          withDictionary:(NSDictionary *)dic
{
    NSString *deviceID = [dic objectForKey:@"deviceID"];
    
    if (dic == NULL) return nil;
    if (deviceID == nil) return nil;

    AiertDeviceCoreDataStorageObject *newDevice = [NSEntityDescription insertNewObjectForEntityForName:@"AiertDeviceCoreDataStorageObject"
                                            inManagedObjectContext:moc];
    newDevice.deviceID = deviceID;
    newDevice.deviceName = [dic objectForKey:@"deviceName"];
    newDevice.deviceStatus = [dic objectForKey:@"deviceStatus"];
    newDevice.userName = [dic objectForKey:@"userName"];
    newDevice.userPassword = [dic objectForKey:@"userPassword"];
    
    return newDevice;
}

#pragma mark -
#pragma mark - Private Methods
- (void)updateWithDictionary:(NSDictionary *)dic
{
    NSString *deviceID = [dic objectForKey:@"deviceID"];
    
    if (dic == NULL) return;
    if (deviceID == nil) return;
    
    self.deviceID = deviceID;
    self.deviceName = [dic objectForKey:@"deviceName"];
    self.deviceStatus = [dic objectForKey:@"deviceStatus"];
    self.userName = [dic objectForKey:@"userName"];
    self.userPassword = [dic objectForKey:@"userPassword"];
}
@end
