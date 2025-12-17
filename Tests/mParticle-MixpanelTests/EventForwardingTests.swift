import XCTest
@testable import mParticle_Mixpanel
import mParticle_Apple_SDK

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

        XCTAssertEqual(status.returnCode, MPKitReturnCode.success)
    }

    func testRouteEvent_WithEmptyName_ReturnsFail() {
        let event = MPEvent(name: "", type: .other)!

        let status = kit.routeEvent(event)

        XCTAssertEqual(status.returnCode, MPKitReturnCode.fail)
    }

    func testRouteEvent_WithAttributes_ReturnsSuccess() {
        let event = MPEvent(name: "Test Event", type: .other)!
        event.customAttributes = ["key1": "value1", "key2": 42]

        let status = kit.routeEvent(event)

        XCTAssertEqual(status.returnCode, MPKitReturnCode.success)
    }
}
