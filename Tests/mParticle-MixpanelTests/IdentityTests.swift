import XCTest
@testable import mParticle_Mixpanel
import mParticle_Apple_SDK

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

    // MARK: - Identity Complete Methods

    func testOnLoginComplete_ReturnsSuccess() {
        let status = kit.onLoginComplete(.init(), request: .init())

        XCTAssertEqual(status.returnCode, MPKitReturnCode.success)
    }

    func testOnLogoutComplete_ReturnsSuccess() {
        let status = kit.onLogoutComplete(.init(), request: .init())

        XCTAssertEqual(status.returnCode, MPKitReturnCode.success)
    }

    func testOnIdentifyComplete_ReturnsSuccess() {
        let status = kit.onIdentifyComplete(.init(), request: .init())

        XCTAssertEqual(status.returnCode, MPKitReturnCode.success)
    }

    func testOnModifyComplete_ReturnsSuccess() {
        let status = kit.onModifyComplete(.init(), request: .init())

        XCTAssertEqual(status.returnCode, MPKitReturnCode.success)
    }

    // MARK: - Not Started Tests

    func testOnLoginComplete_WhenNotStarted_ReturnsFail() {
        let uninitKit = MPKitMixpanel()

        let status = uninitKit.onLoginComplete(.init(), request: .init())

        XCTAssertEqual(status.returnCode, MPKitReturnCode.fail)
    }

    func testOnLogoutComplete_WhenNotStarted_ReturnsFail() {
        let uninitKit = MPKitMixpanel()

        let status = uninitKit.onLogoutComplete(.init(), request: .init())

        XCTAssertEqual(status.returnCode, MPKitReturnCode.fail)
    }
}
