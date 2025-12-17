# mParticle Kit Architecture

This document synthesizes the understanding gained from studying the mParticle Kit documentation, example implementations, and SDK source code.

## 1. What is an mParticle Kit?

### Conceptual Definition

An mParticle Kit is a **client-side integration module** that bridges the mParticle SDK with a third-party analytics/marketing SDK (the "partner SDK"). Kits allow mParticle customers to:

1. Collect data once via the mParticle SDK
2. Forward that data to multiple destinations automatically
3. Maintain a single data collection API while supporting many downstream services

### Technical Definition

A Kit is a modular component that:

- **Wraps a partner SDK** (e.g., Mixpanel, Amplitude, Firebase)
- **Implements a protocol/interface** defined by mParticle (`MPKitProtocol` on iOS)
- **Receives events from the mParticle SDK** through protocol methods
- **Transforms and forwards events** to the partner SDK
- **Is dynamically loaded** when configured in the mParticle dashboard

### Kit vs Server-Side Forwarding

| Aspect | Kit (Client-Side) | Server-Side |
|--------|-------------------|-------------|
| SDK Location | On device | mParticle servers |
| Partner SDK | Included in app | Not needed |
| Latency | Real-time | Batch (minutes) |
| Features | Full SDK features | API-only features |
| App Size | Larger | Smaller |

Kits are preferred when:
- Partner requires device-specific features (device ID, advertising ID)
- Real-time functionality is needed
- Full SDK capabilities are required (e.g., push notifications, in-app messages)

---

## 2. How an mParticle Kit Works

### Lifecycle

```
┌─────────────────────────────────────────────────────────────────┐
│                    mParticle SDK Initialization                  │
└─────────────────────────────────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│ 1. Kit Registration                                              │
│    - Kit registers itself via +[MPKitRegister registerKit:]      │
│    - Happens in +load method (before main())                     │
└─────────────────────────────────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│ 2. Configuration Received                                        │
│    - mParticle fetches kit config from server                    │
│    - Calls didFinishLaunchingWithConfiguration:                  │
│    - Kit receives token, settings, feature flags                 │
└─────────────────────────────────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│ 3. Kit Start                                                     │
│    - Kit initializes partner SDK with configuration              │
│    - Sets started = YES                                          │
│    - Posts mParticleKitDidBecomeActiveNotification               │
└─────────────────────────────────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│ 4. Event Forwarding (ongoing)                                    │
│    - logBaseEvent: → routeEvent: or routeCommerceEvent:          │
│    - logScreen: → screen views                                   │
│    - onIdentifyComplete: etc → identity events                   │
│    - onSetUserAttribute: → user profile updates                  │
└─────────────────────────────────────────────────────────────────┘
```

### Event Flow

```
App Code                mParticle SDK              Kit                    Partner SDK
   │                         │                      │                          │
   │ track("Purchase")       │                      │                          │
   │────────────────────────>│                      │                          │
   │                         │ logBaseEvent:        │                          │
   │                         │─────────────────────>│                          │
   │                         │                      │ routeCommerceEvent:      │
   │                         │                      │─────────────────────────>│
   │                         │                      │ Mixpanel.track()         │
   │                         │                      │─────────────────────────>│
   │                         │                      │                          │
   │                         │ MPKitExecStatus      │                          │
   │                         │<─────────────────────│                          │
```

### Initialization Pattern (iOS)

```objc
// 1. Kit Code - unique identifier assigned by mParticle
+ (NSNumber *)kitCode {
    return @178;  // Mixpanel's assigned kit code
}

// 2. Registration - happens at load time
+ (void)load {
    MPKitRegister *kitRegister = [[MPKitRegister alloc] initWithName:@"Mixpanel"
                                                           className:@"MPKitMixpanel"];
    [MParticle registerExtension:kitRegister];
}

// 3. Configuration - receives settings from mParticle server
- (MPKitExecStatus *)didFinishLaunchingWithConfiguration:(NSDictionary *)configuration {
    self.configuration = configuration;
    [self start];
    return [self execStatus:MPKitReturnCodeSuccess];
}

// 4. Start - initialize partner SDK
- (void)start {
    // Get configuration values
    NSString *token = self.configuration[@"token"];

    // Initialize partner SDK
    [Mixpanel sharedInstanceWithToken:token];

    // Mark as started
    self.started = YES;

    // Notify mParticle
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *info = @{mParticleKitInstanceKey: [[self class] kitCode]};
        [[NSNotificationCenter defaultCenter] postNotificationName:mParticleKitDidBecomeActiveNotification
                                                            object:nil
                                                          userInfo:info];
    });
}
```

---

## 3. What Makes a Good mParticle Kit

### Best Practices

1. **Configuration-Driven**
   - All settings come from mParticle configuration
   - No hardcoded values
   - Support for server-side toggling of features

2. **Proper Status Returns**
   - Return `MPKitReturnCodeSuccess` when operation succeeds
   - Return `MPKitReturnCodeFail` when operation fails
   - Return `MPKitReturnCodeRequirementsNotMet` when preconditions aren't met

3. **Clean Event Mapping**
   - Transform mParticle event types to partner equivalents
   - Preserve event attributes/properties
   - Handle type conversions properly

4. **Identity Alignment**
   - Map mParticle identity types to partner identity
   - Support configurable identity mapping
   - Handle anonymous → identified transitions

5. **Error Handling**
   - Don't crash on malformed data
   - Log errors appropriately
   - Gracefully degrade when partner SDK fails

6. **Thread Safety**
   - Partner SDK calls may need to be on main thread
   - Use dispatch_async when required
   - Don't block the calling thread

### Code Quality

```objc
// Good: Null-safe, type-checked, clean transformation
- (MPKitExecStatus *)routeEvent:(MPEvent *)event {
    if (!event.name || event.name.length == 0) {
        return [self execStatus:MPKitReturnCodeFail];
    }

    NSDictionary *properties = event.customAttributes ?: @{};
    [[Mixpanel sharedInstance] track:event.name properties:properties];

    return [self execStatus:MPKitReturnCodeSuccess];
}

// Bad: No validation, unsafe access
- (MPKitExecStatus *)routeEvent:(MPEvent *)event {
    [[Mixpanel sharedInstance] track:event.name properties:event.customAttributes];
    return [self execStatus:MPKitReturnCodeSuccess];
}
```

---

## 4. Platform Differences (iOS vs JavaScript)

### Architecture Comparison

| Aspect | iOS Kit | JavaScript Kit |
|--------|---------|----------------|
| Language | Objective-C (typically) | ECMAScript 5 |
| Protocol | `MPKitProtocol` | Handler modules |
| Registration | `+load` method | Module registration |
| Configuration | `didFinishLaunchingWithConfiguration:` | `initForwarder()` |
| Event Routing | `logBaseEvent:` → `routeEvent:` | `processEvent()` |
| Distribution | CocoaPods, SPM | npm |

### Event Type Mapping

| mParticle Concept | iOS | JavaScript |
|-------------------|-----|------------|
| Custom Event | `MPEvent` | `PageEvent` (MessageType 4) |
| Screen View | `logScreen:` | `PageView` (MessageType 3) |
| Commerce Event | `MPCommerceEvent` | `Commerce` (MessageType 16) |
| User Attribute | `onSetUserAttribute:` | `setUserAttribute()` |
| Identity | `onIdentifyComplete:` | `onIdentifyComplete()` |

### Identity Handling

**iOS:**
```objc
- (MPKitExecStatus *)onLoginComplete:(FilteredMParticleUser *)user
                             request:(FilteredMPIdentityApiRequest *)request {
    NSString *customerId = user.userIdentities[@(MPUserIdentityCustomerId)];
    if (customerId) {
        [[Mixpanel sharedInstance] identify:customerId];
    }
    return [self execStatus:MPKitReturnCodeSuccess];
}
```

**JavaScript:**
```javascript
function onLoginComplete(user) {
    var customerId = user.getUserIdentities().userIdentities.customerid;
    if (customerId) {
        mixpanel.mparticle.identify(customerId);
    }
    return { returnCode: Success };
}
```

---

## 5. The mparticle-javascript-integration-mixpanel Implementation

### Feature Summary

The JS Mixpanel Kit implements the following features:

| Feature | Implementation | Notes |
|---------|----------------|-------|
| Event Tracking | `mixpanel.track()` | All PageEvents |
| Screen Views | `mixpanel.track("Viewed X")` | Prefixes with "Viewed " |
| Identity | `mixpanel.identify()` | Configurable identity type |
| Logout | `mixpanel.reset()` | Clears identity |
| User Attrs (People) | `mixpanel.people.set()` | When useMixpanelPeople=true |
| User Attrs (Super) | `mixpanel.register()` | When useMixpanelPeople=false |
| Commerce | `mixpanel.people.track_charge()` | Purchase events only |

### Configuration Options

| Setting | Type | Purpose |
|---------|------|---------|
| `token` | String | Mixpanel project token |
| `baseUrl` | String | Custom API endpoint (optional) |
| `userIdentificationType` | Enum | Which identity to use (CustomerId, MPID, Other, Other2-4) |
| `useMixpanelPeople` | Boolean | Use People API vs Super Properties |

### Key Implementation Patterns

**Configurable Identity Mapping:**
```javascript
function getUserId(user) {
    switch (forwarderSettings.userIdentificationType) {
        case 'CustomerId':
            return userIdentities.customerid;
        case 'MPID':
            return user.getMPID();
        case 'Other':
            return userIdentities.other;
        // ...
    }
}
```

**User Attribute Mode Toggle:**
```javascript
if (forwarderSettings.useMixpanelPeople) {
    mixpanel.mparticle.people.set(attrs);
} else {
    mixpanel.mparticle.register(attrs);
}
```

**Commerce Event Handling:**
```javascript
function logPurchaseEvent(event) {
    if (event.ProductAction.ProductActionType !== Purchase) {
        return; // Only handle purchases
    }
    mixpanel.mparticle.people.track_charge(
        event.ProductAction.TotalAmount,
        event.EventAttributes || {}
    );
}
```

---

## 6. Relevant mixpanel-swift APIs for Kit Implementation

### Core APIs

| Category | API | iOS Kit Usage |
|----------|-----|---------------|
| **Init** | `Mixpanel.initialize(token:trackAutomaticEvents:serverURL:)` | `start` method |
| **Instance** | `Mixpanel.mainInstance()` | All subsequent calls |
| **Tracking** | `.track(event:properties:)` | `routeEvent:` |
| **Screen** | `.track(event: "Viewed \(name)")` | `logScreen:` |
| **Identity** | `.identify(distinctId:)` | `onLoginComplete:` |
| **Logout** | `.reset()` | `onLogoutComplete:` |
| **Super Props** | `.registerSuperProperties(_:)` | User attrs (when useMixpanelPeople=false) |
| **Super Props** | `.unregisterSuperProperty(_:)` | Remove user attr |
| **People** | `.people.set(properties:)` | User attrs (when useMixpanelPeople=true) |
| **People** | `.people.unset(properties:)` | Remove user attr |
| **Revenue** | `.people.trackCharge(amount:properties:)` | Commerce events |
| **Opt Out** | `.optOutTracking()` / `.optInTracking()` | GDPR support |

### Type Conversions

mParticle uses `NSDictionary` for attributes, Mixpanel uses `[String: MixpanelType]`:

```swift
// Convert NSDictionary to Properties
func convertToMixpanelProperties(_ attrs: [String: Any]?) -> Properties? {
    guard let attrs = attrs else { return nil }
    var properties: Properties = [:]
    for (key, value) in attrs {
        if let mixpanelValue = value as? MixpanelType {
            properties[key] = mixpanelValue
        }
    }
    return properties
}
```

### Initialization Options

```swift
// Full initialization with all options
let instance = Mixpanel.initialize(
    token: configuration["token"] as! String,
    trackAutomaticEvents: false,  // Kit handles events
    flushInterval: 60,
    instanceName: "mparticle",
    optOutTrackingByDefault: false,
    useUniqueDistinctId: false,
    superProperties: nil,
    serverURL: configuration["baseUrl"] as? String
)
```

---

## Summary

An mParticle iOS Kit for Mixpanel must:

1. **Register** itself with mParticle at load time with Kit ID 178
2. **Initialize** Mixpanel SDK with token from configuration in `start`
3. **Forward events** from `routeEvent:` to `Mixpanel.track()`
4. **Forward screens** from `logScreen:` to `Mixpanel.track("Viewed X")`
5. **Handle identity** from `onLoginComplete:` → `identify()`, `onLogoutComplete:` → `reset()`
6. **Handle user attributes** to either `people.set()` or `registerSuperProperties()` based on config
7. **Handle commerce** from `routeCommerceEvent:` → `people.trackCharge()` for purchases
8. **Provide access** to Mixpanel instance via `providerKitInstance`

The implementation should match the JS Kit's feature set while following iOS platform conventions and the `MPKitProtocol` contract.
