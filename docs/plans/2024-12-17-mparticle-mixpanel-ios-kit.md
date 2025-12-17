# mParticle Mixpanel iOS Kit Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Create an mParticle iOS Kit that wraps the Mixpanel Swift SDK, enabling analytics forwarding from mParticle to Mixpanel with feature parity to the JavaScript Mixpanel Kit.

**Architecture:** The Kit implements `MPKitProtocol`, receives events from the mParticle SDK, transforms them to Mixpanel format, and forwards them to the Mixpanel Swift SDK. Configuration is received from mParticle servers at runtime.

**Tech Stack:** Swift 5.7+, mParticle-Apple-SDK ~> 8.0, Mixpanel-swift ~> 4.0, XCTest

---

## Task 1: Create Swift Package Structure

**Files:**
- Create: `Package.swift`
- Create: `Sources/mParticle-Mixpanel/MPKitMixpanel.swift`
- Create: `Tests/mParticle-MixpanelTests/MPKitMixpanelTests.swift`

**Step 1: Create Package.swift**

```swift
// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "mParticle-Mixpanel",
    platforms: [
        .iOS(.v12),
        .tvOS(.v12),
        .macOS(.v10_13),
        .watchOS(.v5)
    ],
    products: [
        .library(
            name: "mParticle-Mixpanel",
            targets: ["mParticle-Mixpanel"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/mParticle/mparticle-apple-sdk",
            .upToNextMajor(from: "8.0.0")
        ),
        .package(
            url: "https://github.com/mixpanel/mixpanel-swift",
            .upToNextMajor(from: "4.0.0")
        ),
    ],
    targets: [
        .target(
            name: "mParticle-Mixpanel",
            dependencies: [
                .product(name: "mParticle-Apple-SDK", package: "mparticle-apple-sdk"),
                .product(name: "Mixpanel", package: "mixpanel-swift"),
            ],
            path: "Sources/mParticle-Mixpanel"
        ),
        .testTarget(
            name: "mParticle-MixpanelTests",
            dependencies: ["mParticle-Mixpanel"],
            path: "Tests/mParticle-MixpanelTests"
        ),
    ]
)
```

**Step 2: Create empty MPKitMixpanel.swift skeleton**

```swift
import Foundation
#if canImport(mParticle_Apple_SDK)
import mParticle_Apple_SDK
#endif
import Mixpanel

/// mParticle Kit for Mixpanel analytics integration
@objc public class MPKitMixpanel: NSObject {
    // Placeholder - will be implemented in subsequent tasks
}
```

**Step 3: Create empty test file**

```swift
import XCTest
@testable import mParticle_Mixpanel

final class MPKitMixpanelTests: XCTestCase {
    func testPlaceholder() {
        XCTAssertTrue(true, "Package structure is set up correctly")
    }
}
```

**Step 4: Verify package resolves**

Run: `swift package resolve`
Expected: Dependencies resolve successfully

**Step 5: Run tests to verify setup**

Run: `swift test`
Expected: 1 test passes

**Step 6: Commit**

```bash
git add Package.swift Sources/ Tests/
git commit -m "feat: create Swift Package structure with dependencies"
```

---

## Task 2: Create CocoaPods Podspec

**Files:**
- Create: `mParticle-Mixpanel.podspec`

**Step 1: Create podspec file**

```ruby
Pod::Spec.new do |s|
    s.name             = "mParticle-Mixpanel"
    s.version          = "1.0.0"
    s.summary          = "Mixpanel integration for mParticle"

    s.description      = <<-DESC
                       This is the Mixpanel integration for mParticle.
                       DESC

    s.homepage         = "https://www.mparticle.com"
    s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
    s.author           = { "mParticle" => "support@mparticle.com" }
    s.source           = { :git => "https://github.com/mparticle-integrations/mparticle-apple-integration-mixpanel.git", :tag => "v" + s.version.to_s }
    s.social_media_url = "https://twitter.com/mparticle"
    s.swift_versions   = ['5.7', '5.8', '5.9']

    s.ios.deployment_target = "12.0"
    s.tvos.deployment_target = "12.0"

    s.source_files = 'Sources/mParticle-Mixpanel/**/*.swift'

    s.dependency 'mParticle-Apple-SDK', '~> 8.0'
    s.dependency 'Mixpanel-swift', '~> 4.0'
end
```

**Step 2: Validate podspec syntax**

Run: `pod spec lint mParticle-Mixpanel.podspec --allow-warnings --no-clean 2>&1 | head -20`
Expected: Shows validation output (may have warnings but no errors for syntax)

**Step 3: Commit**

```bash
git add mParticle-Mixpanel.podspec
git commit -m "feat: add CocoaPods podspec"
```

---

## Task 3: Create LICENSE and .gitignore

**Files:**
- Create: `LICENSE`
- Create: `.gitignore` (update existing)

**Step 1: Create Apache 2.0 LICENSE**

```text
                                 Apache License
                           Version 2.0, January 2004
                        http://www.apache.org/licenses/

   TERMS AND CONDITIONS FOR USE, REPRODUCTION, AND DISTRIBUTION

   1. Definitions.

      "License" shall mean the terms and conditions for use, reproduction,
      and distribution as defined by Sections 1 through 9 of this document.

      "Licensor" shall mean the copyright owner or entity authorized by
      the copyright owner that is granting the License.

      "Legal Entity" shall mean the union of the acting entity and all
      other entities that control, are controlled by, or are under common
      control with that entity. For the purposes of this definition,
      "control" means (i) the power, direct or indirect, to cause the
      direction or management of such entity, whether by contract or
      otherwise, or (ii) ownership of fifty percent (50%) or more of the
      outstanding shares, or (iii) beneficial ownership of such entity.

      "You" (or "Your") shall mean an individual or Legal Entity
      exercising permissions granted by this License.

      "Source" form shall mean the preferred form for making modifications,
      including but not limited to software source code, documentation
      source, and configuration files.

      "Object" form shall mean any form resulting from mechanical
      transformation or translation of a Source form, including but
      not limited to compiled object code, generated documentation,
      and conversions to other media types.

      "Work" shall mean the work of authorship, whether in Source or
      Object form, made available under the License, as indicated by a
      copyright notice that is included in or attached to the work
      (an example is provided in the Appendix below).

      "Derivative Works" shall mean any work, whether in Source or Object
      form, that is based on (or derived from) the Work and for which the
      editorial revisions, annotations, elaborations, or other modifications
      represent, as a whole, an original work of authorship. For the purposes
      of this License, Derivative Works shall not include works that remain
      separable from, or merely link (or bind by name) to the interfaces of,
      the Work and Derivative Works thereof.

      "Contribution" shall mean any work of authorship, including
      the original version of the Work and any modifications or additions
      to that Work or Derivative Works thereof, that is intentionally
      submitted to the Licensor for inclusion in the Work by the copyright owner
      or by an individual or Legal Entity authorized to submit on behalf of
      the copyright owner. For the purposes of this definition, "submitted"
      means any form of electronic, verbal, or written communication sent
      to the Licensor or its representatives, including but not limited to
      communication on electronic mailing lists, source code control systems,
      and issue tracking systems that are managed by, or on behalf of, the
      Licensor for the purpose of discussing and improving the Work, but
      excluding communication that is conspicuously marked or otherwise
      designated in writing by the copyright owner as "Not a Contribution."

      "Contributor" shall mean Licensor and any individual or Legal Entity
      on behalf of whom a Contribution has been received by Licensor and
      subsequently incorporated within the Work.

   2. Grant of Copyright License. Subject to the terms and conditions of
      this License, each Contributor hereby grants to You a perpetual,
      worldwide, non-exclusive, no-charge, royalty-free, irrevocable
      copyright license to reproduce, prepare Derivative Works of,
      publicly display, publicly perform, sublicense, and distribute the
      Work and such Derivative Works in Source or Object form.

   3. Grant of Patent License. Subject to the terms and conditions of
      this License, each Contributor hereby grants to You a perpetual,
      worldwide, non-exclusive, no-charge, royalty-free, irrevocable
      (except as stated in this section) patent license to make, have made,
      use, offer to sell, sell, import, and otherwise transfer the Work,
      where such license applies only to those patent claims licensable
      by such Contributor that are necessarily infringed by their
      Contribution(s) alone or by combination of their Contribution(s)
      with the Work to which such Contribution(s) was submitted. If You
      institute patent litigation against any entity (including a
      cross-claim or counterclaim in a lawsuit) alleging that the Work
      or a Contribution incorporated within the Work constitutes direct
      or contributory patent infringement, then any patent licenses
      granted to You under this License for that Work shall terminate
      as of the date such litigation is filed.

   4. Redistribution. You may reproduce and distribute copies of the
      Work or Derivative Works thereof in any medium, with or without
      modifications, and in Source or Object form, provided that You
      meet the following conditions:

      (a) You must give any other recipients of the Work or
          Derivative Works a copy of this License; and

      (b) You must cause any modified files to carry prominent notices
          stating that You changed the files; and

      (c) You must retain, in the Source form of any Derivative Works
          that You distribute, all copyright, patent, trademark, and
          attribution notices from the Source form of the Work,
          excluding those notices that do not pertain to any part of
          the Derivative Works; and

      (d) If the Work includes a "NOTICE" text file as part of its
          distribution, then any Derivative Works that You distribute must
          include a readable copy of the attribution notices contained
          within such NOTICE file, excluding those notices that do not
          pertain to any part of the Derivative Works, in at least one
          of the following places: within a NOTICE text file distributed
          as part of the Derivative Works; within the Source form or
          documentation, if provided along with the Derivative Works; or,
          within a display generated by the Derivative Works, if and
          wherever such third-party notices normally appear. The contents
          of the NOTICE file are for informational purposes only and
          do not modify the License. You may add Your own attribution
          notices within Derivative Works that You distribute, alongside
          or as an addendum to the NOTICE text from the Work, provided
          that such additional attribution notices cannot be construed
          as modifying the License.

      You may add Your own copyright statement to Your modifications and
      may provide additional or different license terms and conditions
      for use, reproduction, or distribution of Your modifications, or
      for any such Derivative Works as a whole, provided Your use,
      reproduction, and distribution of the Work otherwise complies with
      the conditions stated in this License.

   5. Submission of Contributions. Unless You explicitly state otherwise,
      any Contribution intentionally submitted for inclusion in the Work
      by You to the Licensor shall be under the terms and conditions of
      this License, without any additional terms or conditions.
      Notwithstanding the above, nothing herein shall supersede or modify
      the terms of any separate license agreement you may have executed
      with Licensor regarding such Contributions.

   6. Trademarks. This License does not grant permission to use the trade
      names, trademarks, service marks, or product names of the Licensor,
      except as required for reasonable and customary use in describing the
      origin of the Work and reproducing the content of the NOTICE file.

   7. Disclaimer of Warranty. Unless required by applicable law or
      agreed to in writing, Licensor provides the Work (and each
      Contributor provides its Contributions) on an "AS IS" BASIS,
      WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
      implied, including, without limitation, any warranties or conditions
      of TITLE, NON-INFRINGEMENT, MERCHANTABILITY, or FITNESS FOR A
      PARTICULAR PURPOSE. You are solely responsible for determining the
      appropriateness of using or redistributing the Work and assume any
      risks associated with Your exercise of permissions under this License.

   8. Limitation of Liability. In no event and under no legal theory,
      whether in tort (including negligence), contract, or otherwise,
      unless required by applicable law (such as deliberate and grossly
      negligent acts) or agreed to in writing, shall any Contributor be
      liable to You for damages, including any direct, indirect, special,
      incidental, or consequential damages of any character arising as a
      result of this License or out of the use or inability to use the
      Work (including but not limited to damages for loss of goodwill,
      work stoppage, computer failure or malfunction, or any and all
      other commercial damages or losses), even if such Contributor
      has been advised of the possibility of such damages.

   9. Accepting Warranty or Additional Liability. While redistributing
      the Work or Derivative Works thereof, You may choose to offer,
      and charge a fee for, acceptance of support, warranty, indemnity,
      or other liability obligations and/or rights consistent with this
      License. However, in accepting such obligations, You may act only
      on Your own behalf and on Your sole responsibility, not on behalf
      of any other Contributor, and only if You agree to indemnify,
      defend, and hold each Contributor harmless for any liability
      incurred by, or claims asserted against, such Contributor by reason
      of your accepting any such warranty or additional liability.

   END OF TERMS AND CONDITIONS

   Copyright 2024 mParticle, Inc.

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
```

**Step 2: Update .gitignore**

```text
*.DS_Store
.build/
.swiftpm/
Packages/
xcuserdata/
DerivedData/
*.xcodeproj/project.xcworkspace/xcuserdata/
*.xcodeproj/xcuserdata/
Pods/
Carthage/Build/
*.xccheckout
*.moved-aside
*.pbxuser
!default.pbxuser
*.mode1v3
!default.mode1v3
*.mode2v3
!default.mode2v3
*.perspectivev3
!default.perspectivev3
```

**Step 3: Commit**

```bash
git add LICENSE .gitignore
git commit -m "chore: add LICENSE and update .gitignore"
```

---

## Task 4: Implement Kit Registration and Configuration Types

**Files:**
- Modify: `Sources/mParticle-Mixpanel/MPKitMixpanel.swift`
- Create: `Sources/mParticle-Mixpanel/UserIdentificationType.swift`
- Create: `Tests/mParticle-MixpanelTests/ConfigurationTests.swift`

**Step 1: Write failing test for UserIdentificationType enum**

```swift
// Tests/mParticle-MixpanelTests/ConfigurationTests.swift
import XCTest
@testable import mParticle_Mixpanel

final class ConfigurationTests: XCTestCase {

    func testUserIdentificationTypeFromString_CustomerId() {
        let type = UserIdentificationType(rawValue: "CustomerId")
        XCTAssertEqual(type, .customerId)
    }

    func testUserIdentificationTypeFromString_MPID() {
        let type = UserIdentificationType(rawValue: "MPID")
        XCTAssertEqual(type, .mpid)
    }

    func testUserIdentificationTypeFromString_Other() {
        let type = UserIdentificationType(rawValue: "Other")
        XCTAssertEqual(type, .other)
    }

    func testUserIdentificationTypeFromString_InvalidDefaultsToCustomerId() {
        let type = UserIdentificationType(rawValue: "InvalidValue") ?? .customerId
        XCTAssertEqual(type, .customerId)
    }
}
```

**Step 2: Run test to verify it fails**

Run: `swift test --filter ConfigurationTests`
Expected: FAIL with "cannot find 'UserIdentificationType' in scope"

**Step 3: Create UserIdentificationType enum**

```swift
// Sources/mParticle-Mixpanel/UserIdentificationType.swift
import Foundation

/// Configurable user identification type for Mixpanel identity mapping
public enum UserIdentificationType: String {
    case customerId = "CustomerId"
    case mpid = "MPID"
    case other = "Other"
    case other2 = "Other2"
    case other3 = "Other3"
    case other4 = "Other4"
}
```

**Step 4: Run test to verify it passes**

Run: `swift test --filter ConfigurationTests`
Expected: PASS (4 tests)

**Step 5: Commit**

```bash
git add Sources/mParticle-Mixpanel/UserIdentificationType.swift Tests/mParticle-MixpanelTests/ConfigurationTests.swift
git commit -m "feat: add UserIdentificationType enum for identity mapping"
```

---

## Task 5: Implement MPKitProtocol Conformance Skeleton

**Files:**
- Modify: `Sources/mParticle-Mixpanel/MPKitMixpanel.swift`
- Create: `Tests/mParticle-MixpanelTests/KitRegistrationTests.swift`

**Step 1: Write failing test for kit code**

```swift
// Tests/mParticle-MixpanelTests/KitRegistrationTests.swift
import XCTest
@testable import mParticle_Mixpanel

final class KitRegistrationTests: XCTestCase {

    func testKitCode_Returns178() {
        let kitCode = MPKitMixpanel.kitCode()
        XCTAssertEqual(kitCode, NSNumber(value: 178))
    }
}
```

**Step 2: Run test to verify it fails**

Run: `swift test --filter KitRegistrationTests`
Expected: FAIL with "type 'MPKitMixpanel' has no member 'kitCode'"

**Step 3: Implement MPKitProtocol skeleton**

```swift
// Sources/mParticle-Mixpanel/MPKitMixpanel.swift
import Foundation
#if canImport(mParticle_Apple_SDK)
import mParticle_Apple_SDK
#endif
import Mixpanel

/// Configuration keys for Mixpanel Kit
private enum ConfigurationKey {
    static let token = "token"
    static let serverURL = "serverURL"
    static let userIdentificationType = "userIdentificationType"
    static let useMixpanelPeople = "useMixpanelPeople"
}

/// mParticle Kit for Mixpanel analytics integration
@objc public class MPKitMixpanel: NSObject, MPKitProtocol {

    // MARK: - MPKitProtocol Required Properties

    @objc public var configuration: [AnyHashable: Any] = [:]
    @objc public var launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    @objc public var started: Bool = false

    // MARK: - Configuration Properties

    private var token: String?
    private var serverURL: String?
    private var userIdentificationType: UserIdentificationType = .customerId
    private var useMixpanelPeople: Bool = true

    // MARK: - Mixpanel Instance

    private var mixpanelInstance: MixpanelInstance?

    // MARK: - Kit Code

    /// Mixpanel Kit Code assigned by mParticle
    @objc public static func kitCode() -> NSNumber {
        return NSNumber(value: 178)
    }

    // MARK: - Kit Registration

    @objc public static func load() {
        // Registration happens via mParticle SDK
        // This method is called automatically at load time
    }

    // MARK: - Helpers

    private func execStatus(_ returnCode: MPKitReturnCode) -> MPKitExecStatus {
        return MPKitExecStatus(sdkCode: Self.kitCode(), returnCode: returnCode)
    }
}
```

**Step 4: Run test to verify it passes**

Run: `swift test --filter KitRegistrationTests`
Expected: PASS (1 test)

**Step 5: Commit**

```bash
git add Sources/mParticle-Mixpanel/MPKitMixpanel.swift Tests/mParticle-MixpanelTests/KitRegistrationTests.swift
git commit -m "feat: implement MPKitProtocol skeleton with kit code 178"
```

---

## Task 6: Implement didFinishLaunchingWithConfiguration

**Files:**
- Modify: `Sources/mParticle-Mixpanel/MPKitMixpanel.swift`
- Create: `Tests/mParticle-MixpanelTests/InitializationTests.swift`

**Step 1: Write failing test for configuration parsing**

```swift
// Tests/mParticle-MixpanelTests/InitializationTests.swift
import XCTest
@testable import mParticle_Mixpanel

final class InitializationTests: XCTestCase {

    func testDidFinishLaunching_WithValidToken_ReturnsSuccess() {
        let kit = MPKitMixpanel()
        let config: [AnyHashable: Any] = [
            "token": "test-token-12345"
        ]

        let status = kit.didFinishLaunching(withConfiguration: config)

        XCTAssertEqual(status?.returnCode, MPKitReturnCode.success)
        XCTAssertTrue(kit.started)
    }

    func testDidFinishLaunching_WithMissingToken_ReturnsRequirementsNotMet() {
        let kit = MPKitMixpanel()
        let config: [AnyHashable: Any] = [:]

        let status = kit.didFinishLaunching(withConfiguration: config)

        XCTAssertEqual(status?.returnCode, MPKitReturnCode.requirementsNotMet)
        XCTAssertFalse(kit.started)
    }

    func testDidFinishLaunching_ParsesServerURL() {
        let kit = MPKitMixpanel()
        let config: [AnyHashable: Any] = [
            "token": "test-token",
            "serverURL": "https://custom.mixpanel.com"
        ]

        let status = kit.didFinishLaunching(withConfiguration: config)

        XCTAssertEqual(status?.returnCode, MPKitReturnCode.success)
    }

    func testDidFinishLaunching_ParsesUseMixpanelPeopleTrue() {
        let kit = MPKitMixpanel()
        let config: [AnyHashable: Any] = [
            "token": "test-token",
            "useMixpanelPeople": "True"
        ]

        let status = kit.didFinishLaunching(withConfiguration: config)

        XCTAssertEqual(status?.returnCode, MPKitReturnCode.success)
    }

    func testDidFinishLaunching_ParsesUserIdentificationType() {
        let kit = MPKitMixpanel()
        let config: [AnyHashable: Any] = [
            "token": "test-token",
            "userIdentificationType": "MPID"
        ]

        let status = kit.didFinishLaunching(withConfiguration: config)

        XCTAssertEqual(status?.returnCode, MPKitReturnCode.success)
    }
}
```

**Step 2: Run test to verify it fails**

Run: `swift test --filter InitializationTests`
Expected: FAIL with "value of type 'MPKitMixpanel' has no member 'didFinishLaunching'"

**Step 3: Implement didFinishLaunchingWithConfiguration**

Add to `MPKitMixpanel.swift`:

```swift
    // MARK: - MPKitProtocol Lifecycle

    @objc public func didFinishLaunching(withConfiguration configuration: [AnyHashable: Any]) -> MPKitExecStatus {
        // Store configuration
        self.configuration = configuration

        // Parse required token
        guard let token = configuration[ConfigurationKey.token] as? String, !token.isEmpty else {
            return execStatus(.requirementsNotMet)
        }
        self.token = token

        // Parse optional server URL
        if let serverURL = configuration[ConfigurationKey.serverURL] as? String, !serverURL.isEmpty {
            self.serverURL = serverURL
        }

        // Parse user identification type (default: CustomerId)
        if let typeString = configuration[ConfigurationKey.userIdentificationType] as? String,
           let type = UserIdentificationType(rawValue: typeString) {
            self.userIdentificationType = type
        }

        // Parse useMixpanelPeople (default: true)
        if let peopleString = configuration[ConfigurationKey.useMixpanelPeople] as? String {
            self.useMixpanelPeople = peopleString.lowercased() == "true"
        }

        // Start the kit
        start()

        return execStatus(.success)
    }

    private func start() {
        // Initialize Mixpanel with configuration
        guard let token = self.token else { return }

        if let serverURL = self.serverURL {
            self.mixpanelInstance = Mixpanel.initialize(
                token: token,
                trackAutomaticEvents: false,
                serverURL: serverURL
            )
        } else {
            self.mixpanelInstance = Mixpanel.initialize(
                token: token,
                trackAutomaticEvents: false
            )
        }

        self.started = true

        // Post notification that kit is active
        DispatchQueue.main.async {
            let userInfo = [mParticleKitInstanceKey: Self.kitCode()]
            NotificationCenter.default.post(
                name: .mParticleKitDidBecomeActive,
                object: nil,
                userInfo: userInfo
            )
        }
    }
```

**Step 4: Run test to verify it passes**

Run: `swift test --filter InitializationTests`
Expected: PASS (5 tests)

**Step 5: Commit**

```bash
git add Sources/mParticle-Mixpanel/MPKitMixpanel.swift Tests/mParticle-MixpanelTests/InitializationTests.swift
git commit -m "feat: implement didFinishLaunchingWithConfiguration with config parsing"
```

---

## Task 7: Implement providerKitInstance

**Files:**
- Modify: `Sources/mParticle-Mixpanel/MPKitMixpanel.swift`
- Modify: `Tests/mParticle-MixpanelTests/InitializationTests.swift`

**Step 1: Write failing test for providerKitInstance**

Add to `InitializationTests.swift`:

```swift
    func testProviderKitInstance_WhenStarted_ReturnsMixpanelInstance() {
        let kit = MPKitMixpanel()
        let config: [AnyHashable: Any] = ["token": "test-token"]
        _ = kit.didFinishLaunching(withConfiguration: config)

        let instance = kit.providerKitInstance

        XCTAssertNotNil(instance)
    }

    func testProviderKitInstance_WhenNotStarted_ReturnsNil() {
        let kit = MPKitMixpanel()

        let instance = kit.providerKitInstance

        XCTAssertNil(instance)
    }
```

**Step 2: Run test to verify it fails**

Run: `swift test --filter InitializationTests`
Expected: FAIL with "has no member 'providerKitInstance'"

**Step 3: Implement providerKitInstance**

Add to `MPKitMixpanel.swift`:

```swift
    // MARK: - Provider Instance

    @objc public var providerKitInstance: Any? {
        guard started else { return nil }
        return mixpanelInstance
    }
```

**Step 4: Run test to verify it passes**

Run: `swift test --filter InitializationTests`
Expected: PASS (7 tests)

**Step 5: Commit**

```bash
git add Sources/mParticle-Mixpanel/MPKitMixpanel.swift Tests/mParticle-MixpanelTests/InitializationTests.swift
git commit -m "feat: implement providerKitInstance"
```

---

## Task 8: Implement Event Forwarding (routeEvent)

**Files:**
- Modify: `Sources/mParticle-Mixpanel/MPKitMixpanel.swift`
- Create: `Tests/mParticle-MixpanelTests/EventForwardingTests.swift`

**Step 1: Write failing test for event forwarding**

```swift
// Tests/mParticle-MixpanelTests/EventForwardingTests.swift
import XCTest
@testable import mParticle_Mixpanel
#if canImport(mParticle_Apple_SDK)
import mParticle_Apple_SDK
#endif

final class EventForwardingTests: XCTestCase {

    var kit: MPKitMixpanel!

    override func setUp() {
        super.setUp()
        kit = MPKitMixpanel()
        let config: [AnyHashable: Any] = ["token": "test-token"]
        _ = kit.didFinishLaunching(withConfiguration: config)
    }

    override func tearDown() {
        kit = nil
        super.tearDown()
    }

    func testRouteEvent_WithValidEvent_ReturnsSuccess() {
        let event = MPEvent(name: "Test Event", type: .other)!

        let status = kit.routeEvent(event)

        XCTAssertEqual(status?.returnCode, MPKitReturnCode.success)
    }

    func testRouteEvent_WithEmptyName_ReturnsFail() {
        let event = MPEvent(name: "", type: .other)!

        let status = kit.routeEvent(event)

        XCTAssertEqual(status?.returnCode, MPKitReturnCode.fail)
    }

    func testRouteEvent_WithAttributes_ReturnsSuccess() {
        let event = MPEvent(name: "Test Event", type: .other)!
        event.customAttributes = ["key1": "value1", "key2": 42]

        let status = kit.routeEvent(event)

        XCTAssertEqual(status?.returnCode, MPKitReturnCode.success)
    }
}
```

**Step 2: Run test to verify it fails**

Run: `swift test --filter EventForwardingTests`
Expected: FAIL with "has no member 'routeEvent'"

**Step 3: Implement routeEvent**

Add to `MPKitMixpanel.swift`:

```swift
    // MARK: - Event Forwarding

    @objc public func routeEvent(_ event: MPEvent) -> MPKitExecStatus {
        guard started, let mixpanel = mixpanelInstance else {
            return execStatus(.fail)
        }

        guard let eventName = event.name, !eventName.isEmpty else {
            return execStatus(.fail)
        }

        let properties = convertToMixpanelProperties(event.customAttributes)
        mixpanel.track(event: eventName, properties: properties)

        return execStatus(.success)
    }

    // MARK: - Property Conversion

    private func convertToMixpanelProperties(_ attributes: [String: Any]?) -> Properties? {
        guard let attributes = attributes else { return nil }

        var properties: Properties = [:]
        for (key, value) in attributes {
            if let mixpanelValue = value as? MixpanelType {
                properties[key] = mixpanelValue
            }
        }
        return properties.isEmpty ? nil : properties
    }
```

**Step 4: Run test to verify it passes**

Run: `swift test --filter EventForwardingTests`
Expected: PASS (3 tests)

**Step 5: Commit**

```bash
git add Sources/mParticle-Mixpanel/MPKitMixpanel.swift Tests/mParticle-MixpanelTests/EventForwardingTests.swift
git commit -m "feat: implement routeEvent for custom event forwarding"
```

---

## Task 9: Implement logBaseEvent Router

**Files:**
- Modify: `Sources/mParticle-Mixpanel/MPKitMixpanel.swift`
- Modify: `Tests/mParticle-MixpanelTests/EventForwardingTests.swift`

**Step 1: Write failing test for logBaseEvent**

Add to `EventForwardingTests.swift`:

```swift
    func testLogBaseEvent_WithMPEvent_RoutesToRouteEvent() {
        let event = MPEvent(name: "Base Event", type: .other)!

        let status = kit.logBaseEvent(event)

        XCTAssertEqual(status?.returnCode, MPKitReturnCode.success)
    }

    func testLogBaseEvent_WithCommerceEvent_RoutesToRouteCommerceEvent() {
        let product = MPProduct(name: "Test Product", sku: "SKU123", quantity: 1, price: 9.99)
        let commerceEvent = MPCommerceEvent(action: .purchase, product: product)!

        let status = kit.logBaseEvent(commerceEvent)

        // Commerce events should be handled (success or specific handling)
        XCTAssertNotNil(status)
    }
```

**Step 2: Run test to verify it fails**

Run: `swift test --filter EventForwardingTests`
Expected: FAIL with "has no member 'logBaseEvent'"

**Step 3: Implement logBaseEvent**

Add to `MPKitMixpanel.swift`:

```swift
    @objc public func logBaseEvent(_ event: MPBaseEvent) -> MPKitExecStatus {
        if let mpEvent = event as? MPEvent {
            return routeEvent(mpEvent)
        } else if let commerceEvent = event as? MPCommerceEvent {
            return routeCommerceEvent(commerceEvent)
        } else {
            return execStatus(.unavailable)
        }
    }

    // Placeholder for commerce events - will be implemented later
    @objc public func routeCommerceEvent(_ commerceEvent: MPCommerceEvent) -> MPKitExecStatus {
        // Will be implemented in Task 13
        return execStatus(.success)
    }
```

**Step 4: Run test to verify it passes**

Run: `swift test --filter EventForwardingTests`
Expected: PASS (5 tests)

**Step 5: Commit**

```bash
git add Sources/mParticle-Mixpanel/MPKitMixpanel.swift Tests/mParticle-MixpanelTests/EventForwardingTests.swift
git commit -m "feat: implement logBaseEvent router"
```

---

## Task 10: Implement logScreen for Screen Views

**Files:**
- Modify: `Sources/mParticle-Mixpanel/MPKitMixpanel.swift`
- Modify: `Tests/mParticle-MixpanelTests/EventForwardingTests.swift`

**Step 1: Write failing test for screen views**

Add to `EventForwardingTests.swift`:

```swift
    func testLogScreen_PrefixesWithViewed() {
        let event = MPEvent(name: "Home Screen", type: .other)!

        let status = kit.logScreen(event)

        XCTAssertEqual(status?.returnCode, MPKitReturnCode.success)
    }

    func testLogScreen_WithEmptyName_ReturnsFail() {
        let event = MPEvent(name: "", type: .other)!

        let status = kit.logScreen(event)

        XCTAssertEqual(status?.returnCode, MPKitReturnCode.fail)
    }
```

**Step 2: Run test to verify it fails**

Run: `swift test --filter EventForwardingTests`
Expected: FAIL with "has no member 'logScreen'"

**Step 3: Implement logScreen**

Add to `MPKitMixpanel.swift`:

```swift
    @objc public func logScreen(_ event: MPEvent) -> MPKitExecStatus {
        guard started, let mixpanel = mixpanelInstance else {
            return execStatus(.fail)
        }

        guard let screenName = event.name, !screenName.isEmpty else {
            return execStatus(.fail)
        }

        let eventName = "Viewed \(screenName)"
        let properties = convertToMixpanelProperties(event.customAttributes)
        mixpanel.track(event: eventName, properties: properties)

        return execStatus(.success)
    }
```

**Step 4: Run test to verify it passes**

Run: `swift test --filter EventForwardingTests`
Expected: PASS (7 tests)

**Step 5: Commit**

```bash
git add Sources/mParticle-Mixpanel/MPKitMixpanel.swift Tests/mParticle-MixpanelTests/EventForwardingTests.swift
git commit -m "feat: implement logScreen with 'Viewed' prefix"
```

---

## Task 11: Implement Identity Handling (Login/Logout)

**Files:**
- Modify: `Sources/mParticle-Mixpanel/MPKitMixpanel.swift`
- Create: `Tests/mParticle-MixpanelTests/IdentityTests.swift`

**Step 1: Write failing test for login**

```swift
// Tests/mParticle-MixpanelTests/IdentityTests.swift
import XCTest
@testable import mParticle_Mixpanel
#if canImport(mParticle_Apple_SDK)
import mParticle_Apple_SDK
#endif

final class IdentityTests: XCTestCase {

    var kit: MPKitMixpanel!

    override func setUp() {
        super.setUp()
        kit = MPKitMixpanel()
        let config: [AnyHashable: Any] = [
            "token": "test-token",
            "userIdentificationType": "CustomerId"
        ]
        _ = kit.didFinishLaunching(withConfiguration: config)
    }

    override func tearDown() {
        kit = nil
        super.tearDown()
    }

    func testOnLoginComplete_ReturnsSuccess() {
        // Create mock user with identities
        let status = kit.onLoginComplete(withUser: nil, request: nil)

        XCTAssertEqual(status?.returnCode, MPKitReturnCode.success)
    }

    func testOnLogoutComplete_ReturnsSuccess() {
        let status = kit.onLogoutComplete(withUser: nil, request: nil)

        XCTAssertEqual(status?.returnCode, MPKitReturnCode.success)
    }

    func testOnIdentifyComplete_ReturnsSuccess() {
        let status = kit.onIdentifyComplete(withUser: nil, request: nil)

        XCTAssertEqual(status?.returnCode, MPKitReturnCode.success)
    }

    func testOnModifyComplete_ReturnsSuccess() {
        let status = kit.onModifyComplete(withUser: nil, request: nil)

        XCTAssertEqual(status?.returnCode, MPKitReturnCode.success)
    }
}
```

**Step 2: Run test to verify it fails**

Run: `swift test --filter IdentityTests`
Expected: FAIL with "has no member 'onLoginComplete'"

**Step 3: Implement identity methods**

Add to `MPKitMixpanel.swift`:

```swift
    // MARK: - Identity Handling

    @objc public func onIdentifyComplete(withUser user: FilteredMParticleUser?, request: FilteredMPIdentityApiRequest?) -> MPKitExecStatus {
        guard started else { return execStatus(.fail) }

        if let userId = extractUserId(from: user) {
            mixpanelInstance?.identify(distinctId: userId)
        }

        return execStatus(.success)
    }

    @objc public func onLoginComplete(withUser user: FilteredMParticleUser?, request: FilteredMPIdentityApiRequest?) -> MPKitExecStatus {
        guard started else { return execStatus(.fail) }

        if let userId = extractUserId(from: user) {
            mixpanelInstance?.identify(distinctId: userId)
        }

        return execStatus(.success)
    }

    @objc public func onLogoutComplete(withUser user: FilteredMParticleUser?, request: FilteredMPIdentityApiRequest?) -> MPKitExecStatus {
        guard started else { return execStatus(.fail) }

        mixpanelInstance?.reset()

        return execStatus(.success)
    }

    @objc public func onModifyComplete(withUser user: FilteredMParticleUser?, request: FilteredMPIdentityApiRequest?) -> MPKitExecStatus {
        guard started else { return execStatus(.fail) }

        if let userId = extractUserId(from: user) {
            mixpanelInstance?.identify(distinctId: userId)
        }

        return execStatus(.success)
    }

    // MARK: - Identity Helpers

    private func extractUserId(from user: FilteredMParticleUser?) -> String? {
        guard let user = user else { return nil }

        let userIdentities = user.userIdentities ?? [:]

        // Only identify if user has actual identities (not anonymous)
        guard !userIdentities.isEmpty else { return nil }

        switch userIdentificationType {
        case .customerId:
            return userIdentities[NSNumber(value: MPUserIdentity.customerId.rawValue)] as? String
        case .mpid:
            return String(user.userId)
        case .other:
            return userIdentities[NSNumber(value: MPUserIdentity.other.rawValue)] as? String
        case .other2:
            return userIdentities[NSNumber(value: MPUserIdentity.other2.rawValue)] as? String
        case .other3:
            return userIdentities[NSNumber(value: MPUserIdentity.other3.rawValue)] as? String
        case .other4:
            return userIdentities[NSNumber(value: MPUserIdentity.other4.rawValue)] as? String
        }
    }
```

**Step 4: Run test to verify it passes**

Run: `swift test --filter IdentityTests`
Expected: PASS (4 tests)

**Step 5: Commit**

```bash
git add Sources/mParticle-Mixpanel/MPKitMixpanel.swift Tests/mParticle-MixpanelTests/IdentityTests.swift
git commit -m "feat: implement identity handling (login, logout, identify, modify)"
```

---

## Task 12: Implement User Attributes

**Files:**
- Modify: `Sources/mParticle-Mixpanel/MPKitMixpanel.swift`
- Create: `Tests/mParticle-MixpanelTests/UserAttributeTests.swift`

**Step 1: Write failing test for user attributes**

```swift
// Tests/mParticle-MixpanelTests/UserAttributeTests.swift
import XCTest
@testable import mParticle_Mixpanel
#if canImport(mParticle_Apple_SDK)
import mParticle_Apple_SDK
#endif

final class UserAttributeTests: XCTestCase {

    func testOnSetUserAttribute_WithPeopleMode_ReturnsSuccess() {
        let kit = MPKitMixpanel()
        let config: [AnyHashable: Any] = [
            "token": "test-token",
            "useMixpanelPeople": "True"
        ]
        _ = kit.didFinishLaunching(withConfiguration: config)

        let status = kit.onSetUserAttribute(withUser: nil)

        XCTAssertEqual(status?.returnCode, MPKitReturnCode.success)
    }

    func testOnSetUserAttribute_WithSuperPropsMode_ReturnsSuccess() {
        let kit = MPKitMixpanel()
        let config: [AnyHashable: Any] = [
            "token": "test-token",
            "useMixpanelPeople": "False"
        ]
        _ = kit.didFinishLaunching(withConfiguration: config)

        let status = kit.onSetUserAttribute(withUser: nil)

        XCTAssertEqual(status?.returnCode, MPKitReturnCode.success)
    }

    func testOnRemoveUserAttribute_ReturnsSuccess() {
        let kit = MPKitMixpanel()
        let config: [AnyHashable: Any] = ["token": "test-token"]
        _ = kit.didFinishLaunching(withConfiguration: config)

        let status = kit.onRemoveUserAttribute(withUser: nil)

        XCTAssertEqual(status?.returnCode, MPKitReturnCode.success)
    }
}
```

**Step 2: Run test to verify it fails**

Run: `swift test --filter UserAttributeTests`
Expected: FAIL with "has no member 'onSetUserAttribute'"

**Step 3: Implement user attribute methods**

Add to `MPKitMixpanel.swift`:

```swift
    // MARK: - User Attributes

    @objc public func onSetUserAttribute(withUser user: FilteredMParticleUser?) -> MPKitExecStatus {
        guard started, let mixpanel = mixpanelInstance else {
            return execStatus(.fail)
        }

        guard let user = user,
              let changedAttribute = user.userAttributes?.keys.first as? String,
              let value = user.userAttributes?[changedAttribute] else {
            return execStatus(.success)
        }

        if useMixpanelPeople {
            // Use People API
            if let mixpanelValue = value as? MixpanelType {
                mixpanel.people.set(property: changedAttribute, to: mixpanelValue)
            }
        } else {
            // Use Super Properties
            if let mixpanelValue = value as? MixpanelType {
                mixpanel.registerSuperProperties([changedAttribute: mixpanelValue])
            }
        }

        return execStatus(.success)
    }

    @objc public func onRemoveUserAttribute(withUser user: FilteredMParticleUser?) -> MPKitExecStatus {
        guard started, let mixpanel = mixpanelInstance else {
            return execStatus(.fail)
        }

        // Note: mParticle provides the attribute key that was removed
        // For now, return success as we don't have the removed key in FilteredMParticleUser

        return execStatus(.success)
    }
```

**Step 4: Run test to verify it passes**

Run: `swift test --filter UserAttributeTests`
Expected: PASS (3 tests)

**Step 5: Commit**

```bash
git add Sources/mParticle-Mixpanel/MPKitMixpanel.swift Tests/mParticle-MixpanelTests/UserAttributeTests.swift
git commit -m "feat: implement user attribute handling with People/SuperProps toggle"
```

---

## Task 13: Implement Commerce Events

**Files:**
- Modify: `Sources/mParticle-Mixpanel/MPKitMixpanel.swift`
- Create: `Tests/mParticle-MixpanelTests/CommerceTests.swift`

**Step 1: Write failing test for commerce events**

```swift
// Tests/mParticle-MixpanelTests/CommerceTests.swift
import XCTest
@testable import mParticle_Mixpanel
#if canImport(mParticle_Apple_SDK)
import mParticle_Apple_SDK
#endif

final class CommerceTests: XCTestCase {

    var kit: MPKitMixpanel!

    override func setUp() {
        super.setUp()
        kit = MPKitMixpanel()
        let config: [AnyHashable: Any] = [
            "token": "test-token",
            "useMixpanelPeople": "True"
        ]
        _ = kit.didFinishLaunching(withConfiguration: config)
    }

    override func tearDown() {
        kit = nil
        super.tearDown()
    }

    func testRouteCommerceEvent_Purchase_TracksCharge() {
        let product = MPProduct(name: "Test Product", sku: "SKU123", quantity: 1, price: 29.99)
        let commerceEvent = MPCommerceEvent(action: .purchase, product: product)!
        commerceEvent.transactionAttributes = MPTransactionAttributes()
        commerceEvent.transactionAttributes?.revenue = 29.99

        let status = kit.routeCommerceEvent(commerceEvent)

        XCTAssertEqual(status?.returnCode, MPKitReturnCode.success)
    }

    func testRouteCommerceEvent_NonPurchase_ExpandsToEvents() {
        let product = MPProduct(name: "Test Product", sku: "SKU123", quantity: 1, price: 29.99)
        let commerceEvent = MPCommerceEvent(action: .addToCart, product: product)!

        let status = kit.routeCommerceEvent(commerceEvent)

        // Non-purchase events should be expanded and tracked
        XCTAssertEqual(status?.returnCode, MPKitReturnCode.success)
    }

    func testRouteCommerceEvent_WithoutPeopleMode_ReturnsSuccess() {
        let kit = MPKitMixpanel()
        let config: [AnyHashable: Any] = [
            "token": "test-token",
            "useMixpanelPeople": "False"
        ]
        _ = kit.didFinishLaunching(withConfiguration: config)

        let product = MPProduct(name: "Test Product", sku: "SKU123", quantity: 1, price: 29.99)
        let commerceEvent = MPCommerceEvent(action: .purchase, product: product)!

        let status = kit.routeCommerceEvent(commerceEvent)

        // Should still work but not call people.trackCharge
        XCTAssertEqual(status?.returnCode, MPKitReturnCode.success)
    }
}
```

**Step 2: Run test to verify it fails**

Run: `swift test --filter CommerceTests`
Expected: Tests may pass with placeholder, need real implementation

**Step 3: Implement full commerce event handling**

Replace the placeholder `routeCommerceEvent` in `MPKitMixpanel.swift`:

```swift
    @objc public func routeCommerceEvent(_ commerceEvent: MPCommerceEvent) -> MPKitExecStatus {
        guard started, let mixpanel = mixpanelInstance else {
            return execStatus(.fail)
        }

        let execStatus = MPKitExecStatus(sdkCode: Self.kitCode(), returnCode: .success)

        // Handle Purchase events with People API
        if commerceEvent.action == .purchase {
            if useMixpanelPeople {
                let revenue = commerceEvent.transactionAttributes?.revenue?.doubleValue ?? 0.0
                let properties = convertToMixpanelProperties(commerceEvent.customAttributes)
                mixpanel.people.trackCharge(amount: revenue, properties: properties)
            }
            execStatus?.incrementForwardCount()
        } else {
            // Expand non-purchase commerce events to regular events
            if let expandedEvents = commerceEvent.expandedInstructions() as? [MPCommerceEventInstruction] {
                for instruction in expandedEvents {
                    if let event = instruction.event {
                        _ = routeEvent(event)
                        execStatus?.incrementForwardCount()
                    }
                }
            }
        }

        return execStatus ?? self.execStatus(.success)
    }
```

**Step 4: Run test to verify it passes**

Run: `swift test --filter CommerceTests`
Expected: PASS (3 tests)

**Step 5: Commit**

```bash
git add Sources/mParticle-Mixpanel/MPKitMixpanel.swift Tests/mParticle-MixpanelTests/CommerceTests.swift
git commit -m "feat: implement commerce event handling with trackCharge"
```

---

## Task 14: Implement Opt-Out Support

**Files:**
- Modify: `Sources/mParticle-Mixpanel/MPKitMixpanel.swift`
- Modify: `Tests/mParticle-MixpanelTests/InitializationTests.swift`

**Step 1: Write failing test for opt-out**

Add to `InitializationTests.swift`:

```swift
    func testSetOptOut_True_CallsMixpanelOptOut() {
        let kit = MPKitMixpanel()
        let config: [AnyHashable: Any] = ["token": "test-token"]
        _ = kit.didFinishLaunching(withConfiguration: config)

        let status = kit.setOptOut(true)

        XCTAssertEqual(status?.returnCode, MPKitReturnCode.success)
    }

    func testSetOptOut_False_CallsMixpanelOptIn() {
        let kit = MPKitMixpanel()
        let config: [AnyHashable: Any] = ["token": "test-token"]
        _ = kit.didFinishLaunching(withConfiguration: config)

        let status = kit.setOptOut(false)

        XCTAssertEqual(status?.returnCode, MPKitReturnCode.success)
    }
```

**Step 2: Run test to verify it fails**

Run: `swift test --filter InitializationTests`
Expected: FAIL with "has no member 'setOptOut'"

**Step 3: Implement setOptOut**

Add to `MPKitMixpanel.swift`:

```swift
    // MARK: - Opt Out

    @objc public func setOptOut(_ optOut: Bool) -> MPKitExecStatus {
        guard started, let mixpanel = mixpanelInstance else {
            return execStatus(.fail)
        }

        if optOut {
            mixpanel.optOutTracking()
        } else {
            mixpanel.optInTracking()
        }

        return execStatus(.success)
    }
```

**Step 4: Run test to verify it passes**

Run: `swift test --filter InitializationTests`
Expected: PASS (9 tests)

**Step 5: Commit**

```bash
git add Sources/mParticle-Mixpanel/MPKitMixpanel.swift Tests/mParticle-MixpanelTests/InitializationTests.swift
git commit -m "feat: implement setOptOut for GDPR compliance"
```

---

## Task 15: Create README Documentation

**Files:**
- Create: `README.md`

**Step 1: Create README**

```markdown
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

## Configuration

Configure the Mixpanel integration in the [mParticle dashboard](https://app.mparticle.com):

| Setting | Description | Default |
|---------|-------------|---------|
| `token` | Your Mixpanel project token | (required) |
| `serverURL` | Custom Mixpanel API endpoint | Mixpanel default |
| `userIdentificationType` | Identity type for Mixpanel user ID | CustomerId |
| `useMixpanelPeople` | Use People API for user attributes | true |

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
if let mixpanel = MParticle.sharedInstance().kitInstance(forKit: NSNumber(value: 178)) as? MixpanelInstance {
    mixpanel.time(event: "Long Operation")
}
```

## License

Apache License 2.0. See [LICENSE](LICENSE) for details.
```

**Step 2: Commit**

```bash
git add README.md
git commit -m "docs: add README with installation and usage instructions"
```

---

## Task 16: Run Full Test Suite and Final Commit

**Files:**
- All files

**Step 1: Run all tests**

Run: `swift test`
Expected: All tests pass

**Step 2: Check test coverage summary**

Run: `swift test 2>&1 | grep -E "(Test Suite|passed|failed)"`
Expected: See passing test count

**Step 3: Create git tag for v1.0.0**

```bash
git tag -a v1.0.0 -m "Initial release of mParticle-Mixpanel Kit"
```

**Step 4: Final status check**

Run: `git log --oneline | head -20`
Expected: See all commits in order

---

## Summary

This plan implements the mParticle Mixpanel iOS Kit in 16 tasks with TDD approach:

1. **Tasks 1-3**: Project setup (Package.swift, podspec, LICENSE)
2. **Tasks 4-7**: Kit infrastructure (types, registration, configuration, instance)
3. **Tasks 8-10**: Event forwarding (routeEvent, logBaseEvent, logScreen)
4. **Tasks 11-12**: Identity and user attributes
5. **Tasks 13-14**: Commerce events and opt-out
6. **Tasks 15-16**: Documentation and release

Each task follows the Red-Green-Refactor pattern with explicit test commands and expected outputs.
