import Foundation
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
        return NSNumber(value: 10)
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

    // MARK: - Event Forwarding

    @objc public func logBaseEvent(_ event: MPBaseEvent) -> MPKitExecStatus {
        switch event {
        case let mpEvent as MPEvent:
            return logEvent(mpEvent)
        case let commerceEvent as MPCommerceEvent:
            return logCommerceEvent(commerceEvent)
        default:
            return execStatus(.cannotExecute)
        }
    }

    @objc public func logEvent(_ event: MPEvent) -> MPKitExecStatus {
        guard started, let mixpanel = mixpanelInstance else {
            return execStatus(.fail)
        }

        let eventName = event.name
        guard !eventName.isEmpty else {
            return execStatus(.fail)
        }

        let properties = convertToMixpanelProperties(event.customAttributes)
        mixpanel.track(event: eventName, properties: properties)

        return execStatus(.success)
    }

    @objc public func logScreen(_ event: MPEvent) -> MPKitExecStatus {
        guard started, let mixpanel = mixpanelInstance else {
            return execStatus(.fail)
        }

        let screenName = event.name
        guard !screenName.isEmpty else {
            return execStatus(.fail)
        }

        let eventName = "Viewed \(screenName)"
        let properties = convertToMixpanelProperties(event.customAttributes)
        mixpanel.track(event: eventName, properties: properties)

        return execStatus(.success)
    }

    // MARK: - Commerce Events

    @objc public func logCommerceEvent(_ commerceEvent: MPCommerceEvent) -> MPKitExecStatus {
        guard started, let mixpanel = mixpanelInstance else {
            return execStatus(.fail)
        }

        let status = MPKitExecStatus(sdkCode: Self.kitCode(), returnCode: .success)

        // Handle Purchase events with People API
        if commerceEvent.action == .purchase {
            if useMixpanelPeople {
                let revenue = commerceEvent.transactionAttributes?.revenue?.doubleValue ?? 0.0
                let properties = convertToMixpanelProperties(commerceEvent.customAttributes)
                mixpanel.people.trackCharge(amount: revenue, properties: properties)
            }
            status.incrementForwardCount()
        } else {
            // Expand non-purchase commerce events to regular events
            if let expandedEvents = commerceEvent.expandedInstructions() {
                for instruction in expandedEvents {
                    _ = logEvent(instruction.event)
                    status.incrementForwardCount()
                }
            }
        }

        return status
    }

    // MARK: - Identity Handling

    @objc public func onIdentifyComplete(_ user: FilteredMParticleUser, request: FilteredMPIdentityApiRequest) -> MPKitExecStatus {
        guard started else { return execStatus(.fail) }

        if let userId = extractUserId(from: user) {
            mixpanelInstance?.identify(distinctId: userId)
        }

        return execStatus(.success)
    }

    @objc public func onLoginComplete(_ user: FilteredMParticleUser, request: FilteredMPIdentityApiRequest) -> MPKitExecStatus {
        guard started else { return execStatus(.fail) }

        if let userId = extractUserId(from: user) {
            mixpanelInstance?.identify(distinctId: userId)
        }

        return execStatus(.success)
    }

    @objc public func onLogoutComplete(_ user: FilteredMParticleUser, request: FilteredMPIdentityApiRequest) -> MPKitExecStatus {
        guard started else { return execStatus(.fail) }

        mixpanelInstance?.reset()

        return execStatus(.success)
    }

    @objc public func onModifyComplete(_ user: FilteredMParticleUser, request: FilteredMPIdentityApiRequest) -> MPKitExecStatus {
        guard started else { return execStatus(.fail) }

        if let userId = extractUserId(from: user) {
            mixpanelInstance?.identify(distinctId: userId)
        }

        return execStatus(.success)
    }

    // MARK: - User Attributes

    @objc public func onSetUserAttribute(_ user: FilteredMParticleUser) -> MPKitExecStatus {
        guard started, let mixpanel = mixpanelInstance else {
            return execStatus(.fail)
        }

        guard let changedAttribute = user.userAttributes.keys.first,
              let value = user.userAttributes[changedAttribute] else {
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

    @objc public func onRemoveUserAttribute(_ user: FilteredMParticleUser) -> MPKitExecStatus {
        guard started else {
            return execStatus(.fail)
        }

        // Note: mParticle provides the attribute key that was removed
        // For now, return success as we don't have the removed key in FilteredMParticleUser

        return execStatus(.success)
    }

    /// Increment a numeric user attribute by a given value
    /// Maps to Mixpanel's people.increment() when useMixpanelPeople is enabled
    @objc public func incrementUserAttribute(_ key: String, byValue value: NSNumber) -> MPKitExecStatus {
        guard started, let mixpanel = mixpanelInstance else {
            return execStatus(.fail)
        }

        // Only increment via People API - no super property equivalent for increment
        if useMixpanelPeople {
            mixpanel.people.increment(property: key, by: value.doubleValue)
        }

        return execStatus(.success)
    }

    /// Remove a user attribute by key
    /// Maps to Mixpanel's people.unset() or unregisterSuperProperty()
    @objc public func removeUserAttribute(_ key: String) -> MPKitExecStatus {
        guard started, let mixpanel = mixpanelInstance else {
            return execStatus(.fail)
        }

        if useMixpanelPeople {
            mixpanel.people.unset(properties: [key])
        } else {
            mixpanel.unregisterSuperProperty(key)
        }

        return execStatus(.success)
    }

    /// Set a user attribute with an array of values
    /// Maps to Mixpanel's people.set() or registerSuperProperties() with array value
    @objc public func setUserAttribute(_ key: String, values: [Any]) -> MPKitExecStatus {
        guard started, let mixpanel = mixpanelInstance else {
            return execStatus(.fail)
        }

        // Convert array to MixpanelType array
        let mixpanelValues = values.compactMap { $0 as? MixpanelType }

        if useMixpanelPeople {
            mixpanel.people.set(property: key, to: mixpanelValues)
        } else {
            mixpanel.registerSuperProperties([key: mixpanelValues])
        }

        return execStatus(.success)
    }

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

    // MARK: - Identity Helpers

    private func extractUserId(from user: FilteredMParticleUser?) -> String? {
        guard let user = user else { return nil }

        let userIdentities = user.userIdentities

        switch userIdentificationType {
        case .customerId:
            return userIdentities[NSNumber(value: MPUserIdentity.customerId.rawValue)]
        case .mpid:
            return user.userId.stringValue
        case .other:
            return userIdentities[NSNumber(value: MPUserIdentity.other.rawValue)]
        case .other2:
            return userIdentities[NSNumber(value: MPUserIdentity.other2.rawValue)]
        case .other3:
            return userIdentities[NSNumber(value: MPUserIdentity.other3.rawValue)]
        case .other4:
            return userIdentities[NSNumber(value: MPUserIdentity.other4.rawValue)]
        }
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

// MARK: - Public API for direct access

extension MPKitMixpanel {
    /// Route an MPEvent to Mixpanel (public API for tests and direct access)
    @objc public func routeEvent(_ event: MPEvent) -> MPKitExecStatus {
        return logEvent(event)
    }

    /// Route a commerce event to Mixpanel (public API for tests and direct access)
    @objc public func routeCommerceEvent(_ commerceEvent: MPCommerceEvent) -> MPKitExecStatus {
        return logCommerceEvent(commerceEvent)
    }
}
