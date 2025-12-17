# Mixpanel JavaScript SDK

## Purpose

This is the official Mixpanel SDK for web/JavaScript. It is provided as a **reference only** for understanding API naming patterns when comparing with the JS Mixpanel Kit.

## Relevance

**Low** - The iOS Kit wraps `mixpanel-swift`, not this SDK. However, this SDK is useful for:
1. Understanding which API names correspond between platforms
2. Verifying that the JS Mixpanel Kit uses standard Mixpanel patterns

## API Comparison (JS vs Swift)

| JS API | Swift API |
|--------|-----------|
| `mixpanel.init(token, config)` | `Mixpanel.initialize(token:...)` |
| `mixpanel.track(event, props)` | `.track(event:properties:)` |
| `mixpanel.identify(id)` | `.identify(distinctId:)` |
| `mixpanel.alias(alias, id)` | `.createAlias(_:distinctId:)` |
| `mixpanel.reset()` | `.reset()` |
| `mixpanel.register(props)` | `.registerSuperProperties(_:)` |
| `mixpanel.register_once(props)` | `.registerSuperPropertiesOnce(_:)` |
| `mixpanel.unregister(prop)` | `.unregisterSuperProperty(_:)` |
| `mixpanel.people.set(props)` | `.people.set(properties:)` |
| `mixpanel.people.set_once(props)` | `.people.setOnce(properties:)` |
| `mixpanel.people.unset(props)` | `.people.unset(properties:)` |
| `mixpanel.people.increment(prop, by)` | `.people.increment(property:by:)` |
| `mixpanel.people.append(props)` | `.people.append(properties:)` |
| `mixpanel.people.union(props)` | `.people.union(properties:)` |
| `mixpanel.people.track_charge(amount)` | `.people.trackCharge(amount:)` |
| `mixpanel.people.clear_charges()` | `.people.clearCharges()` |
| `mixpanel.people.delete_user()` | `.people.deleteUser()` |
| `mixpanel.time_event(event)` | `.time(event:)` |
| `mixpanel.opt_out_tracking()` | `.optOutTracking()` |
| `mixpanel.opt_in_tracking()` | `.optInTracking()` |
| `mixpanel.has_opted_out_tracking()` | `.hasOptedOutTracking()` |

## Directory Structure

The SDK uses a modular structure, but for reference purposes only:
- `src/` - Source files
- `dist/` - Built bundles
- `doc/` - API documentation

## When to Reference

Only consult this SDK when:
1. You need to verify a Mixpanel API pattern
2. You're debugging discrepancies between JS and Swift behavior
3. You need to understand a feature not covered in the JS Mixpanel Kit
