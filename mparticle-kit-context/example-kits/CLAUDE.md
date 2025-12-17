# Example Kits Directory

## Purpose

This directory contains reference Kit implementations that serve as templates and feature guides for building `mparticle-apple-integration-mixpanel`.

## Directories and Relevance

### mparticle-apple-integration-example/
**Relevance: Critical - Structural Template**

The official iOS Kit template. Use this for:
- Project structure and file organization
- `MPKitProtocol` implementation patterns
- CocoaPods and Swift Package Manager setup
- Xcode project configuration
- Unit test structure

Do NOT copy feature implementation from here - it's just a skeleton.

### mparticle-javascript-integration-example/
**Relevance: Low**

The official JS Kit template. Reference only for understanding the JS handler pattern if needed.

### mparticle-javascript-integration-mixpanel/
**Relevance: Critical - Feature Reference**

**This is the primary reference for what features to implement.** It shows exactly which Mixpanel APIs the Kit should expose and how mParticle events map to Mixpanel calls.

Study this implementation to understand:
- Which events to forward (PageEvent, PageView, Commerce)
- Identity handling patterns (identify, login, logout, modify)
- User attribute handling (register vs people.set)
- Commerce event handling (track_charge)
- Settings structure (token, baseUrl, userIdentificationType, useMixpanelPeople)

## Implementation Approach

1. **Structure** from `mparticle-apple-integration-example/`
2. **Features** from `mparticle-javascript-integration-mixpanel/`
3. **Swift APIs** from `mixpanel-sdks/mixpanel-swift/`

## JS-to-iOS Feature Mapping

The JS Kit implements these features that need iOS equivalents:

| JS Method | When Called | iOS Kit Method to Implement |
|-----------|-------------|----------------------------|
| `initForwarder()` | SDK init | `didFinishLaunchingWithConfiguration:` |
| `processEvent()` | Any event | `logBaseEvent:` |
| `logEvent()` | PageEvent | `routeEvent:` |
| `logPageView()` | PageView | `logScreen:` |
| `logCommerceEvent()` | Purchase | `routeCommerceEvent:` |
| `onIdentifyComplete()` | Identify | `onIdentifyComplete:request:` |
| `onLoginComplete()` | Login | `onLoginComplete:request:` |
| `onLogoutComplete()` | Logout | `onLogoutComplete:request:` |
| `onModifyComplete()` | Modify | `onModifyComplete:request:` |
| `setUserAttribute()` | Attribute set | `onSetUserAttribute:` |
| `removeUserAttribute()` | Attribute remove | `onRemoveUserAttribute:` |
