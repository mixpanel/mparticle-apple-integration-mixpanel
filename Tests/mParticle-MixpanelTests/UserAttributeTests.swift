import XCTest
@testable import mParticle_Mixpanel
import mParticle_Apple_SDK

final class UserAttributeTests: XCTestCase {

    // MARK: - onSetUserAttribute Tests

    func testOnSetUserAttribute_WithPeopleMode_ReturnsSuccess() {
        let kit = MPKitMixpanel()
        let config: [AnyHashable: Any] = [
            "token": "test-token",
            "useMixpanelPeople": "True"
        ]
        _ = kit.didFinishLaunching(withConfiguration: config)

        let status = kit.onSetUserAttribute(.init())

        XCTAssertEqual(status.returnCode, MPKitReturnCode.success)
    }

    func testOnSetUserAttribute_WithSuperPropsMode_ReturnsSuccess() {
        let kit = MPKitMixpanel()
        let config: [AnyHashable: Any] = [
            "token": "test-token",
            "useMixpanelPeople": "False"
        ]
        _ = kit.didFinishLaunching(withConfiguration: config)

        let status = kit.onSetUserAttribute(.init())

        XCTAssertEqual(status.returnCode, MPKitReturnCode.success)
    }

    func testOnSetUserAttribute_WhenNotStarted_ReturnsFail() {
        let kit = MPKitMixpanel()

        let status = kit.onSetUserAttribute(.init())

        XCTAssertEqual(status.returnCode, MPKitReturnCode.fail)
    }

    // MARK: - onRemoveUserAttribute Tests

    func testOnRemoveUserAttribute_ReturnsSuccess() {
        let kit = MPKitMixpanel()
        let config: [AnyHashable: Any] = ["token": "test-token"]
        _ = kit.didFinishLaunching(withConfiguration: config)

        let status = kit.onRemoveUserAttribute(.init())

        XCTAssertEqual(status.returnCode, MPKitReturnCode.success)
    }

    func testOnRemoveUserAttribute_WhenNotStarted_ReturnsFail() {
        let kit = MPKitMixpanel()

        let status = kit.onRemoveUserAttribute(.init())

        XCTAssertEqual(status.returnCode, MPKitReturnCode.fail)
    }
}
