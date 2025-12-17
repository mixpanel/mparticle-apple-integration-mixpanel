# JavaScript Mixpanel Kit

## Purpose

**This is the primary feature reference** for building `mparticle-apple-integration-mixpanel`. It defines exactly which Mixpanel features to expose and how mParticle events should map to Mixpanel API calls.

## Key Files

### src/MixpanelEventForwarder.js
**Study this file carefully.** It contains the complete integration logic.

## Implemented Features

### 1. Initialization
```javascript
mixpanel.init(settings.token, { api_host: forwarderSettings.baseUrl }, 'mparticle')
```
**iOS Equivalent:**
```swift
Mixpanel.initialize(token: token, trackAutomaticEvents: false, serverURL: serverURL)
```

### 2. Settings/Configuration
| Setting | Purpose |
|---------|---------|
| `token` | Mixpanel project token |
| `baseUrl` | Custom API endpoint (optional) |
| `userIdentificationType` | How to map mParticle identity to Mixpanel (CustomerId, MPID, Other, Other2-4) |
| `useMixpanelPeople` | Whether to use People API vs super properties |

### 3. Event Tracking
```javascript
// PageEvent
mixpanel.mparticle.track(event.EventName, event.EventAttributes);

// PageView
mixpanel.mparticle.track('Viewed ' + event.EventName, event.EventAttributes);
```
**iOS Equivalent:**
```swift
Mixpanel.mainInstance().track(event: eventName, properties: properties)
```

### 4. Identity Handling

**Login/Identify/Modify:** Call `mixpanel.identify()` with the configured identity type
```javascript
// Determine which identity to use based on settings
switch (forwarderSettings.userIdentificationType) {
    case 'CustomerId': idForMixpanel = userIdentities.customerid; break;
    case 'MPID': idForMixpanel = user.getMPID(); break;
    // etc.
}
mixpanel.mparticle.identify(idForMixpanel);
```

**Logout:** Call `mixpanel.reset()`
```javascript
mixpanel.mparticle.reset();
```

**Important:** Only identify if user has actual identities (not just MPID for anonymous users)

### 5. User Attributes
Two modes based on `useMixpanelPeople`:

**People mode (useMixpanelPeople = true):**
```javascript
mixpanel.mparticle.people.set(attr);
mixpanel.mparticle.people.unset(attribute);
```

**Super Properties mode (useMixpanelPeople = false):**
```javascript
mixpanel.mparticle.register(attr);
mixpanel.mparticle.unregister(attribute);
```

### 6. Commerce Events
Only Purchase events are handled:
```javascript
if (event.ProductAction.ProductActionType == Purchase) {
    mixpanel.mparticle.people.track_charge(event.ProductAction.TotalAmount, {...});
}
```
**Note:** Requires `useMixpanelPeople = true`

## iOS Implementation Requirements

Based on this analysis, the iOS Kit MUST implement:

1. **Initialization** with token, server URL support
2. **Event forwarding** for PageEvent and PageView (screen)
3. **Identity handling** with configurable identity type mapping
4. **User attributes** with People vs Super Properties mode
5. **Commerce events** for Purchase (via `people.trackCharge()`)
6. **Logout handling** via `reset()`

## Test Cases to Mirror

See `test/src/tests.js` for test scenarios:
- Track events and page views
- Identity operations (identify, login, logout)
- User attribute registration
- Commerce event tracking
- Settings validation

## API Mapping Summary

| JS Mixpanel | Swift Mixpanel |
|-------------|----------------|
| `mixpanel.init()` | `Mixpanel.initialize()` |
| `mixpanel.track()` | `.track(event:properties:)` |
| `mixpanel.identify()` | `.identify(distinctId:)` |
| `mixpanel.reset()` | `.reset()` |
| `mixpanel.alias()` | `.createAlias()` |
| `mixpanel.register()` | `.registerSuperProperties()` |
| `mixpanel.unregister()` | `.unregisterSuperProperty()` |
| `mixpanel.people.set()` | `.people.set(properties:)` |
| `mixpanel.people.unset()` | `.people.unset(properties:)` |
| `mixpanel.people.track_charge()` | `.people.trackCharge(amount:)` |
