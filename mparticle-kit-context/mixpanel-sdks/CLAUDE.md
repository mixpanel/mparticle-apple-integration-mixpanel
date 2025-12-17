# Mixpanel SDK Source Code

## Purpose

This directory contains the full source code for Mixpanel's official SDKs. These are the partner SDKs that the mParticle Kit will wrap.

## Directories

### mixpanel-swift/
**Relevance: Critical**

The Swift SDK for iOS, tvOS, macOS, and watchOS. This is the SDK that `mparticle-apple-integration-mixpanel` will wrap and expose through the mParticle Kit interface.

### mixpanel-js/
**Relevance: Low**

The JavaScript SDK for web. Reference only for understanding API naming patterns when comparing with the JS Mixpanel Kit implementation.

## Platform Differences

| Aspect | Swift SDK | JS SDK |
|--------|-----------|--------|
| Initialization | `Mixpanel.initialize()` | `mixpanel.init()` |
| Instance Access | `Mixpanel.mainInstance()` | `mixpanel` (global) |
| Properties Type | `[String: MixpanelType]` | Plain JS object |
| Async Pattern | Completion handlers | Callbacks |
| Automatic Events | `trackAutomaticEvents` param | Not applicable |

## Usage Pattern

The Kit will:
1. Initialize Mixpanel in `start` method
2. Hold a reference or access via `Mixpanel.mainInstance()`
3. Call Mixpanel methods when mParticle events are received
4. Return the Mixpanel instance via `providerKitInstance`

## Key SDK Features to Expose

From mixpanel-swift, the Kit should expose:
- Event tracking (`track`)
- User identification (`identify`, `reset`)
- Super properties (`registerSuperProperties`, `unregisterSuperProperty`)
- People properties (`people.set`, `people.unset`, `people.increment`)
- Revenue tracking (`people.trackCharge`)
- Opt out (`optOutTracking`, `optInTracking`)
