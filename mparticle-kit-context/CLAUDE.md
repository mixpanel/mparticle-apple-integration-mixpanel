# mParticle Kit Context Directory

## Purpose

This directory contains all reference materials for implementing `mparticle-apple-integration-mixpanel`, an iOS/tvOS Kit that wraps the Mixpanel Swift SDK for the mParticle platform.

## Directory Structure

```
mparticle-kit-context/
├── docs/                 # Official mParticle Kit documentation
├── example-kits/         # Reference implementations
│   ├── mparticle-apple-integration-example/     # iOS Kit template
│   ├── mparticle-javascript-integration-example/ # JS Kit template
│   └── mparticle-javascript-integration-mixpanel/ # JS Mixpanel Kit (primary reference)
└── mixpanel-sdks/        # Mixpanel SDK source code
    ├── mixpanel-swift/   # iOS SDK to wrap
    └── mixpanel-js/      # Web SDK (for API comparison)
```

## Key Concepts

### What is an mParticle Kit?

An mParticle Kit is a client-side integration that wraps a partner SDK (like Mixpanel) and receives events from the mParticle SDK. The Kit:

1. Receives mParticle events through protocol methods
2. Transforms event data to the partner SDK format
3. Forwards events to the partner SDK

### Implementation Strategy

1. **Use the JS Mixpanel Kit as the primary reference** - It defines which Mixpanel APIs should be exposed and how mParticle events map to Mixpanel calls
2. **Use the iOS Example Kit as the structural template** - It provides the correct iOS Kit architecture and protocol implementation
3. **Reference mixpanel-swift for API understanding** - Understand the Swift SDK methods that correspond to JS SDK methods

## Cross-References

- `docs/ios-kit-integration.md` - Start here for iOS Kit architecture
- `example-kits/mparticle-javascript-integration-mixpanel/src/MixpanelEventForwarder.js` - Primary feature reference
- `example-kits/mparticle-apple-integration-example/mParticle-Example/MPKitExample.m` - iOS implementation pattern
- `mixpanel-sdks/mixpanel-swift/Sources/MixpanelInstance.swift` - Core Swift API

## Implementation Notes

The iOS Kit should provide feature parity with the JS Mixpanel Kit:

| JS Feature | iOS Equivalent |
|------------|----------------|
| `mixpanel.track()` | `Mixpanel.mainInstance().track()` |
| `mixpanel.identify()` | `Mixpanel.mainInstance().identify()` |
| `mixpanel.reset()` | `Mixpanel.mainInstance().reset()` |
| `mixpanel.register()` | `Mixpanel.mainInstance().registerSuperProperties()` |
| `mixpanel.people.set()` | `Mixpanel.mainInstance().people.set()` |
| `mixpanel.people.track_charge()` | `Mixpanel.mainInstance().people.trackCharge()` |
