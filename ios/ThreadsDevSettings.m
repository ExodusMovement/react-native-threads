#import "ThreadsDevSettings.h"
#import <React/RCTLog.h>

@implementation ThreadsDevSettings
{
  ThreadsInstanceData *_data;
}

// We're replacing the stock implementation of RCTDevSettings for the worker bridge.
// We define `moduleName` instead of using RCT_EXPORT_MODULE because the latter would
// override RCTDevSettings for the parent bridge, which is undesirable.
+ (NSString *)moduleName
{
  return @"RCTDevSettings";
}

// RCTDevSettings doesn't expose requiresMainQueueSetup, so we explicitly keep it in sync.
+ (BOOL)requiresMainQueueSetup
{
  return YES;
}

- (instancetype)initWithData:(ThreadsInstanceData *)data
{
  if (self = [self init]) {
    _data = data;
  }
  return self;
}

- (BOOL)isShakeToShowDevMenuEnabled
{
  return NO;
}

- (BOOL)isRemoteDebuggingAvailable
{
  return _data.bundlerPort && super.isRemoteDebuggingAvailable;
}

- (void)_remoteDebugSettingDidChange
{
  if (super.isDebuggingRemotely && !self.isRemoteDebuggingAvailable) {
    RCTLogWarn(
      @"The worker with bundle root %@ cannot be debugged remotely because it does "
       "not have a unique bundler instance. Start another bundler on a unique port "
       "(using the --port argument), then provide that port to the Worker constructor.",
      _data.name
    );
    return;
  }
  [super _remoteDebugSettingDidChange];
}

@end