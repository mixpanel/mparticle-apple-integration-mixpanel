# iOS Example Kit

## Purpose

This is the official mParticle iOS Kit template. It provides the **structural foundation** for building `mparticle-apple-integration-mixpanel`.

## Key Files

### mParticle-Example/MPKitExample.h
The Kit header file. Key elements:
- Imports for mParticle SDK (handles SPM, CocoaPods, and direct import)
- `MPKitProtocol` conformance declaration
- Required properties: `configuration`, `launchOptions`, `started`

### mParticle-Example/MPKitExample.m
The Kit implementation. **Study this file thoroughly.** Key sections:

1. **Kit Registration**
   ```objc
   + (NSNumber *)kitCode { return @123; }  // Get ID from mParticle
   + (void)load { /* Register kit with MParticle */ }
   ```

2. **Initialization**
   ```objc
   - (MPKitExecStatus *)didFinishLaunchingWithConfiguration:(NSDictionary *)configuration
   ```

3. **Lifecycle**
   ```objc
   - (void)start  // Initialize partner SDK, broadcast notification
   - (id const)providerKitInstance  // Return partner SDK instance
   ```

4. **Event Handling**
   ```objc
   - (MPKitExecStatus *)logBaseEvent:(MPBaseEvent *)event  // Route to handlers
   - (MPKitExecStatus *)routeEvent:(MPEvent *)event  // Custom events
   - (MPKitExecStatus *)logScreen:(MPEvent *)event  // Screen views
   - (MPKitExecStatus *)routeCommerceEvent:(MPCommerceEvent *)event  // Commerce
   ```

5. **Identity**
   ```objc
   - (MPKitExecStatus *)onIdentifyComplete:(FilteredMParticleUser *)user request:...
   - (MPKitExecStatus *)onLoginComplete:(FilteredMParticleUser *)user request:...
   - (MPKitExecStatus *)onLogoutComplete:(FilteredMParticleUser *)user request:...
   - (MPKitExecStatus *)onModifyComplete:(FilteredMParticleUser *)user request:...
   ```

6. **User Attributes**
   ```objc
   - (MPKitExecStatus *)onSetUserAttribute:(FilteredMParticleUser *)user
   - (MPKitExecStatus *)onRemoveUserAttribute:(FilteredMParticleUser *)user
   ```

### mParticle-Integration-Example.podspec
CocoaPods specification. Customize for Mixpanel:
- Name: `mParticle-Mixpanel`
- Dependencies: `mParticle-Apple-SDK` and `Mixpanel-swift`

### Package.swift
Swift Package Manager manifest. Customize for Mixpanel.

## Implementation Pattern

Every protocol method should:
1. Extract relevant data from mParticle objects
2. Transform to partner SDK format
3. Call partner SDK method
4. Return `MPKitExecStatus` with appropriate return code

```objc
- (MPKitExecStatus *)routeEvent:(MPEvent *)event {
    // 1. Extract data
    NSString *eventName = event.name;
    NSDictionary *attributes = event.customAttributes;

    // 2. Transform & call partner SDK
    [[Mixpanel sharedInstance] track:eventName properties:attributes];

    // 3. Return status
    return [self execStatus:MPKitReturnCodeSuccess];
}
```

## For Mixpanel Implementation

Replace placeholder code with:
- Import Mixpanel-swift
- Initialize `Mixpanel.initialize(token:trackAutomaticEvents:)` in `start`
- Route events to `Mixpanel.mainInstance().track()`
- Handle identity with `Mixpanel.mainInstance().identify()` and `.reset()`
