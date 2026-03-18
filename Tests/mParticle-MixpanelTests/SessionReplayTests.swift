import XCTest
@testable import mParticle_Mixpanel
import mParticle_Apple_SDK

final class SessionReplayTests: XCTestCase {

    // MARK: - Configuration Parsing: Default Values

    func testSessionReplayDefaults_WhenNotConfigured() {
        let kit = MPKitMixpanel()
        let config: [AnyHashable: Any] = ["token": "test-token"]
        _ = kit.didFinishLaunching(withConfiguration: config)

        XCTAssertFalse(kit.sessionReplayEnabled)
        XCTAssertEqual(kit.recordSessionsPercent, 100)
        XCTAssertTrue(kit.autoStartRecording)
        XCTAssertTrue(kit.wifiOnly)
        XCTAssertFalse(kit.enableMixpanelSessionReplayOniOS26)
        XCTAssertTrue(kit.maskImages)
        XCTAssertTrue(kit.maskText)
        XCTAssertTrue(kit.maskWebViews)
        XCTAssertTrue(kit.maskMaps)
    }

    // MARK: - Configuration Parsing: Explicit Values

    func testSessionReplayEnabled_ParsesTrue() {
        let kit = MPKitMixpanel()
        let config: [AnyHashable: Any] = [
            "token": "test-token",
            "sessionReplayEnabled": "true"
        ]
        _ = kit.didFinishLaunching(withConfiguration: config)

        XCTAssertTrue(kit.sessionReplayEnabled)
    }

    func testSessionReplayEnabled_ParsesFalse() {
        let kit = MPKitMixpanel()
        let config: [AnyHashable: Any] = [
            "token": "test-token",
            "sessionReplayEnabled": "false"
        ]
        _ = kit.didFinishLaunching(withConfiguration: config)

        XCTAssertFalse(kit.sessionReplayEnabled)
    }

    func testRecordSessionsPercent_ParsesValidValue() {
        let kit = MPKitMixpanel()
        let config: [AnyHashable: Any] = [
            "token": "test-token",
            "recordSessionsPercent": "50"
        ]
        _ = kit.didFinishLaunching(withConfiguration: config)

        XCTAssertEqual(kit.recordSessionsPercent, 50)
    }

    func testRecordSessionsPercent_ClampsToMax100() {
        let kit = MPKitMixpanel()
        let config: [AnyHashable: Any] = [
            "token": "test-token",
            "recordSessionsPercent": "200"
        ]
        _ = kit.didFinishLaunching(withConfiguration: config)

        XCTAssertEqual(kit.recordSessionsPercent, 100)
    }

    func testRecordSessionsPercent_ClampsToMin0() {
        let kit = MPKitMixpanel()
        let config: [AnyHashable: Any] = [
            "token": "test-token",
            "recordSessionsPercent": "-10"
        ]
        _ = kit.didFinishLaunching(withConfiguration: config)

        XCTAssertEqual(kit.recordSessionsPercent, 0)
    }

    // MARK: - Boolean Parsing: Default-true properties use != "false" pattern

    func testAutoStartRecording_DefaultsToTrue_WhenMissing() {
        let kit = MPKitMixpanel()
        let config: [AnyHashable: Any] = ["token": "test-token"]
        _ = kit.didFinishLaunching(withConfiguration: config)

        XCTAssertTrue(kit.autoStartRecording)
    }

    func testAutoStartRecording_RemainsTrue_ForNonFalseString() {
        let kit = MPKitMixpanel()
        let config: [AnyHashable: Any] = [
            "token": "test-token",
            "autoStartRecording": "yes"
        ]
        _ = kit.didFinishLaunching(withConfiguration: config)

        XCTAssertTrue(kit.autoStartRecording, "Non-'false' strings should preserve default true")
    }

    func testAutoStartRecording_SetsFalse_WhenExplicitlyFalse() {
        let kit = MPKitMixpanel()
        let config: [AnyHashable: Any] = [
            "token": "test-token",
            "autoStartRecording": "false"
        ]
        _ = kit.didFinishLaunching(withConfiguration: config)

        XCTAssertFalse(kit.autoStartRecording)
    }

    func testWifiOnly_DefaultsToTrue_WhenMissing() {
        let kit = MPKitMixpanel()
        let config: [AnyHashable: Any] = ["token": "test-token"]
        _ = kit.didFinishLaunching(withConfiguration: config)

        XCTAssertTrue(kit.wifiOnly)
    }

    func testWifiOnly_SetsFalse_WhenExplicitlyFalse() {
        let kit = MPKitMixpanel()
        let config: [AnyHashable: Any] = [
            "token": "test-token",
            "wifiOnly": "false"
        ]
        _ = kit.didFinishLaunching(withConfiguration: config)

        XCTAssertFalse(kit.wifiOnly)
    }

    // MARK: - Privacy Masking: Default-true properties

    func testMaskImages_DefaultsToTrue() {
        let kit = MPKitMixpanel()
        let config: [AnyHashable: Any] = ["token": "test-token"]
        _ = kit.didFinishLaunching(withConfiguration: config)

        XCTAssertTrue(kit.maskImages)
    }

    func testMaskImages_SetsFalse_WhenExplicitlyFalse() {
        let kit = MPKitMixpanel()
        let config: [AnyHashable: Any] = [
            "token": "test-token",
            "maskImages": "false"
        ]
        _ = kit.didFinishLaunching(withConfiguration: config)

        XCTAssertFalse(kit.maskImages)
    }

    func testMaskText_SetsFalse_WhenExplicitlyFalse() {
        let kit = MPKitMixpanel()
        let config: [AnyHashable: Any] = [
            "token": "test-token",
            "maskText": "false"
        ]
        _ = kit.didFinishLaunching(withConfiguration: config)

        XCTAssertFalse(kit.maskText)
    }

    func testMaskWebViews_SetsFalse_WhenExplicitlyFalse() {
        let kit = MPKitMixpanel()
        let config: [AnyHashable: Any] = [
            "token": "test-token",
            "maskWebViews": "false"
        ]
        _ = kit.didFinishLaunching(withConfiguration: config)

        XCTAssertFalse(kit.maskWebViews)
    }

    func testMaskMaps_SetsFalse_WhenExplicitlyFalse() {
        let kit = MPKitMixpanel()
        let config: [AnyHashable: Any] = [
            "token": "test-token",
            "maskMaps": "false"
        ]
        _ = kit.didFinishLaunching(withConfiguration: config)

        XCTAssertFalse(kit.maskMaps)
    }

    // MARK: - enableMixpanelSessionReplayOniOS26

    func testEnableiOS26_ParsesTrue() {
        let kit = MPKitMixpanel()
        let config: [AnyHashable: Any] = [
            "token": "test-token",
            "enableMixpanelSessionReplayOniOS26": "true"
        ]
        _ = kit.didFinishLaunching(withConfiguration: config)

        XCTAssertTrue(kit.enableMixpanelSessionReplayOniOS26)
    }

    func testEnableiOS26_DefaultsFalse() {
        let kit = MPKitMixpanel()
        let config: [AnyHashable: Any] = ["token": "test-token"]
        _ = kit.didFinishLaunching(withConfiguration: config)

        XCTAssertFalse(kit.enableMixpanelSessionReplayOniOS26)
    }

    // MARK: - Session Replay Provider Instance

    #if os(iOS)
    func testSessionReplayProviderInstance_WhenNotStarted_ReturnsNil() {
        let kit = MPKitMixpanel()

        let instance = kit.sessionReplayProviderInstance

        XCTAssertNil(instance)
    }

    func testSessionReplayProviderInstance_WhenDisabled_ReturnsNil() {
        let kit = MPKitMixpanel()
        let config: [AnyHashable: Any] = [
            "token": "test-token",
            "sessionReplayEnabled": "false"
        ]
        _ = kit.didFinishLaunching(withConfiguration: config)

        let instance = kit.sessionReplayProviderInstance

        XCTAssertNil(instance)
    }

    func testSessionReplayProviderInstance_WhenEnabled_BeforeAsyncInit_ReturnsNil() {
        let kit = MPKitMixpanel()
        let config: [AnyHashable: Any] = [
            "token": "test-token",
            "sessionReplayEnabled": "true"
        ]
        _ = kit.didFinishLaunching(withConfiguration: config)

        // Instance is nil because async initialization hasn't completed
        let instance = kit.sessionReplayProviderInstance

        XCTAssertNil(instance)
    }
    #endif

    // MARK: - Identity Methods with Session Replay Config

    func testOnIdentifyComplete_WithSessionReplayEnabled_ReturnsSuccess() {
        let kit = MPKitMixpanel()
        let config: [AnyHashable: Any] = [
            "token": "test-token",
            "sessionReplayEnabled": "true"
        ]
        _ = kit.didFinishLaunching(withConfiguration: config)

        let status = kit.onIdentifyComplete(.init(), request: .init())

        XCTAssertEqual(status.returnCode, MPKitReturnCode.success)
    }

    func testOnLoginComplete_WithSessionReplayEnabled_ReturnsSuccess() {
        let kit = MPKitMixpanel()
        let config: [AnyHashable: Any] = [
            "token": "test-token",
            "sessionReplayEnabled": "true"
        ]
        _ = kit.didFinishLaunching(withConfiguration: config)

        let status = kit.onLoginComplete(.init(), request: .init())

        XCTAssertEqual(status.returnCode, MPKitReturnCode.success)
    }

    func testOnLogoutComplete_WithSessionReplayEnabled_ReturnsSuccess() {
        let kit = MPKitMixpanel()
        let config: [AnyHashable: Any] = [
            "token": "test-token",
            "sessionReplayEnabled": "true"
        ]
        _ = kit.didFinishLaunching(withConfiguration: config)

        let status = kit.onLogoutComplete(.init(), request: .init())

        XCTAssertEqual(status.returnCode, MPKitReturnCode.success)
    }

    func testSetOptOut_WithSessionReplayEnabled_ReturnsSuccess() {
        let kit = MPKitMixpanel()
        let config: [AnyHashable: Any] = [
            "token": "test-token",
            "sessionReplayEnabled": "true"
        ]
        _ = kit.didFinishLaunching(withConfiguration: config)

        let optOutStatus = kit.setOptOut(true)
        XCTAssertEqual(optOutStatus.returnCode, MPKitReturnCode.success)

        let optInStatus = kit.setOptOut(false)
        XCTAssertEqual(optInStatus.returnCode, MPKitReturnCode.success)
    }

    // MARK: - Full Configuration Round-Trip

    func testFullSessionReplayConfig_ParsesAllValues() {
        let kit = MPKitMixpanel()
        let config: [AnyHashable: Any] = [
            "token": "test-token",
            "sessionReplayEnabled": "true",
            "recordSessionsPercent": "75",
            "autoStartRecording": "false",
            "wifiOnly": "false",
            "enableMixpanelSessionReplayOniOS26": "true",
            "maskImages": "false",
            "maskText": "false",
            "maskWebViews": "false",
            "maskMaps": "false"
        ]
        _ = kit.didFinishLaunching(withConfiguration: config)

        XCTAssertTrue(kit.sessionReplayEnabled)
        XCTAssertEqual(kit.recordSessionsPercent, 75)
        XCTAssertFalse(kit.autoStartRecording)
        XCTAssertFalse(kit.wifiOnly)
        XCTAssertTrue(kit.enableMixpanelSessionReplayOniOS26)
        XCTAssertFalse(kit.maskImages)
        XCTAssertFalse(kit.maskText)
        XCTAssertFalse(kit.maskWebViews)
        XCTAssertFalse(kit.maskMaps)
    }
}
