#ifndef ThreadManager_h
#define ThreadManager_h

#import "ThreadSelfManager.h"
#import <React/RCTBridge.h>
#import <React/RCTBridge+Private.h>
#import <React/RCTEventDispatcher.h>
#import <React/RCTBundleURLProvider.h>
#import <React/RCTEventEmitter.h>

@interface ThreadManager : RCTEventEmitter <RCTBridgeModule>
- (void)checkAndSendEvent:(NSString *)name body:(id)body;
@end

#endif
