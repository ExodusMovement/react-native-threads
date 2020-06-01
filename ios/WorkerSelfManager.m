#import "ThreadSelfManager.h"
#include <stdlib.h>

@implementation ThreadSelfManager

RCT_EXPORT_MODULE();

@synthesize bridge = _bridge;
@synthesize workerManager = _workerManager;
@synthesize threadId = _threadId;
@synthesize threadMessage = _threadMessage;

RCT_EXPORT_METHOD(postMessage: (NSString *)message)
{
  if (self.workerManager == nil) {
    NSLog(@"No worker manager defined - abort sending thread message");
    return;
  }

  NSString *eventBody = [NSString stringWithFormat:@"{\"id\":%i,\"message\":%@}", self.threadId, message];

  [self.workerManager checkAndSendEvent:self.threadMessage body:eventBody];
}

@end
