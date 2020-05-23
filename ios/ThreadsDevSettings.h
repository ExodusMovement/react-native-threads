#import "ThreadManager.h"
#import <React/RCTBridgeModule.h>
#import <React/RCTDevSettings.h>

@interface RCTDevSettings ()
// The `bridge` property must be defined on the RCTDevSettings (the superclass)
// in order for its conditional logic about development settings to be accurate.
// The `bridge` property is synthesized in the implementation (which is private),
// so we explicitly declare its interface here.
@property(nonatomic, weak) RCTBridge *bridge;

// We override this method to raise a warning if the worker cannot be debugged.
- (void)_remoteDebugSettingDidChange;
@end

@interface ThreadsDevSettings : RCTDevSettings <RCTBridgeModule>
@end