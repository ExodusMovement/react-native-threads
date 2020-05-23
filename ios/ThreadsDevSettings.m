#import "ThreadsDevSettings.h"
#import <React/RCTLog.h>

@implementation ThreadsDevSettings
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

- (BOOL)isShakeToShowDevMenuEnabled
{
  return NO;
}

- (BOOL)isRemoteDebuggingAvailable
{
  return NO;
}

- (void)_remoteDebugSettingDidChange
{
  if (super.isDebuggingRemotely && !self.isRemoteDebuggingAvailable) {
    return;
  }
  [super _remoteDebugSettingDidChange];
}

@end