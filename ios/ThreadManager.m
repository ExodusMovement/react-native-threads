#import "ThreadManager.h"
#import "ThreadsDevSettings.h"
#include <stdlib.h>

@implementation ThreadManager
{
  bool hasListeners;
}

@synthesize bridge = _bridge;

NSMutableDictionary *threads;
int nextThreadId = 1;
NSString *const THREAD_TERMINATED = @"ThreadIsTerminated";
NSString *const THREAD_MESSAGE = @"Thread";

- (NSArray<NSString *> *)supportedEvents
{
  return @[THREAD_TERMINATED, THREAD_MESSAGE];
}

-(void)startObserving {
    hasListeners = YES;
}

-(void)stopObserving {
    hasListeners = NO;
}

-(void) checkAndSendEvent:(NSString*)name body:(id)body
{
    if (hasListeners) {
      [self sendEventWithName:name body:body];
    }
}

RCT_EXPORT_MODULE();


RCT_REMAP_METHOD(startThread,
                 name: (NSString *)name
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
  if (threads == nil) {
    threads = [[NSMutableDictionary alloc] init];
  }

  int threadId = nextThreadId++;

  NSURL *threadURL = [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:name fallbackResource:name];
  NSLog(@"starting Thread %@", [threadURL absoluteString]);

  RCTBridgeModuleListProvider threadModuleProvider = ^NSArray<id<RCTBridgeModule>> *{
    ThreadsDevSettings *devSettings = [[ThreadsDevSettings alloc] init];
    return @[devSettings];
  };


  RCTBridge *threadBridge = [[RCTBridge alloc] initWithBundleURL:threadURL
                                            moduleProvider:threadModuleProvider
                                             launchOptions:nil];

  ThreadSelfManager *threadSelf = [threadBridge moduleForName:@"ThreadSelfManager"];
  [threadSelf setThreadId:threadId];
  [threadSelf setWorkerManager:self];
  [threadSelf setThreadMessage:THREAD_MESSAGE];


  [threads setObject:threadBridge forKey:[NSNumber numberWithInt:threadId]];
  resolve([NSNumber numberWithInt:threadId]);
}

RCT_EXPORT_METHOD(stopThread:(int)threadId)
{
  if (threads == nil) {
    NSLog(@"Empty list of threads. abort stopping thread with id %i", threadId);
    [self checkAndSendEvent:THREAD_TERMINATED body:@{@"threadId": [NSString stringWithFormat:@"%i",threadId]}];
    return;
  }

  RCTBridge *threadBridge = threads[[NSNumber numberWithInt:threadId]];
  if (threadBridge == nil) {
    NSLog(@"Thread is NIl. abort stopping thread with id %i", threadId);
    [self checkAndSendEvent:THREAD_TERMINATED body:@{@"threadId": [NSString stringWithFormat:@"%i",threadId]}];
    return;
  }

  [threadBridge invalidate];
  [threads removeObjectForKey:[NSNumber numberWithInt:threadId]];
}

RCT_EXPORT_METHOD(postThreadMessage: (int)threadId message:(NSString *)message)
{
  if (threads == nil) {
    NSLog(@"Empty list of threads. abort posting to thread with id %i", threadId);
    [self checkAndSendEvent:THREAD_TERMINATED body:@{@"threadId": [NSString stringWithFormat:@"%i",threadId]}];
    return;
  }

  RCTBridge *threadBridge = threads[[NSNumber numberWithInt:threadId]];
  if (threadBridge == nil) {
    NSLog(@"Thread is NIl. abort posting to thread with id %i", threadId);
    [self checkAndSendEvent:THREAD_TERMINATED body:@{@"threadId": [NSString stringWithFormat:@"%i",threadId]}];
    return;
  }

  [threadBridge.eventDispatcher sendAppEventWithName:@"ThreadMessage"
                                               body:message];
}

- (void)invalidate {
  if (threads == nil) {
    return;
  }

  for (NSNumber *threadId in threads) {
    RCTBridge *threadBridge = threads[threadId];
    [threadBridge invalidate];
  }

  [threads removeAllObjects];
  threads = nil;
}

@end
