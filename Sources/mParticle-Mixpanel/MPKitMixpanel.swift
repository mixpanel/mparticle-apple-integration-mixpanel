import Foundation
import UIKit
import Mixpanel
import mParticle_Apple_SDK

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

    // MARK: - MPKitProtocol Lifecycle

    @objc public func didFinishLaunching(withConfiguration configuration: [AnyHashable: Any]) -> MPKitExecStatus {
        // Will be implemented in Task 6
        return execStatus(.success)
    }

    // MARK: - Helpers

    private func execStatus(_ returnCode: MPKitReturnCode) -> MPKitExecStatus {
        return MPKitExecStatus(sdkCode: Self.kitCode(), returnCode: returnCode)
    }
}
