//
//  Singleton.h
//  FindLocationDemo
//
//  Created by Peter Lee on 14-4-22.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#ifndef AiertApp_SingletonManager_h
#define AiertApp_SingletonManager_h

//.h
#define Single_interface(class)  + (class *)sharedInstance; \
                                 +(id)allocWithZone:(NSZone *)zone; \
                                 -(id)copyWithZone:(NSZone *)zone;

// .m
// \ 代表下一行也属于宏
// ## 是分隔符
#define Single_implementation(class) \
static class *sharedInstance = nil; \
 \
+ (class *)sharedInstance \
{ \
    @synchronized (self){ \
        if (sharedInstance == nil) { \
        sharedInstance = [[self alloc] init]; \
        } \
    } \
    return sharedInstance; \
} \
 \
+ (id)allocWithZone:(NSZone *)zone \
{ \
    static dispatch_once_t onceToken; \
    dispatch_once(&onceToken, ^{ \
        sharedInstance = [super allocWithZone:zone]; \
    }); \
    return sharedInstance; \
} \
 \
-(id)copyWithZone:(NSZone *)zone \
{ \
    @synchronized (self){ \
        if (sharedInstance == nil) { \
            sharedInstance = [[class alloc] init]; \
        } \
    } \
    return sharedInstance; \
}

#endif
