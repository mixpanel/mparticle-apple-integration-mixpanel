import Foundation
import Mixpanel
import mParticle_Apple_SDK

#if os(iOS)
    import MixpanelSessionReplay
#endif

/// Configuration keys for Mixpanel Kit
private enum ConfigurationKey {
    static let token = "token"
    static let baseUrl = "baseUrl"
    static let userIdentificationType = "userIdentificationType"
    static let useMixpanelPeople = "useMixpanelPeople"

    // Session Replay - Essential
    static let sessionReplayEnabled = "sessionReplayEnabled"
    static let recordSessionsPercent = "recordSessionsPercent"
    static let autoStartRecording = "autoStartRecording"
    static let wifiOnly = "wifiOnly"
    static let enableMixpanelSessionReplayOniOS26 = "enableMixpanelSessionReplayOniOS26"

    // Session Replay - Privacy/Masking
    static let maskImages = "maskImages"
    static let maskText = "maskText"
    static let maskWebViews = "maskWebViews"
    static let maskMaps = "maskMaps"
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

    // MARK: - Session Replay Configuration

    private var sessionReplayEnabled: Bool = false
    private var recordSessionsPercent: Int = 100
    private var autoStartRecording: Bool = true
    private var wifiOnly: Bool = true
    private var enableMixpanelSessionReplayOniOS26: Bool = false

    // Privacy/Masking (all default true for privacy-first)
    private var maskImages: Bool = true
    private var maskText: Bool = true
    private var maskWebViews: Bool = true
    private var maskMaps: Bool = true

    // MARK: - Mixpanel Instance

    private var mixpanelInstance: MixpanelInstance?

    #if os(iOS)
        private var _sessionReplayInstance: MPSessionReplayInstance?
        /// Queued distinct ID for identity sync during async initialization
        private var pendingDistinctId: String?
        /// Flag indicating opt-in was requested during async initialization
        private var pendingStartRecording: Bool = false
    #endif

    // MARK: - Kit Code

    /// Mixpanel Kit Code assigned by mParticle
    @objc public static func kitCode() -> NSNumber {
        return NSNumber(value: 10)
    }

    // MARK: - MPKitProtocol Lifecycle

    @objc public func didFinishLaunching(withConfiguration configuration: [AnyHashable: Any])
        -> MPKitExecStatus
    {
        // Store configuration
        self.configuration = configuration

        // Parse required token
        guard let token = configuration[ConfigurationKey.token] as? String, !token.isEmpty else {
            return execStatus(.requirementsNotMet)
        }
        self.token = token

        // Parse optional base URL (Mixpanel Target Server endpoint)
        if let baseUrl = configuration[ConfigurationKey.baseUrl] as? String, !baseUrl.isEmpty {
            self.serverURL = baseUrl
        }

        // Parse user identification type (default: CustomerId)
        if let typeString = configuration[ConfigurationKey.userIdentificationType] as? String,
            let type = UserIdentificationType(rawValue: typeString)
        {
            self.userIdentificationType = type
        }

        // Parse useMixpanelPeople (default: true)
        if let peopleString = configuration[ConfigurationKey.useMixpanelPeople] as? String {
            self.useMixpanelPeople = peopleString.lowercased() == "true"
        }

        // Parse Session Replay configuration
        parseMPSessionReplayConfiguration(configuration)

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

        #if os(iOS)
            initializeSessionReplayIfEnabled()
        #endif

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

    private func parseMPSessionReplayConfiguration(_ configuration: [AnyHashable: Any]) {
        // Session Replay enabled (default: false)
        if let enabledString = configuration[ConfigurationKey.sessionReplayEnabled] as? String {
            self.sessionReplayEnabled = enabledString.lowercased() == "true"
        }

        // Record sessions percent (default: 100, clamped to 0-100)
        if let percentString = configuration[ConfigurationKey.recordSessionsPercent] as? String,
            let percent = Int(percentString)
        {
            self.recordSessionsPercent = max(0, min(100, percent))
        }

        // Auto start recording (default: true)
        if let autoStartString = configuration[ConfigurationKey.autoStartRecording] as? String {
            self.autoStartRecording = autoStartString.lowercased() == "true"
        }

        // WiFi only (default: true)
        if let wifiOnlyString = configuration[ConfigurationKey.wifiOnly] as? String {
            self.wifiOnly = wifiOnlyString.lowercased() == "true"
        }

        // Enable on iOS 26+ (default: false)
        if let ios26String = configuration[ConfigurationKey.enableMixpanelSessionReplayOniOS26]
            as? String
        {
            self.enableMixpanelSessionReplayOniOS26 = ios26String.lowercased() == "true"
        }

        // Privacy/Masking settings (all default: true)
        if let maskImagesString = configuration[ConfigurationKey.maskImages] as? String {
            self.maskImages = maskImagesString.lowercased() != "false"
        }

        if let maskTextString = configuration[ConfigurationKey.maskText] as? String {
            self.maskText = maskTextString.lowercased() != "false"
        }

        if let maskWebViewsString = configuration[ConfigurationKey.maskWebViews] as? String {
            self.maskWebViews = maskWebViewsString.lowercased() != "false"
        }

        if let maskMapsString = configuration[ConfigurationKey.maskMaps] as? String {
            self.maskMaps = maskMapsString.lowercased() != "false"
        }
    }

    #if os(iOS)
        private func initializeSessionReplayIfEnabled() {
            guard sessionReplayEnabled,
                let mixpanel = mixpanelInstance
            else { return }

            // Build autoMaskedViews set from config
            var autoMaskedViews: Set<MPAutoMaskedViews> = []
            if maskImages { autoMaskedViews.insert(.image) }
            if maskText { autoMaskedViews.insert(.text) }
            if maskWebViews { autoMaskedViews.insert(.web) }
            if maskMaps { autoMaskedViews.insert(.map) }

            let config = MPSessionReplayConfig(
                wifiOnly: wifiOnly,
                autoMaskedViews: autoMaskedViews,
                autoStartRecording: autoStartRecording,
                recordingSessionsPercent: Double(recordSessionsPercent),
                enableSessionReplayOniOS26AndLater: enableMixpanelSessionReplayOniOS26
            )

            // Initialize Session Replay asynchronously
            MPSessionReplay.initialize(
                token: mixpanel.apiToken,
                distinctId: mixpanel.distinctId,
                config: config
            ) { [weak self] result in
                // Dispatch to main thread to avoid data races with pendingDistinctId/pendingStartRecording
                // which are accessed from main-thread SDK callbacks
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    switch result {
                    case .success(let replayInstanceOptional):
                        guard let replayInstance = replayInstanceOptional else {
                            NSLog(
                                "[MPKitMixpanel] Session Replay initialization returned nil instance"
                            )
                            return
                        }
                        self._sessionReplayInstance = replayInstance
                        // Drain any pending identity updates that occurred during initialization
                        if let pendingId = self.pendingDistinctId {
                            replayInstance.identify(distinctId: pendingId)
                            self.pendingDistinctId = nil
                        }
                        // Drain pending opt-in start recording request
                        if self.pendingStartRecording {
                            replayInstance.startRecording()
                            self.pendingStartRecording = false
                        }
                    case .failure(let error):
                        // Log failure for diagnostics - analytics continues without Session Replay
                        NSLog(
                            "[MPKitMixpanel] Session Replay initialization failed: %@",
                            error.localizedDescription)
                    }
                }
            }
        }

        /// Syncs identity to Session Replay, queuing if initialization is still in progress
        private func syncSessionReplayIdentity(_ distinctId: String) {
            guard sessionReplayEnabled else { return }
            if let instance = _sessionReplayInstance {
                instance.identify(distinctId: distinctId)
            } else {
                // Queue identity update for when initialization completes
                pendingDistinctId = distinctId
            }
        }
    #endif

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

        // Expand all commerce events (including purchases) to regular events
        // Note: trackCharge is deprecated by Mixpanel - commerce events should be tracked as regular events
        if let expandedEvents = commerceEvent.expandedInstructions() {
            for instruction in expandedEvents {
                guard let event = instruction.event else { continue }

                let properties = buildCommerceEventProperties(
                    expandedEvent: event,
                    commerceEvent: commerceEvent
                )

                mixpanel.track(event: event.name, properties: properties.isEmpty ? nil : properties)
                status.incrementForwardCount()
            }
        }

        return status
    }

    /// Builds Mixpanel properties from expanded commerce event and original commerce event
    /// Combines: expanded event attributes, commerce event custom attributes, and transaction attributes
    internal func buildCommerceEventProperties(
        expandedEvent: MPEvent,
        commerceEvent: MPCommerceEvent
    ) -> [String: MixpanelType] {
        var properties: [String: MixpanelType] = [:]

        // Add expanded event's custom attributes (contains product info)
        if let eventAttrs = expandedEvent.customAttributes {
            for (key, value) in eventAttrs {
                if let mixpanelValue = value as? MixpanelType {
                    properties[key] = mixpanelValue
                }
            }
        }

        // Add commerce event's custom attributes
        if let commerceAttrs = commerceEvent.customAttributes {
            for (key, value) in commerceAttrs {
                if let mixpanelValue = value as? MixpanelType {
                    properties[key] = mixpanelValue
                }
            }
        }

        // Add transaction attributes
        if let transactionAttrs = commerceEvent.transactionAttributes {
            if let revenue = transactionAttrs.revenue?.doubleValue {
                properties["Revenue"] = revenue
            }
            if let transactionId = transactionAttrs.transactionId {
                properties["Transaction Id"] = transactionId
            }
            if let tax = transactionAttrs.tax?.doubleValue {
                properties["Tax"] = tax
            }
            if let shipping = transactionAttrs.shipping?.doubleValue {
                properties["Shipping"] = shipping
            }
            if let couponCode = transactionAttrs.couponCode {
                properties["Coupon Code"] = couponCode
            }
        }

        return properties
    }

    // MARK: - Identity Handling

    @objc public func onIdentifyComplete(
        _ user: FilteredMParticleUser, request: FilteredMPIdentityApiRequest
    ) -> MPKitExecStatus {
        guard started else { return execStatus(.fail) }

        if let userId = extractUserId(from: user) {
            mixpanelInstance?.identify(distinctId: userId)
            #if os(iOS)
                syncSessionReplayIdentity(userId)
            #endif
        }

        return execStatus(.success)
    }

    @objc public func onLoginComplete(
        _ user: FilteredMParticleUser, request: FilteredMPIdentityApiRequest
    ) -> MPKitExecStatus {
        guard started else { return execStatus(.fail) }

        if let userId = extractUserId(from: user) {
            mixpanelInstance?.identify(distinctId: userId)
            #if os(iOS)
                syncSessionReplayIdentity(userId)
            #endif
        }

        return execStatus(.success)
    }

    @objc public func onLogoutComplete(
        _ user: FilteredMParticleUser, request: FilteredMPIdentityApiRequest
    ) -> MPKitExecStatus {
        guard started else { return execStatus(.fail) }

        mixpanelInstance?.reset()
        #if os(iOS)
            _sessionReplayInstance?.stopRecording()
        #endif

        return execStatus(.success)
    }

    @objc public func onModifyComplete(
        _ user: FilteredMParticleUser, request: FilteredMPIdentityApiRequest
    ) -> MPKitExecStatus {
        guard started else { return execStatus(.fail) }

        if let userId = extractUserId(from: user) {
            mixpanelInstance?.identify(distinctId: userId)
            #if os(iOS)
                syncSessionReplayIdentity(userId)
            #endif
        }

        return execStatus(.success)
    }

    // MARK: - User Attributes

    @objc public func onSetUserAttribute(_ user: FilteredMParticleUser) -> MPKitExecStatus {
        guard started, let mixpanel = mixpanelInstance else {
            return execStatus(.fail)
        }

        for (key, value) in user.userAttributes {
            let mixpanelKey = Self.mixpanelProfileKey(for: key)
            if useMixpanelPeople {
                if let mixpanelValue = value as? MixpanelType {
                    mixpanel.people.set(property: mixpanelKey, to: mixpanelValue)
                }
            } else {
                if let mixpanelValue = value as? MixpanelType {
                    mixpanel.registerSuperProperties([mixpanelKey: mixpanelValue])
                }
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
    @objc public func incrementUserAttribute(_ key: String, byValue value: NSNumber)
        -> MPKitExecStatus
    {
        guard started, let mixpanel = mixpanelInstance else {
            return execStatus(.fail)
        }

        // Only increment via People API - no super property equivalent for increment
        if useMixpanelPeople {
            mixpanel.people.increment(property: Self.mixpanelProfileKey(for: key), by: value.doubleValue)
        }

        return execStatus(.success)
    }

    /// Remove a user attribute by key
    /// Maps to Mixpanel's people.unset() or unregisterSuperProperty()
    @objc public func removeUserAttribute(_ key: String) -> MPKitExecStatus {
        guard started, let mixpanel = mixpanelInstance else {
            return execStatus(.fail)
        }

        let mixpanelKey = Self.mixpanelProfileKey(for: key)
        if useMixpanelPeople {
            mixpanel.people.unset(properties: [mixpanelKey])
        } else {
            mixpanel.unregisterSuperProperty(mixpanelKey)
        }

        return execStatus(.success)
    }

    /// Set a user attribute with a single value, uses reserved-attribute mapping.
    @objc public func setUserAttribute(_ key: String, value: Any) -> MPKitExecStatus {
        guard started, let mixpanel = mixpanelInstance else {
            return execStatus(.fail)
        }

        let mixpanelKey = Self.mixpanelProfileKey(for: key)
        guard let mixpanelValue = value as? MixpanelType else {
            return execStatus(.success)
        }

        if useMixpanelPeople {
            mixpanel.people.set(property: mixpanelKey, to: mixpanelValue)
        } else {
            mixpanel.registerSuperProperties([mixpanelKey: mixpanelValue])
        }

        return execStatus(.success)
    }

    /// Set a user attribute with an array of values
    /// Maps to Mixpanel's people.set() or registerSuperProperties() with array value
    @objc public func setUserAttribute(_ key: String, values: [Any]) -> MPKitExecStatus {
        guard started, let mixpanel = mixpanelInstance else {
            return execStatus(.fail)
        }

        let mixpanelKey = Self.mixpanelProfileKey(for: key)
        let mixpanelValues = values.compactMap { $0 as? MixpanelType }

        if useMixpanelPeople {
            mixpanel.people.set(property: mixpanelKey, to: mixpanelValues)
        } else {
            mixpanel.registerSuperProperties([mixpanelKey: mixpanelValues])
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
            #if os(iOS)
                _sessionReplayInstance?.stopRecording()
                // Clear any pending start recording request
                pendingStartRecording = false
            #endif
        } else {
            mixpanel.optInTracking()
            #if os(iOS)
                if sessionReplayEnabled && autoStartRecording {
                    if let instance = _sessionReplayInstance {
                        instance.startRecording()
                    } else {
                        // Queue start recording for when initialization completes
                        pendingStartRecording = true
                    }
                }
            #endif
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

    #if os(iOS)
        /// Access to the underlying Session Replay instance for advanced control.
        /// Returns nil if Session Replay is not enabled or not initialized.
        @objc public var sessionReplayProviderInstance: Any? {
            guard started, sessionReplayEnabled else { return nil }
            return _sessionReplayInstance
        }
    #endif

    // MARK: - Helpers

    private func execStatus(_ returnCode: MPKitReturnCode) -> MPKitExecStatus {
        return MPKitExecStatus(sdkCode: Self.kitCode(), returnCode: returnCode)
    }

    /// mParticle reserved keys mapped to Mixpanel reserved user attribute keys.
    /// https://docs.mixpanel.com/docs/data-structure/property-reference/reserved-properties
    private static let reservedKeyToMixpanel: [String: String] = [
        "$FirstName": "$first_name",
        "$LastName": "$last_name",
        "$Email": "$email",
        "$Mobile": "$phone",
        "$Country": "$country_code",
        "$City": "$city",
        "$State": "$region"
    ]

    /// Returns the Mixpanel profile key for a given mParticle reserved attribute key
    internal static func mixpanelProfileKey(for key: String) -> String {
        return reservedKeyToMixpanel[key] ?? key
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
