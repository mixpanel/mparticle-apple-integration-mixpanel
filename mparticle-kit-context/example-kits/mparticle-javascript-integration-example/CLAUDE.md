# JavaScript Example Kit

## Purpose

This is the official mParticle JavaScript Kit template. It provides structural reference for understanding the JS Kit pattern, but is **less relevant** for iOS development.

## Relevance for iOS Kit

**Low** - Use primarily to understand:
- Handler patterns (if comparing with JS Mixpanel Kit)
- Event type constants
- The general mParticle Kit philosophy

## Key Concepts (JS-specific)

### Handler Modules
JS Kits use separate handler files:
- `initialization.js` - SDK loading and initialization
- `event-handler.js` - Page events and custom events
- `commerce-handler.js` - eCommerce events
- `identity-handler.js` - User identity changes
- `session-handler.js` - Session management
- `user-attribute-handler.js` - User attribute changes

### Event Types
```javascript
MessageType = {
    SessionStart: 1,
    SessionEnd: 2,
    PageView: 3,
    PageEvent: 4,
    CrashReport: 5,
    OptOut: 6,
    Commerce: 16
}
```

These correspond to mParticle iOS event types but with different structure.

## iOS Equivalents

| JS Handler | iOS Protocol Method |
|------------|---------------------|
| `initForwarder()` | `didFinishLaunchingWithConfiguration:` |
| `processEvent()` | `logBaseEvent:` |
| `onLoginComplete()` | `onLoginComplete:request:` |
| `setUserAttribute()` | `onSetUserAttribute:` |

## When to Reference

Only reference this directory when:
1. Understanding how JS handlers map to iOS protocol methods
2. Comparing structure between JS and iOS kits
3. Validating that iOS implementation covers same scenarios
