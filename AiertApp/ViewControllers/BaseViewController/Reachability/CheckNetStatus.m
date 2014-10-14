//
//  CheckNetStatus.m
//  FindLocationDemo
//
//  Created by Peter Lee on 14-4-16.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//

#import "CheckNetStatus.h"

static Reachability *_reachability = nil;
BOOL _reachabilityOn;

static inline Reachability* defaultReachability () {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _reachability = [Reachability reachabilityForInternetConnection];
#if !__has_feature(objc_arc)
        [_reachability retain];
#endif
    });
    
    return _reachability;
}


@interface CheckNetStatus ()

- (void)startInternetReachability;
- (void)stopInternerReachability;
- (void)checkNetworkStatus;

@end

@implementation CheckNetStatus

Single_implementation(CheckNetStatus);

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self startInternetReachability];
    }
    return self;
}

- (void)dealloc {
    [self stopInternerReachability];
#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}


- (void)startInternetReachability {
    
    if (!_reachabilityOn) {
        _reachabilityOn = TRUE;
        [defaultReachability() startNotifier];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus) name:kReachabilityChangedNotification object:nil];
    
    [self checkNetworkStatus];
}

- (void)stopInternerReachability {
    
    _reachabilityOn = FALSE;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

-(BOOL)getInitNetworkStatus
{
    if ([defaultReachability() currentReachabilityStatus] == NotReachable) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NO_NETWORK object:nil userInfo:nil];
        [self.delegate NoNetWork];
        return NO;
    }
    return YES;
}

-(NetworkStatus)getNowNetWorkStatus
{
    return [defaultReachability() currentReachabilityStatus];
}

- (void)checkNetworkStatus {
    // called after network status changes
    NetworkStatus internetStatus = [defaultReachability() currentReachabilityStatus];
    switch (internetStatus) {
        case NotReachable:
            [[NSNotificationCenter defaultCenter] postNotificationName:DISCONNECT_NET object:nil userInfo:nil];
            [self.delegate DisconnectNetWork];
            break;
        case ReachableViaWiFi:
        case ReachableViaWWAN:
            [[NSNotificationCenter defaultCenter] postNotificationName:CONNECT_NET object:nil userInfo:nil];
            [self.delegate ConnectNetWork];
            break;
        default:
            break;
    }
}


@end
