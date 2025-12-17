# mparticle-apple-integration-mixpanel

## Project Requirements Document

---

## 1. Executive Summary

### Project Goal

Create an official mParticle iOS Kit (`mparticle-apple-integration-mixpanel`) that wraps the Mixpanel Swift SDK, enabling mParticle customers to forward analytics data to Mixpanel from iOS, tvOS, macOS, and watchOS applications.

### Scope

This Kit will provide **feature parity** with the existing JavaScript Mixpanel Kit (`mparticle-javascript-integration-mixpanel`), translating mParticle events into Mixpanel API calls while following iOS Kit development best practices.

### Key Deliverables

1. **MPKitMixpanel.swift** - Core Kit implementation conforming to `MPKitProtocol`
2. **mParticle-Mixpanel.podspec** - CocoaPods distribution specification
3. **Package.swift** - Swift Package Manager manifest
4. **Unit Tests** - Comprehensive test coverage for all Kit functionality
5. **Documentation** - README with integration instructions

### Target Platforms

| Platform | Minimum Version |
|----------|-----------------|
| iOS | 12.0+ |
| tvOS | 12.0+ |
| macOS | 10.13+ |
| watchOS | 5.0+ |

---

## 2. Technical Architecture Overview

### Component Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                        Customer iOS App                              │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌────────────────┐    ┌──────────────────┐    ┌─────────────────┐  │
│  │ App Code       │───>│ mParticle SDK    │───>│ MPKitMixpanel   │  │
│  │ (Events,       │    │ (Routing,        │    │ (Transform &    │  │
│  │  Identity,     │    │  Filtering,      │    │  Forward)       │  │
│  │  Attributes)   │    │  Identity)       │    │                 │  │
│  └────────────────┘    └──────────────────┘    └────────┬────────┘  │
│                                                          │          │
│                                                          ▼          │
│                                               ┌─────────────────┐   │
│                                               │ Mixpanel Swift  │   │
│                                               │ SDK             │   │
│                                               └────────┬────────┘   │
│                                                        │            │
└────────────────────────────────────────────────────────┼────────────┘
                                                         │
                                                         ▼
                                               ┌─────────────────┐
                                               │ Mixpanel API    │
                                               │ Servers         │
                                               └─────────────────┘
```

### Kit Architecture

```
mparticle-apple-integration-mixpanel/
├── Sources/
│   └── mParticle-Mixpanel/
│       ├── MPKitMixpanel.swift       # Main Kit class
│       ├── MPKitMixpanel+Events.swift    # Event handling extension
│       ├── MPKitMixpanel+Identity.swift  # Identity handling extension
│       ├── MPKitMixpanel+Commerce.swift  # Commerce handling extension
│       └── Utilities/
│           └── PropertyConverter.swift   # Type conversion utilities
├── Tests/
│   └── mParticle-MixpanelTests/
│       ├── MPKitMixpanelTests.swift
│       ├── EventForwardingTests.swift
│       ├── IdentityTests.swift
│       └── CommerceTests.swift
├── mParticle-Mixpanel.podspec
├── Package.swift
└── README.md
```

### Class Hierarchy

```swift
// Main Kit Class
class MPKitMixpanel: NSObject, MPKitProtocol {
    // Required properties
    var configuration: [AnyHashable: Any]
    var launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    var started: Bool

    // Configuration
    var token: String
    var serverURL: String?
    var userIdentificationType: UserIdentificationType
    var useMixpanelPeople: Bool

    // Mixpanel instance
    var mixpanelInstance: MixpanelInstance?
}

enum UserIdentificationType: String {
    case customerId = "CustomerId"
    case mpid = "MPID"
    case other = "Other"
    case other2 = "Other2"
    case other3 = "Other3"
    case other4 = "Other4"
}
```

---

## 3. Feature Requirements

### 3.1 Core Features (Must Have)

#### 3.1.1 Initialization

| Requirement | Description |
|-------------|-------------|
| FR-001 | Initialize Mixpanel SDK with project token from configuration |
| FR-002 | Support custom server URL (baseUrl) configuration |
| FR-003 | Disable automatic events (Kit handles all event forwarding) |
| FR-004 | Register Kit with mParticle SDK at load time |
| FR-005 | Broadcast `mParticleKitDidBecomeActiveNotification` when started |

#### 3.1.2 Event Tracking

| Requirement | Description |
|-------------|-------------|
| FR-010 | Forward custom events via `routeEvent:` to `Mixpanel.track()` |
| FR-011 | Forward screen views via `logScreen:` to `Mixpanel.track("Viewed X")` |
| FR-012 | Preserve all event attributes/properties during forwarding |
| FR-013 | Handle null/empty event names gracefully |

#### 3.1.3 Identity Management

| Requirement | Description |
|-------------|-------------|
| FR-020 | Support configurable user identification type (CustomerId, MPID, Other, etc.) |
| FR-021 | Call `Mixpanel.identify()` on login/identify events |
| FR-022 | Call `Mixpanel.reset()` on logout events |
| FR-023 | Only identify users with actual identities (not anonymous MPID) |

#### 3.1.4 User Attributes

| Requirement | Description |
|-------------|-------------|
| FR-030 | Support `useMixpanelPeople` configuration toggle |
| FR-031 | When `useMixpanelPeople=true`: Use `people.set()` / `people.unset()` |
| FR-032 | When `useMixpanelPeople=false`: Use `registerSuperProperties()` / `unregisterSuperProperty()` |
| FR-033 | Handle attribute key/value type conversions |

#### 3.1.5 Commerce Events

| Requirement | Description |
|-------------|-------------|
| FR-040 | Forward Purchase events to `people.trackCharge()` |
| FR-041 | Include revenue amount from transaction attributes |
| FR-042 | Include commerce event attributes in charge properties |

### 3.2 Extended Features (Should Have)

#### 3.2.1 Advanced Tracking

| Requirement | Description |
|-------------|-------------|
| FR-050 | Support timed events via `time(event:)` |
| FR-051 | Support Groups API via `setGroup()` |

#### 3.2.2 Privacy & Compliance

| Requirement | Description |
|-------------|-------------|
| FR-060 | Support opt-out tracking via `optOutTracking()` |
| FR-061 | Support opt-in tracking via `optInTracking()` |
| FR-062 | Respect mParticle's consent state |

### 3.3 Kit Infrastructure (Must Have)

| Requirement | Description |
|-------------|-------------|
| FR-070 | Return Mixpanel instance via `providerKitInstance` |
| FR-071 | Return appropriate `MPKitExecStatus` for all operations |
| FR-072 | Handle missing/invalid configuration gracefully |
| FR-073 | Thread-safe operation (main thread calls where required) |

---

## 4. API Mapping

### 4.1 JS Kit → iOS Kit Method Mapping

| JS Kit Method | iOS Kit Method | Mixpanel API |
|---------------|----------------|--------------|
| `initForwarder()` | `didFinishLaunchingWithConfiguration:` | `Mixpanel.initialize()` |
| `processEvent()` | `logBaseEvent:` | (Router) |
| `logEvent()` | `routeEvent:` | `.track()` |
| `logPageView()` | `logScreen:` | `.track("Viewed X")` |
| `logPurchaseEvent()` | `routeCommerceEvent:` | `.people.trackCharge()` |
| `onIdentifyComplete()` | `onIdentifyComplete:request:` | `.identify()` |
| `onLoginComplete()` | `onLoginComplete:request:` | `.identify()` |
| `onLogoutComplete()` | `onLogoutComplete:request:` | `.reset()` |
| `onModifyComplete()` | `onModifyComplete:request:` | `.identify()` |
| `setUserAttribute()` | `onSetUserAttribute:` | `.people.set()` or `.registerSuperProperties()` |
| `removeUserAttribute()` | `onRemoveUserAttribute:` | `.people.unset()` or `.unregisterSuperProperty()` |

### 4.2 Configuration Mapping

| JS Setting | iOS Configuration Key | Type | Default |
|------------|----------------------|------|---------|
| `token` | `token` | String | (required) |
| `baseUrl` | `serverURL` | String | nil (uses default) |
| `userIdentificationType` | `userIdentificationType` | String | "CustomerId" |
| `useMixpanelPeople` | `useMixpanelPeople` | Bool | true |

### 4.3 Identity Type Mapping

| mParticle Identity | Swift Enum Case | Notes |
|-------------------|-----------------|-------|
| `MPUserIdentityCustomerId` | `.customerId` | Preferred for Mixpanel |
| MPID | `.mpid` | mParticle's internal ID |
| `MPUserIdentityOther` | `.other` | Custom identity |
| `MPUserIdentityOther2` | `.other2` | Custom identity |
| `MPUserIdentityOther3` | `.other3` | Custom identity |
| `MPUserIdentityOther4` | `.other4` | Custom identity |

### 4.4 Event Type Mapping

| mParticle Event | iOS Type | Mixpanel Handling |
|-----------------|----------|-------------------|
| Custom Event | `MPEvent` | `track(event:properties:)` |
| Screen View | `MPEvent` (via `logScreen:`) | `track(event: "Viewed \(name)")` |
| Commerce - Purchase | `MPCommerceEvent` | `people.trackCharge()` |
| Commerce - Other | `MPCommerceEvent` | Track as custom event |

---

## 5. Implementation Approach

### Phase 1: Project Setup

**Objective:** Create project structure and build configuration

**Tasks:**
1. Create Xcode project with SPM structure
2. Configure CocoaPods podspec
3. Set up dependencies (mParticle-Apple-SDK, Mixpanel-swift)
4. Create base `MPKitMixpanel` class skeleton
5. Set up unit test target

**Deliverables:**
- Compilable project skeleton
- Podspec and Package.swift
- CI configuration

### Phase 2: Core Kit Implementation

**Objective:** Implement basic Kit lifecycle and event forwarding

**Tasks:**
1. Implement Kit registration (`+load`, `kitCode`)
2. Implement configuration handling (`didFinishLaunchingWithConfiguration:`)
3. Implement `start` method with Mixpanel initialization
4. Implement `routeEvent:` for custom events
5. Implement `logScreen:` for screen views

**Deliverables:**
- Working Kit that forwards events to Mixpanel
- Unit tests for event forwarding

### Phase 3: Identity Implementation

**Objective:** Implement user identity handling

**Tasks:**
1. Implement `onIdentifyComplete:request:`
2. Implement `onLoginComplete:request:`
3. Implement `onLogoutComplete:request:`
4. Implement `onModifyComplete:request:`
5. Implement configurable identity type mapping

**Deliverables:**
- Identity forwarding matching JS Kit behavior
- Unit tests for identity scenarios

### Phase 4: User Attributes & Commerce

**Objective:** Complete feature parity with JS Kit

**Tasks:**
1. Implement `onSetUserAttribute:`
2. Implement `onRemoveUserAttribute:`
3. Implement user attribute mode toggle (People vs Super Properties)
4. Implement `routeCommerceEvent:` for purchases
5. Implement `providerKitInstance`

**Deliverables:**
- Complete feature implementation
- Full unit test coverage

### Phase 5: Polish & Documentation

**Objective:** Production-ready release

**Tasks:**
1. Error handling and edge cases
2. Thread safety verification
3. README documentation
4. Integration testing with sample app
5. Version 1.0.0 release

**Deliverables:**
- Production-ready Kit
- Comprehensive documentation
- Sample integration app

---

## 6. Dependencies

### Runtime Dependencies

| Dependency | Version | Purpose |
|------------|---------|---------|
| mParticle-Apple-SDK | ~> 8.0 | mParticle SDK integration |
| Mixpanel-swift | ~> 4.0 | Mixpanel analytics SDK |

### Development Dependencies

| Dependency | Version | Purpose |
|------------|---------|---------|
| XCTest | (built-in) | Unit testing |
| OCMock (optional) | ~> 3.9 | Mocking for Obj-C tests |

### Platform Requirements

| Platform | Minimum Deployment Target |
|----------|--------------------------|
| iOS | 12.0 |
| tvOS | 12.0 |
| macOS | 10.13 |
| watchOS | 5.0 |

### Build Requirements

| Tool | Version |
|------|---------|
| Xcode | 14.0+ |
| Swift | 5.7+ |
| CocoaPods | 1.10+ |

---

## 7. Testing Strategy

### 7.1 Unit Tests

| Test Category | Coverage Target | Description |
|---------------|-----------------|-------------|
| Initialization | 100% | Kit registration, configuration parsing, start |
| Event Forwarding | 100% | Custom events, screen views, attributes |
| Identity | 100% | Login, logout, identify, modify |
| User Attributes | 100% | Set, remove, People vs Super modes |
| Commerce | 100% | Purchase events, revenue tracking |
| Edge Cases | 90%+ | Null values, malformed data, errors |

### 7.2 Test Scenarios

**Initialization Tests:**
- Kit starts with valid configuration
- Kit fails gracefully with missing token
- Kit uses custom server URL when provided
- Kit uses default server URL when not provided

**Event Forwarding Tests:**
- Custom event forwarded with all attributes
- Screen view prefixed with "Viewed "
- Empty event name handled gracefully
- Null attributes don't crash

**Identity Tests:**
- Login with CustomerId calls identify
- Login with MPID calls identify (when configured)
- Logout calls reset
- Anonymous user not identified

**User Attribute Tests:**
- Set attribute uses people.set (when useMixpanelPeople=true)
- Set attribute uses registerSuperProperties (when useMixpanelPeople=false)
- Remove attribute uses appropriate API

**Commerce Tests:**
- Purchase event calls trackCharge with correct amount
- Non-purchase events handled appropriately
- Commerce attributes included in properties

### 7.3 Integration Testing

**Manual Testing Checklist:**
- [ ] Install Kit via CocoaPods in sample app
- [ ] Install Kit via SPM in sample app
- [ ] Verify events appear in Mixpanel dashboard
- [ ] Verify user profiles in Mixpanel People
- [ ] Verify identity linking works correctly
- [ ] Verify revenue tracking in Mixpanel Revenue

---

## 8. Success Criteria

### 8.1 Functional Criteria

| Criterion | Validation Method |
|-----------|-------------------|
| All FR-0xx requirements implemented | Unit test coverage |
| Feature parity with JS Kit | Side-by-side feature comparison |
| Events appear in Mixpanel dashboard | Integration test |
| Identity links correctly | Mixpanel People verification |
| Revenue tracked correctly | Mixpanel Revenue report |

### 8.2 Quality Criteria

| Criterion | Target |
|-----------|--------|
| Unit test coverage | > 90% |
| Zero critical bugs | Automated + manual testing |
| No memory leaks | Instruments profiling |
| Thread-safe | Concurrency testing |

### 8.3 Distribution Criteria

| Criterion | Validation Method |
|-----------|-------------------|
| Publishes to CocoaPods | `pod trunk push` |
| Works with SPM | `swift package resolve` |
| README complete | Documentation review |
| Sample app works | Manual verification |

### 8.4 Definition of Done

The project is complete when:

1. All requirements (FR-001 through FR-073) are implemented
2. Unit test coverage exceeds 90%
3. Integration tests pass with Mixpanel dashboard
4. Kit is published to CocoaPods trunk
5. Kit is available via Swift Package Manager
6. README includes complete integration instructions
7. mParticle has reviewed and approved the implementation

---

## Appendix A: Kit Code Assignment

The Kit requires an official Kit Code from mParticle. Based on the JavaScript Kit:

- **Mixpanel Kit Code:** 178 (to be confirmed with mParticle)

For development, a sideloaded kit approach can be used until official Kit Code is assigned.

---

## Appendix B: Reference Materials

| Resource | Location |
|----------|----------|
| mParticle iOS Kit Docs | `mparticle-kit-context/docs/` |
| iOS Example Kit | `mparticle-kit-context/example-kits/mparticle-apple-integration-example/` |
| JS Mixpanel Kit | `mparticle-kit-context/example-kits/mparticle-javascript-integration-mixpanel/` |
| Mixpanel Swift SDK | `mparticle-kit-context/mixpanel-sdks/mixpanel-swift/` |
| Architecture Doc | `ARCHITECTURE.md` |

---

## Appendix C: Risks and Mitigations

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Mixpanel API changes | Low | High | Pin SDK version, monitor releases |
| mParticle SDK breaking changes | Low | High | Pin SDK version, test with new releases |
| Kit Code assignment delays | Medium | Low | Use sideloaded kit for development |
| Thread safety issues | Medium | High | Thorough concurrency testing |
| Type conversion edge cases | Medium | Medium | Comprehensive unit tests |

---

*Document Version: 1.0*
*Created: December 17, 2024*
*Project: mparticle-apple-integration-mixpanel*
