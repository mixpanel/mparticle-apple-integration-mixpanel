# Copilot Instructions for mParticle-Mixpanel

## Repository Overview

This repository implements the **Mixpanel integration kit** for the mParticle Apple SDK. It enables mParticle users to forward analytics events, user attributes, and commerce data to Mixpanel through a standardized integration.

**Repository Type**: Swift Package / CocoaPods library  
**Languages**: Swift (primary), Objective-C (kit registration wrapper)  
**Platforms**: iOS 12.0+, tvOS 12.0+  
**Size**: Small (~11 Swift files, ~600 lines of code)  
**Build System**: Swift Package Manager (primary), CocoaPods (supported)

## Critical Build Requirements

### ⚠️ Platform Requirement
**This project MUST be built on macOS.** It depends on Apple platform frameworks (iOS/tvOS) that cannot be built on Linux. The CI workflow runs on `macos-latest`.

### Swift Version
- **Minimum**: Swift 5.7
- **Tested**: Swift 5.7, 5.8, 5.9
- CI uses the Swift version bundled with macOS-latest

### Dependencies
- **mParticle-Apple-SDK** (~> 8.0): The main mParticle SDK
- **Mixpanel-swift** (~> 4.0): The official Mixpanel analytics SDK

Note: mParticle-Apple-SDK uses binary xcframework artifacts that are only available on macOS/with network access.

## Build and Test Commands

### Building the Project

**Always run on macOS**. The build will fail on Linux with network errors when trying to download binary xcframeworks.

```bash
swift build -v
```

**Expected behavior**: 
- Downloads dependencies (mParticle-Apple-SDK, Mixpanel-swift)
- Compiles Swift and Objective-C sources
- Takes ~30-60 seconds on first build (due to dependency resolution)
- Subsequent builds are faster (~10-20 seconds)

**Common issues**:
- If you see "Could not resolve host: static.mparticle.com" - you're on Linux, not macOS
- Network issues may prevent binary xcframework downloads

### Running Tests

```bash
swift test -v
```

**Test structure**: 8 test files with ~600 lines of test code covering:
- Configuration and initialization
- Event forwarding (events, screens, commerce)
- User identity handling
- User attributes
- Kit registration

**Expected behavior**: All tests should pass. Tests run quickly (~5-10 seconds).

### Clean Build

If you encounter build issues, clean the build artifacts:

```bash
rm -rf .build/
swift build -v
```

## Project Structure

### Source Files

```
Sources/
├── mParticle-Mixpanel/          # Main Swift implementation
│   ├── MPKitMixpanel.swift      # Core kit implementation (386 lines)
│   ├── MPKitMixpanel+Version.swift  # Version tracking
│   └── UserIdentificationType.swift # Identity type enum
└── mParticle-MixpanelObjC/      # Objective-C wrapper for auto-registration
    ├── MPKitMixpanelObjC.h      # Header
    ├── MPKitMixpanelObjC.m      # Implementation with +load method
    └── include/                  # Public headers directory
```

**Why two targets?**
- `mParticle-Mixpanel`: Swift code implementing MPKitProtocol
- `mParticle-MixpanelObjC`: Objective-C wrapper that uses `+load` method to auto-register the kit with mParticle SDK at runtime

### Test Files

```
Tests/mParticle-MixpanelTests/
├── MPKitMixpanelTests.swift       # Placeholder test
├── InitializationTests.swift      # Kit initialization and configuration
├── ConfigurationTests.swift       # Configuration parsing
├── EventForwardingTests.swift     # Event routing tests
├── CommerceTests.swift            # Commerce event tests
├── IdentityTests.swift            # User identity tests
├── UserAttributeTests.swift       # User attribute forwarding
└── KitRegistrationTests.swift     # Kit registration validation
```

### Configuration Files

- **Package.swift**: Swift Package Manager configuration (swift-tools-version: 5.7)
- **mParticle-Mixpanel.podspec**: CocoaPods specification
- **.github/workflows/swift.yml**: CI/CD workflow (build + test on macOS-latest)
- **.gitignore**: Excludes build artifacts (.build/, .swiftpm/, xcuserdata/, etc.)

## Key Architecture Concepts

### Kit Protocol Implementation

The `MPKitMixpanel` class implements `MPKitProtocol` from mParticle-Apple-SDK. Key methods:

1. **Lifecycle**: `didFinishLaunching(withConfiguration:)` - Initializes Mixpanel with token
2. **Events**: `logEvent()`, `logScreen()`, `logCommerceEvent()` - Forward analytics
3. **Identity**: `onIdentifyComplete()`, `onLoginComplete()`, `onLogoutComplete()` - Handle user identity
4. **Attributes**: `onSetUserAttribute()`, `onRemoveUserAttribute()` - Sync user properties

### Kit Code
Every mParticle kit has a unique identifier. Mixpanel's kit code is **10** (defined in `MPKitMixpanel.kitCode()` in `MPKitMixpanel.swift` line 36).

### Configuration Keys
- `token`: Mixpanel project token (required)
- `serverURL`: Custom Mixpanel API endpoint (optional)
- `userIdentificationType`: Maps mParticle identity to Mixpanel distinct_id (CustomerId, MPID, Other, etc.)
- `useMixpanelPeople`: Enable Mixpanel People API for user attributes (default: true)

## Continuous Integration

### GitHub Actions Workflow

**File**: `.github/workflows/swift.yml`

**Triggers**: 
- Push to `main` branch
- Pull requests to `main` branch

**Jobs**:
1. **Build**: Runs `swift build -v` on macOS-latest
2. **Test**: Runs `swift test -v` on macOS-latest

**Expected runtime**: ~2-3 minutes total

**Common failures**:
- Build failures: Usually dependency resolution or network issues
- Test failures: Check if changes broke kit protocol implementation

## Making Code Changes

### Adding New Features

1. **Modify `MPKitMixpanel.swift`**: Add new MPKitProtocol methods or enhance existing ones
2. **Add tests**: Create or extend test files in `Tests/mParticle-MixpanelTests/`
3. **Update version**: Modify version string in `MPKitMixpanel+Version.swift` and `mParticle-Mixpanel.podspec`
4. **Build and test**: Run `swift build -v && swift test -v`

### Code Style

- **No linter configured**: Follow existing Swift conventions in the codebase
- **Comments**: Minimal - only for complex logic. Use `// MARK:` for section organization
- **Naming**: Follow Swift API Design Guidelines
- **Error handling**: Return appropriate `MPKitExecStatus` (success, fail, requirementsNotMet)

### Testing Patterns

All test classes:
- Import `@testable import mParticle_Mixpanel`
- Create kit instance with `MPKitMixpanel()`
- Initialize with test config: `["token": "test-token"]`
- Use `XCTAssert` for validations
- Follow pattern: `test<Method>_<Scenario>_<ExpectedResult>`

## Important Implementation Details

### Objective-C/Swift Interop

The ObjC wrapper (`MPKitMixpanelObjC.m`) is required for automatic kit registration. The `+load` method registers the kit class name with mParticle before app initialization.

### Screen View Prefix

Screen views are automatically prefixed with "Viewed " when forwarded to Mixpanel (e.g., "Home Screen" becomes "Viewed Home Screen").

### People API vs Super Properties

When `useMixpanelPeople` is true, user attributes are set via Mixpanel People API. Otherwise, they're registered as super properties.

### Identity Handling

On logout, the kit calls `mixpanel.reset()` to clear the Mixpanel identity state.

## Validation Steps

Before submitting changes:

1. **Build**: `swift build -v` (must succeed on macOS)
2. **Test**: `swift test -v` (all tests must pass)
3. **Git status**: Ensure no unwanted files (build artifacts) are staged
4. **CI**: GitHub Actions will run the same build + test on macOS-latest

## Trust These Instructions

These instructions are comprehensive and verified. Only perform additional searches if:
- Information is missing for your specific task
- Instructions contradict current repository state
- You encounter errors not documented here

When in doubt, build and test on macOS with the commands provided above.
