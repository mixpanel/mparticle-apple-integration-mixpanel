import XCTest
@testable import mParticle_Mixpanel
import mParticle_Apple_SDK

final class InitializationTests: XCTestCase {

    func testDidFinishLaunching_WithValidToken_ReturnsSuccess() {
        let kit = MPKitMixpanel()
        let config: [AnyHashable: Any] = [
            "token": "test-token-12345"
        ]

        let status = kit.didFinishLaunching(withConfiguration: config)

        XCTAssertEqual(status.returnCode, MPKitReturnCode.success)
        XCTAssertTrue(kit.started)
    }

    func testDidFinishLaunching_WithMissingToken_ReturnsRequirementsNotMet() {
        let kit = MPKitMixpanel()
        let config: [AnyHashable: Any] = [:]

        let status = kit.didFinishLaunching(withConfiguration: config)

        XCTAssertEqual(status.returnCode, MPKitReturnCode.requirementsNotMet)
        XCTAssertFalse(kit.started)
    }

    func testDidFinishLaunching_ParsesServerURL() {
        let kit = MPKitMixpanel()
        let config: [AnyHashable: Any] = [
            "token": "test-token",
            "serverURL": "https://custom.mixpanel.com"
        ]

        let status = kit.didFinishLaunching(withConfiguration: config)

        XCTAssertEqual(status.returnCode, MPKitReturnCode.success)
    }

    func testDidFinishLaunching_ParsesUseMixpanelPeopleTrue() {
        let kit = MPKitMixpanel()
        let config: [AnyHashable: Any] = [
            "token": "test-token",
            "useMixpanelPeople": "True"
        ]

        let status = kit.didFinishLaunching(withConfiguration: config)

        XCTAssertEqual(status.returnCode, MPKitReturnCode.success)
    }

    func testDidFinishLaunching_ParsesUserIdentificationType() {
        let kit = MPKitMixpanel()
        let config: [AnyHashable: Any] = [
            "token": "test-token",
            "userIdentificationType": "MPID"
        ]

        let status = kit.didFinishLaunching(withConfiguration: config)

        XCTAssertEqual(status.returnCode, MPKitReturnCode.success)
    }

    // MARK: - providerKitInstance Tests

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
}
