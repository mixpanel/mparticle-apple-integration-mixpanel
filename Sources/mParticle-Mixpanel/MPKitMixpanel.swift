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
        startKit()

        return execStatus(.success)
    }

    private func startKit() {
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

    // MARK: - Provider Instance

    @objc public var providerKitInstance: Any? {
        guard started else { return nil }
        return mixpanelInstance
    }

    // MARK: - Helpers

    private func execStatus(_ returnCode: MPKitReturnCode) -> MPKitExecStatus {
        return MPKitExecStatus(sdkCode: Self.kitCode(), returnCode: returnCode)
    }
}
