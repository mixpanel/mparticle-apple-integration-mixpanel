import XCTest
@testable import mParticle_Mixpanel
import mParticle_Apple_SDK

final class CommerceTests: XCTestCase {

    var kit: MPKitMixpanel!

    override func setUp() {
        super.setUp()
        kit = MPKitMixpanel()
        let config: [AnyHashable: Any] = [
            "token": "test-token",
            "useMixpanelPeople": "True"
        ]
        _ = kit.didFinishLaunching(withConfiguration: config)
    }

    override func tearDown() {
        kit = nil
        super.tearDown()
    }

    // MARK: - Purchase Event Tests

    func testRouteCommerceEvent_Purchase_TracksCharge() {
        let product = MPProduct(name: "Test Product", sku: "SKU123", quantity: 1, price: 29.99)
        let commerceEvent = MPCommerceEvent(action: .purchase, product: product)
        commerceEvent.transactionAttributes = MPTransactionAttributes()
        commerceEvent.transactionAttributes?.revenue = 29.99

        let status = kit.routeCommerceEvent(commerceEvent)

        XCTAssertEqual(status.returnCode, MPKitReturnCode.success)
    }

    func testRouteCommerceEvent_Purchase_WithoutPeopleMode() {
        let kit = MPKitMixpanel()
        let config: [AnyHashable: Any] = [
            "token": "test-token",
            "useMixpanelPeople": "False"
        ]
        _ = kit.didFinishLaunching(withConfiguration: config)

        let product = MPProduct(name: "Test Product", sku: "SKU123", quantity: 1, price: 29.99)
        let commerceEvent = MPCommerceEvent(action: .purchase, product: product)

        let status = kit.routeCommerceEvent(commerceEvent)

        // Should still work but not call people.trackCharge
        XCTAssertEqual(status.returnCode, MPKitReturnCode.success)
    }

    // MARK: - Non-Purchase Event Tests

    func testRouteCommerceEvent_AddToCart_ExpandsToEvents() {
        let product = MPProduct(name: "Test Product", sku: "SKU123", quantity: 1, price: 29.99)
        let commerceEvent = MPCommerceEvent(action: .addToCart, product: product)

        let status = kit.routeCommerceEvent(commerceEvent)

        // Non-purchase events should be expanded and tracked
        XCTAssertEqual(status.returnCode, MPKitReturnCode.success)
    }

    func testRouteCommerceEvent_RemoveFromCart_ExpandsToEvents() {
        let product = MPProduct(name: "Test Product", sku: "SKU123", quantity: 1, price: 29.99)
        let commerceEvent = MPCommerceEvent(action: .removeFromCart, product: product)

        let status = kit.routeCommerceEvent(commerceEvent)

        XCTAssertEqual(status.returnCode, MPKitReturnCode.success)
    }

    // MARK: - Not Started Tests

    func testRouteCommerceEvent_WhenNotStarted_ReturnsFail() {
        let uninitKit = MPKitMixpanel()
        let product = MPProduct(name: "Test Product", sku: "SKU123", quantity: 1, price: 29.99)
        let commerceEvent = MPCommerceEvent(action: .purchase, product: product)

        let status = uninitKit.routeCommerceEvent(commerceEvent)

        XCTAssertEqual(status.returnCode, MPKitReturnCode.fail)
    }
}
