#ifndef ThreadSelfManager_h
#define ThreadSelfManager_h

#import "ThreadManager.h"
#import <React/RCTBridge.h>
#import <React/RCTBridge+Private.h>
#import <React/RCTEventDispatcher.h>

@interface ThreadSelfManager : NSObject <RCTBridgeModule>
@property int threadId;
@property id workerManager;
@property NSString *threadMessage;
@end

#endif
