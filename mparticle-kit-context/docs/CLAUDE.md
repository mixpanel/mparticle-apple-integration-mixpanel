# mParticle Documentation

## Purpose

This directory contains official mParticle documentation for Kit development, scraped from docs.mparticle.com.

## Files and Relevance

### overview.md
**Relevance: Medium**

Provides high-level understanding of what mParticle Kits are:
- Kits wrap partner SDKs for client-side integration
- Typically used when partner features aren't available via server-to-server forwarding
- Links to official example kits and development guides

### ios-kit-implementation.md
**Relevance: Critical**

This is the most important documentation file. It covers:
- Kit project structure and naming conventions
- `MPKitProtocol` implementation requirements
- Configuration handling via `initWithConfiguration:startImmediately:`
- The `start` method and lifecycle
- Kit ID assignment (contact mParticle for official Kit ID)
- Publishing requirements (CocoaPods, README, unit tests)

Key patterns to follow:
1. Implement `+ (NSNumber *)kitCode` with assigned Kit ID
2. Use `+ (void)load` for kit registration
3. Implement `didFinishLaunchingWithConfiguration:` for initialization
4. Broadcast `mParticleKitDidBecomeActiveNotification` when started

### ios-kit-integration.md
**Relevance: High**

Covers Kit usage from the app developer perspective:
- Making direct calls to Kit instances via `kitInstance`
- Kit availability notifications
- Deep linking support
- Sideloaded (custom) kit development
- Client-side filtering for sideloaded kits

Important for understanding how developers will interact with the Kit.

### javascript-kit-integration.md
**Relevance: Medium**

JS Kit development guide. Useful for:
- Understanding the handler pattern (commerce, event, identity, session, user-attribute)
- Event types and data structures
- eCommerce helpers and event expansion

## Platform Differences (iOS vs JS)

| Aspect | iOS | JavaScript |
|--------|-----|------------|
| Language | Objective-C/Swift | ECMAScript 5 |
| Integration | CocoaPods/SPM | npm/script tag |
| Protocol | `MPKitProtocol` | Handler modules |
| Lifecycle | `start` method | `initForwarder` function |
| Event routing | `logBaseEvent:` method | `processEvent` function |
| Identity | `onLoginComplete:` etc. | `onLoginComplete()` etc. |

## Implementation Checklist

- [ ] Read ios-kit-implementation.md thoroughly before coding
- [ ] Obtain Kit ID from mParticle (or use placeholder for sideloaded kit)
- [ ] Follow the naming convention: `mparticle-apple-integration-mixpanel`
- [ ] Create `.podspec` file with proper dependencies
- [ ] Implement unit tests
