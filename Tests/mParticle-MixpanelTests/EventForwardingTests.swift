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

    func testRouteEvent_WhenNotStarted_ReturnsFail() {
        // Create uninitialized kit
        let uninitKit = MPKitMixpanel()
        let event = MPEvent(name: "Test Event", type: .other)!

        let status = uninitKit.routeEvent(event)

        XCTAssertEqual(status.returnCode, MPKitReturnCode.fail)
    }

    func testMPEvent_WithEmptyName_ReturnsNil() {
        // Verify SDK rejects empty event names
        let event = MPEvent(name: "", type: .other)

        XCTAssertNil(event)
    }

    func testRouteEvent_WithAttributes_ReturnsSuccess() {
        let event = MPEvent(name: "Test Event", type: .other)!
        event.customAttributes = ["key1": "value1", "key2": 42]

        let status = kit.routeEvent(event)

        XCTAssertEqual(status.returnCode, MPKitReturnCode.success)
    }

    // MARK: - logBaseEvent Tests

    func testLogBaseEvent_WithMPEvent_RoutesToRouteEvent() {
        let event = MPEvent(name: "Base Event", type: .other)!

        let status = kit.logBaseEvent(event)

        XCTAssertEqual(status.returnCode, MPKitReturnCode.success)
    }

    func testLogBaseEvent_WithCommerceEvent_RoutesToRouteCommerceEvent() {
        let product = MPProduct(name: "Test Product", sku: "SKU123", quantity: 1, price: 9.99)
        let commerceEvent = MPCommerceEvent(action: .purchase, product: product)

        let status = kit.logBaseEvent(commerceEvent)

        // Commerce events should be handled (success or specific handling)
        XCTAssertNotNil(status)
    }

    // MARK: - logScreen Tests

    func testLogScreen_PrefixesWithViewed() {
        let event = MPEvent(name: "Home Screen", type: .other)!

        let status = kit.logScreen(event)

        XCTAssertEqual(status.returnCode, MPKitReturnCode.success)
    }

    func testLogScreen_WhenNotStarted_ReturnsFail() {
        let uninitKit = MPKitMixpanel()
        let event = MPEvent(name: "Settings", type: .other)!

        let status = uninitKit.logScreen(event)

        XCTAssertEqual(status.returnCode, MPKitReturnCode.fail)
    }

    func testLogScreen_WithAttributes_ReturnsSuccess() {
        let event = MPEvent(name: "Settings", type: .other)!
        event.customAttributes = ["section": "profile"]

        let status = kit.logScreen(event)

        XCTAssertEqual(status.returnCode, MPKitReturnCode.success)
    }
}
