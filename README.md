# mParticle-Mixpanel

[![CocoaPods](https://img.shields.io/cocoapods/v/mParticle-Mixpanel.svg)](https://cocoapods.org/pods/mParticle-Mixpanel)
[![Swift Package Manager](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![License](https://img.shields.io/cocoapods/l/mParticle-Mixpanel.svg)](https://cocoapods.org/pods/mParticle-Mixpanel)

This is the [Mixpanel](https://mixpanel.com) integration for the [mParticle Apple SDK](https://github.com/mParticle/mparticle-apple-sdk).

## Installation

### Swift Package Manager

Add the package dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/mparticle-integrations/mparticle-apple-integration-mixpanel", .upToNextMajor(from: "1.0.0"))
]
```

### CocoaPods

Add the following to your `Podfile`:

```ruby
pod 'mParticle-Mixpanel', '~> 1.0'
```

Then run `pod install`.

## Requirements

- iOS 13.0+ / tvOS 13.0+
- mParticle Apple SDK 8.0+

## Configuration

Configure the Mixpanel integration in the [mParticle dashboard](https://app.mparticle.com):

### Core Settings

| Setting                  | Description                                | Default               |
| ------------------------ | ------------------------------------------ | --------------------- |
| `token`                  | Your Mixpanel project token                | (required)            |
| `baseUrl`                | Mixpanel Target Server endpoint (US or EU) | Mixpanel default (US) |
| `userIdentificationType` | Identity type for Mixpanel user ID         | CustomerId            |
| `useMixpanelPeople`      | Use People API for user attributes         | true                  |

### Session Replay Settings (iOS only)

| Setting                              | Type        | Default | Description                      |
| ------------------------------------ | ----------- | ------- | -------------------------------- |
| `sessionReplayEnabled`               | bool        | false   | Enable Session Replay            |
| `recordSessionsPercent`              | int (0-100) | 100     | Sampling rate for sessions       |
| `autoStartRecording`                 | bool        | true    | Auto-start recording on launch   |
| `wifiOnly`                           | bool        | true    | Upload recordings only on WiFi   |
| `enableMixpanelSessionReplayOniOS26` | bool        | false   | Force enable on iOS 26+          |
| `maskImages`                         | bool        | true    | Mask UIImageView content         |
| `maskText`                           | bool        | true    | Mask UILabel/UITextField content |
| `maskWebViews`                       | bool        | true    | Mask WKWebView content           |
| `maskMaps`                           | bool        | true    | Mask MKMapView content           |

### User Identification Types

- `CustomerId` - Uses mParticle Customer ID
- `MPID` - Uses mParticle ID
- `Other`, `Other2`, `Other3`, `Other4` - Uses custom identity types

## Usage

### Initialize mParticle

```swift
let options = MParticleOptions(key: "YOUR_APP_KEY", secret: "YOUR_APP_SECRET")
MParticle.sharedInstance().start(with: options)
```

### Track Events

Events logged through mParticle are automatically forwarded to Mixpanel:

```swift
let event = MPEvent(name: "Button Clicked", type: .other)
event?.customAttributes = ["button_name": "signup"]
MParticle.sharedInstance().logEvent(event!)
```

### Track Screens

Screen views are forwarded with a "Viewed " prefix:

```swift
MParticle.sharedInstance().logScreen("Home Screen", eventInfo: nil)
// Logged to Mixpanel as: "Viewed Home Screen"
```

### User Attributes

User attributes are forwarded to Mixpanel People (when enabled) or as super properties:

```swift
MParticle.sharedInstance().identity.currentUser?.setUserAttribute("plan_type", value: "premium")
```

### Commerce Events

Purchase events are tracked using Mixpanel's revenue tracking:

```swift
let product = MPProduct(name: "Premium Plan", sku: "PLAN_001", quantity: 1, price: 9.99)
let commerceEvent = MPCommerceEvent(action: .purchase, product: product)
MParticle.sharedInstance().logEvent(commerceEvent!)
```

### Direct SDK Access

Access the Mixpanel SDK directly for advanced features:

```swift
if let mixpanel = MParticle.sharedInstance().kitInstance(forKit: NSNumber(value: 10)) as? MixpanelInstance {
    mixpanel.time(event: "Long Operation")
}
```

## Session Replay (iOS only)

Session Replay records user sessions for playback in the Mixpanel dashboard. Enable it through mParticle configuration settings.

### Features

- **Automatic identity sync**: Session Replay identity is synchronized with mParticle identity changes (login, logout, identify, modify)
- **Privacy compliance**: Recording automatically stops on logout or opt-out
- **Privacy masking**: Configurable masking for images, text, web views, and maps
- **Sampling**: Control what percentage of sessions are recorded

### Direct Session Replay Access

For advanced control, access the Session Replay provider directly:

```swift
#if os(iOS)
import MixpanelSessionReplay

if let kit = MParticle.sharedInstance().kitInstance(forKit: NSNumber(value: 10)) as? MPKitMixpanel,
   let sessionReplay = kit.sessionReplayProviderInstance {
    // Manual control
    sessionReplay.startRecording()
    sessionReplay.stopRecording()
}
#endif
```

## License

Apache License 2.0. See [LICENSE](LICENSE) for details.
