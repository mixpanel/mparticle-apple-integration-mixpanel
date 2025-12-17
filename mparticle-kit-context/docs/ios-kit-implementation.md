# iOS | Kits

Although the majority of mParticle event integrations are entirely server-side, the mParticle SDK *does* do some client-side data forwarding. The mParticle SDK works with latest versions of these kits, but just as with other integrations, you are not required to write any client-side code to leverage them.

mParticle supports several kinds of client-side kits:

-   [mParticle-hosted kits](https://github.com/mparticle-integrations) that mParticle has developed and fully supports.

-   Partner-hosted kits that have been tested and are fully supported by mParticle:
    
    -   [CleverTap](https://github.com/CleverTap/mparticle-web-integration-clevertap)
    -   [Singular](https://github.com/singular-labs/mparticle-javascript-integration-singular)
    -   [Branch](https://github.com/BranchMetrics/mparticle-javascript-integration-branch)
-   Sideloaded kits, also called custom kits, that have not been tested and are not support by mParticle. You are responsible for any sideloaded kit that you write yourself or include from a third-party source. This responsibility includes the correct handling and protection of user profiles and identities both within your own system as well as any third-party service you may forward that data to. Be especially cautious with sideloaded kits you may find from third-party repositories. They will potentially receive all events that you log via the mParticle SDK, so you are responsible for ensuring that they handle that data correctly and safely.

Refer to the [iOS](https://github.com/mParticle/mParticle-apple-SDK) SDK GitHub repository for configuring mParticle-hosted kits with the mParticle SDK into your app.

### [](https://docs.mparticle.com/developers/client-sdks/ios/kits/#making-direct-calls-to-kits)Making direct calls to Kits

If you need to access or use a kit method or functionality not covered by the mParticle SDK, you can obtain the respective internal instance by calling the `kitInstance` method, passing an enum with the instance you are interested. The method will return the instance in question, or nil/null if the kit is not active.

For the cases where a kit is implemented with class methods, you can call those class methods directly.

Objective-CSwift

```
#import <AppboyKit.h>

- (void)refreshFeed {
    Appboy *appboy = [[MParticle sharedInstance] kitInstance:MPKitInstanceAppboy];
    if (appboy) {
        [appboy requestFeedRefresh];
    }
}
```

```
import mParticle_Appboy

func refreshFeed() {
    guard let appboy = MParticle.sharedInstance().kitInstance(MPKitAppboy.kitCode()) as? Braze else {
        return
    }
    appboy.newsFeed.requestRefresh()
}
```

The mParticle SDK only instantiates kits that are configured for your app. Since services can be turned on and off dynamically, if you need to access a kit API directly, you must make sure that the given service is currently active.

You can also verify at any given moment if a kit is active and enabled to be used in your app.

Objective-CSwift

```
if ([[MParticle sharedInstance] isKitActive:@(MPKitInstanceAppboy)]) {
    // Do something
}
```

```
if MParticle.sharedInstance().isKitActive(MPKitAppboy.kitCode()) {
    // Do something
}
```

### [](https://docs.mparticle.com/developers/client-sdks/ios/kits/#kit-availability-and-unavailability-notifications)Kit Availability and Unavailability Notifications

The mParticle SDK also allows you to listen for notifications asynchronously, avoiding the need to repeatedly check if a kit is active or inactive.

Objective-CSwift

```
- (void)awakeFromNib {
    [super awakeFromNib];

    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(handleKitDidBecomeActive:)
                               name:mParticleKitDidBecomeActiveNotification
                             object:nil];
}

- (void)handleKitDidBecomeActive:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSNumber *kitNumber = userInfo[mParticleKitInstanceKey];
    MPKitInstance kitInstance = (MPKitInstance)[kitNumber integerValue];

    if (kitInstance == MPKitInstanceAppboy) {
        NSLog(@"Appboy is available for use.");
    }
}
```

```
override func viewDidLoad() {
    super.viewDidLoad()

    NotificationCenter.default.addObserver(self,
                                           selector: #selector(handleKitDidBecomeActive(_:)),
                                           name: NSNotification.Name.mParticleKitDidBecomeActive,
                                           object: nil)
}

@objc private func handleKitDidBecomeActive(_ notification: Notification) {
    guard let info = notification.userInfo,
            let kitNumber = info[mParticleKitInstanceKey] as? NSNumber,
            let kitInstance = MPKitInstance(rawValue: UInt(kitNumber.intValue))
    else {
        return
    }

    if kitInstance == .appboy {
        print("Appboy is available for use.")
    }
}
```

## [](https://docs.mparticle.com/developers/client-sdks/ios/kits/#deep-linking)Deep Linking

Several integrations support the creation and attribution of deep links to install and open an app. A deep link will typically contain some additional information to be used when the user ultimately opens your application, so that you can properly route the user to the appropriate content, or otherwise customize their experience.

As at version 7, the mParticle SDKs offer an integration-agnostic Attribution Listener API that lets you query your integrations at runtime to determine if the given user arrived by way of a deep link.

The following integrations support deep linking:

-   [AppsFlyer](https://docs.mparticle.com/integrations/appsflyer/event/)

-   [Branch](https://docs.mparticle.com/integrations/branch-metrics/event/)
-   [Button](https://docs.mparticle.com/integrations/button/event/)

-   [Iterable](https://docs.mparticle.com/integrations/iterable/event/) (note the Iterable Kit uses its own deep-linking API)

Objective-CSwift

```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    MParticleOptions *options = [MParticleOptions optionsWithKey:@"<<Your app key>>" secret:@"<<Your app secret>>"];
    options.onAttributionComplete = ^void (MPAttributionResult *_Nullable attributionResult, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Attribution fetching for kitCode=%@ failed with error=%@", error.userInfo[mParticleKitInstanceKey], error);
            return;
        }

        NSLog(@"Attribution fetching for kitCode=%@ completed with linkInfo: %@", attributionResult.kitCode, attributionResult.linkInfo);

    };
    [[MParticle sharedInstance] startWithOptions:options];

    return YES;
}
```

```
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    let options = MParticleOptions(key: "<<Your app key>>", secret: "<<Your app secret>>")
    
    options.onAttributionComplete = { attributionResult, error in
        if let error = error as NSError? {
            if let kitCode = error.userInfo[mParticleKitInstanceKey] {
                print("Attribution fetching for kitCode=\(kitCode) failed with error=\(error)")
            } else {
                print("Attribution fetching failed with error=\(error)")
            }
            return
        }
        
        if let result = attributionResult {
            print("Attribution fetching for kitCode=\(result.kitCode) completed with linkInfo: \(result.linkInfo)")
        }
    }
    
    MParticle.sharedInstance().start(with: options)
    
    return true
}
```

## [](https://docs.mparticle.com/developers/client-sdks/ios/kits/#determining-which-partner-sdk-version-is-being-used-by-a-kit)Determining Which Partner SDK Version is Being Used By a Kit

The types of questions most users have about kits are:

-   What version of the partner SDK do you “support”?

-   Which version of a partner’s SDK does a given app/SDK version “use”?

These are two different questions. mParticle defines “support” as - if you can build an app/site with the mParticle SDK and the app compiles, it’s supported.

Therefore, we do not manually test every single version of every single kit.

We only verify that they compile. If the partner breaks their SDK, or our integration with it, it’s possible that we will not know it.

If a partner breaks their SDK/our integration, it typically means they’ve also broken anyone who is directly integrating.

### [](https://docs.mparticle.com/developers/client-sdks/ios/kits/#find-the-kit-source-code)Find the Kit Source Code

For the Apple SDK, we push version tags of each kit. So every time we release the Apple SDK version x.y.z:

1.  We release Apple SDK version x.y.z
2.  We also release ALL kits as version x.y.z - even if that kit’s actual code didn’t change. The idea here is that we want to encourage customers to always use the same versions of all mParticle dependencies, so we push them all every time.

Depending on how customers configure their builds (Cocoapods, Carthage, manual, and variations within each), they could end up mixing different versions of kits - so watch out for that.

However, in the vast majority of cases - if a customer is on x.y.z of the core, they are likely/hopefully on x.y.z of each kit.

Given version x.y.z of a kit, to find the partner SDK version supported, do the following:

1.  Navigate to the mParticle Integrations Github org
2.  Find the repository of the partner. We use a naming convention - all Apple SDK kits are named mparticle-apple-integration-.
3.  Using the dropdown at the top-left of the repository, select the “Tags” tab and then click on the tag version x.y.z that you are checking.
4.  Determine the package manager - we generally align the SDK version supported between Carthage and Cocoapods, but it’s worth verifying individually:

-   If the customer is using Cocoapods, look at the .podspec file

-   If the customer is using Carthage, look at the Cartfile. Some kits do not support Carthage so you will not see a Cartfile

### [](https://docs.mparticle.com/developers/client-sdks/ios/kits/#determine-the-version)Determine the version

#### [](https://docs.mparticle.com/developers/client-sdks/ios/kits/#cocoapods)Cocoapods

Look for the s.ios.dependency line towards the bottom of the file (example). **Generally, We depend on the latest minor version of a kit.** So the customer can choose which version of the SDK will be used:

-   ’~> 0.1.2’ Version 0.1.2 and the versions up to 0.2, not including 0.2 and higher

-   ’~> 0.1’ Version 0.1 and the versions up to 1.0, not including 1.0 and higher
-   ’~> 0’ Version 0 and higher, this is basically the same as not having it.

[Read more about Cocoapod versions here](https://guides.cocoapods.org/using/the-podfile.html#specifying-pod-versions).

In the linked example above, it shows that our SDK, version 7.10.0, supports version `~> 10.1` of the Airship SDK. Per the above rules this means we “support” version 10.1 and later up to but not including 11.0.

#### [](https://docs.mparticle.com/developers/client-sdks/ios/kits/#carthage)Carthage

Cartfiles are generally very short and easy to read. Look for the partner’s SDK version [see this example](https://github.com/mparticle-integrations/mparticle-apple-integration-radar/blob/7.10.0/Cartfile#L1). Similar to Cocoapods, we will typically pull in the latest minor version. There are some minor differences that you can [read about here](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#version-requirement).

In the linked example above, it shows that our SDK, version 7.10.0, supports version `~> 2.1` of the Radar SDK. This means we “support” version 2.1 and later up to but not including 3.0.

## [](https://docs.mparticle.com/developers/client-sdks/ios/kits/#sideloaded-kits-custom-kits)Sideloaded Kits (Custom kits)

Kits are generally added and configured via the mParticle UI settings. When initializing the app, the mParticle SDK receives the configuration settings from our servers and initializes each kit. When you send events to the mParticle Apple SDK, they are routed to each kit and mapped to a partner SDK method, ultimately arriving in our partners’ dashboards for your analysis. The kits in our UI are either built by mParticle or by partners. When partners build kits, we require careful coordination and updates to our database in order for their kits to work properly within our ecosystem.

However, there may be cases where you’d like to build a custom kit, whether to debug or to quickly send data to a partner SDK for which we do not have an official kit. We support the ability to build your own kit which can receive events without needing any configuration in our UI or database. We call these sideloaded kits. When sideloaded kits are included in your app, they remove the need for settings from our server because you configure the kit yourself and then include it using a public API we provide.

### [](https://docs.mparticle.com/developers/client-sdks/ios/kits/#important-safety-warning)Important Safety Warning

Remember that while mParticle fully supports all official kits located in the [“mparticle-integrations” GitHub organization](https://github.com/mParticle-integrations) as well as official kits created by our partners, you are responsible for any sideloaded kit you write yourself or include from a third-party source. This responsibility includes the correct handling and protection of user profiles and identities both within your own system as well as any third-party service you may forward that data to.

Be especially cautious with sideloaded kits you may find from third-party repositories. They will potentially receive all events that you log via the mParticle SDK, so you are responsible for ensuring that they handle that data correctly and safely.

### [](https://docs.mparticle.com/developers/client-sdks/ios/kits/#critical-limitations)Critical Limitations

Keep in mind that sideloaded kits are completely client-side, so things like data filtering are configured client-side and these options will not be available in the mParticle dashboard. This also means that event forwarding and filtering metrics from sideloaded kits will not be included in the metrics displayed in the mParticle dashboard as they would for official kits.

Our official support channels will be unable to help with issues you may have with your sideloaded kit such as data unavailable downstream, crashes, or unsupported functionality. mParticle support will only be able to help in cases where there is an issue with the mParticle SDK sideloaded kit feature in general.

### [](https://docs.mparticle.com/developers/client-sdks/ios/kits/#developing-a-sideloaded-kit)Developing a Sideloaded Kit

On iOS/tvOS a sideloaded kit is essentially just a class that implements the `MPKitProtocol` protocol. A simple example written in Swift can be found [here](https://github.com/mParticle/mparticle-apple-sample-apps/blob/main/sideloaded-kit-samples/mp-sideloaded-kit-example/src/ConsoleLoggingKit.swift) and the `MPKitProtocol` definition can be found [here](https://github.com/mParticle/mparticle-apple-sdk/blob/main/mParticle-Apple-SDK/Include/MPKitProtocol.h).

There are a few things to keep in mind when developing your kit:

1.  The class method `kitCode` must be implemented as it is marked as required in the `MPKitProtocol`, however is only used for official mParticle kits. It is unused for sideloaded kits and can return any number, though `-1` is recommended for clarity.
2.  Though it is marked optional in the `MPKitProtocol`, Sideloaded kits **must** implement the `sideloadedKitCode` property. In sideloaded kits, this property is used in place of the `kitCode` method. If using Swift, it can be initialized to any value as it will be overwritten by the SDK on initialization, though `0` is recommended for clarity. Make sure not to write to this property later as the value is used internally to forward messages to the kit.

### [](https://docs.mparticle.com/developers/client-sdks/ios/kits/#including-the-sideloaded-kit-and-adding-filters)Including the Sideloaded Kit and Adding Filters

The sideloaded kit can be included directly in your application’s source code, or can be included as a framework using your favorite package manager such as CocoaPods or SPM.

To register the sideloaded kit, all that’s needed is to create an instance and pass it to the `sideloadedKits` property of the `MParticleOptions` object:

Objective-CSwift

```
MParticleOptions *options = [MParticleOptions optionsWithKey:key secret:secret];
SideloadedKit *kit = [[SideloadedKit alloc] init];
options.sideloadedKits = @[kit];
[MParticle.sharedInstance startWithOptions:options];
```

```
let options = MParticleOptions(key: key, secret: secret)
let kit = SideloadedKit()
options.sideloadedKits = [kit]
MParticle.sharedInstance().start(with: options)
```

Note that you may use multiple instances of the same sideloaded kit class, perhaps initialized with different parameters. Each sideloaded kit does not need to be a unique class, only a unique instance.

To add filters to a sideloaded kit you must call the corresponding methods on the `SideloadedKit` instance.

Each method allows you to add a different type of filter and each `SideLoadedKit` will accept any number or combination of filters.

Objective-CSwift

```
MParticleOptions *options = [MParticleOptions optionsWithKey:key secret:secret];
SideloadedKit *kit = [[SideloadedKit alloc] init];
[kit addEventTypeFilterWithEventType:MPEventTypeNavigation];
options.sideloadedKits = @[kit];
[MParticle.sharedInstance startWithOptions:options];
```

```
let options = MParticleOptions(key: key, secret: secret)
let kit = SideloadedKit()
kit.addEventTypeFilterWithEventType(MPEventTypeNavigation)
options.sideloadedKits = [kit]
MParticle.sharedInstance().start(with: options)
```

---
Source: [iOS | Kits](https://docs.mparticle.com/developers/client-sdks/ios/kits/)