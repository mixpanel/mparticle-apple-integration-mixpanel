import XCTest
@testable import mParticle_Mixpanel
import mParticle_Apple_SDK
import Mixpanel

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

    func testRouteCommerceEvent_Purchase_ExpandsToEvents() {
        let product = MPProduct(name: "Test Product", sku: "SKU123", quantity: 1, price: 29.99)
        let commerceEvent = MPCommerceEvent(action: .purchase, product: product)
        commerceEvent.transactionAttributes = MPTransactionAttributes()
        commerceEvent.transactionAttributes?.revenue = 29.99

        let status = kit.routeCommerceEvent(commerceEvent)

        // Purchase events are now expanded to regular events (trackCharge is deprecated)
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

        // Should expand to regular events regardless of useMixpanelPeople setting
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

    // MARK: - Property Building Tests

    func testBuildCommerceEventProperties_IncludesExpandedEventAttributes() {
        let expandedEvent = MPEvent(name: "eCommerce - purchase - Item", type: .transaction)
        expandedEvent?.customAttributes = [
            "Name": "Test Product",
            "SKU": "SKU123",
            "Price": 29.99,
            "Quantity": 1
        ]

        let commerceEvent = MPCommerceEvent(action: .purchase, product: MPProduct())

        let properties = kit.buildCommerceEventProperties(
            expandedEvent: expandedEvent!,
            commerceEvent: commerceEvent
        )

        XCTAssertEqual(properties["Name"] as? String, "Test Product")
        XCTAssertEqual(properties["SKU"] as? String, "SKU123")
        XCTAssertEqual(properties["Price"] as? Double, 29.99)
        XCTAssertEqual(properties["Quantity"] as? Int, 1)
    }

    func testBuildCommerceEventProperties_IncludesCommerceEventCustomAttributes() {
        let expandedEvent = MPEvent(name: "eCommerce - purchase - Item", type: .transaction)

        let commerceEvent = MPCommerceEvent(action: .purchase, product: MPProduct())
        commerceEvent.customAttributes = [
            "campaign": "summer_sale",
            "source": "mobile_app"
        ]

        let properties = kit.buildCommerceEventProperties(
            expandedEvent: expandedEvent!,
            commerceEvent: commerceEvent
        )

        XCTAssertEqual(properties["campaign"] as? String, "summer_sale")
        XCTAssertEqual(properties["source"] as? String, "mobile_app")
    }

    func testBuildCommerceEventProperties_IncludesRevenue() {
        let expandedEvent = MPEvent(name: "eCommerce - purchase - Item", type: .transaction)

        let commerceEvent = MPCommerceEvent(action: .purchase, product: MPProduct())
        commerceEvent.transactionAttributes = MPTransactionAttributes()
        commerceEvent.transactionAttributes?.revenue = 99.99

        let properties = kit.buildCommerceEventProperties(
            expandedEvent: expandedEvent!,
            commerceEvent: commerceEvent
        )

        XCTAssertEqual(properties["Revenue"] as? Double, 99.99)
    }

    func testBuildCommerceEventProperties_IncludesAllTransactionAttributes() {
        let expandedEvent = MPEvent(name: "eCommerce - purchase - Item", type: .transaction)

        let commerceEvent = MPCommerceEvent(action: .purchase, product: MPProduct())
        commerceEvent.transactionAttributes = MPTransactionAttributes()
        commerceEvent.transactionAttributes?.revenue = 109.99
        commerceEvent.transactionAttributes?.transactionId = "TXN-12345"
        commerceEvent.transactionAttributes?.tax = 8.50
        commerceEvent.transactionAttributes?.shipping = 5.99
        commerceEvent.transactionAttributes?.couponCode = "SAVE10"

        let properties = kit.buildCommerceEventProperties(
            expandedEvent: expandedEvent!,
            commerceEvent: commerceEvent
        )

        XCTAssertEqual(properties["Revenue"] as? Double, 109.99)
        XCTAssertEqual(properties["Transaction Id"] as? String, "TXN-12345")
        XCTAssertEqual(properties["Tax"] as? Double, 8.50)
        XCTAssertEqual(properties["Shipping"] as? Double, 5.99)
        XCTAssertEqual(properties["Coupon Code"] as? String, "SAVE10")
    }

    func testBuildCommerceEventProperties_CombinesAllSources() {
        // Expanded event with product attributes
        let expandedEvent = MPEvent(name: "eCommerce - purchase - Item", type: .transaction)
        expandedEvent?.customAttributes = [
            "Name": "Premium Widget",
            "SKU": "WIDGET-001"
        ]

        // Commerce event with custom attributes
        let commerceEvent = MPCommerceEvent(action: .purchase, product: MPProduct())
        commerceEvent.customAttributes = [
            "campaign": "holiday_promo"
        ]

        // Transaction attributes
        commerceEvent.transactionAttributes = MPTransactionAttributes()
        commerceEvent.transactionAttributes?.revenue = 49.99
        commerceEvent.transactionAttributes?.transactionId = "ORDER-789"

        let properties = kit.buildCommerceEventProperties(
            expandedEvent: expandedEvent!,
            commerceEvent: commerceEvent
        )

        // Verify all sources are combined
        XCTAssertEqual(properties["Name"] as? String, "Premium Widget")
        XCTAssertEqual(properties["SKU"] as? String, "WIDGET-001")
        XCTAssertEqual(properties["campaign"] as? String, "holiday_promo")
        XCTAssertEqual(properties["Revenue"] as? Double, 49.99)
        XCTAssertEqual(properties["Transaction Id"] as? String, "ORDER-789")
    }

    func testBuildCommerceEventProperties_EmptyWhenNoAttributes() {
        let expandedEvent = MPEvent(name: "eCommerce - purchase - Item", type: .transaction)
        let commerceEvent = MPCommerceEvent(action: .purchase, product: MPProduct())

        let properties = kit.buildCommerceEventProperties(
            expandedEvent: expandedEvent!,
            commerceEvent: commerceEvent
        )

        XCTAssertTrue(properties.isEmpty)
    }

    func testBuildCommerceEventProperties_CommerceAttributesOverrideExpandedAttributes() {
        // If same key exists in both, commerce event's custom attributes should win
        let expandedEvent = MPEvent(name: "eCommerce - purchase - Item", type: .transaction)
        expandedEvent?.customAttributes = [
            "source": "product_level"
        ]

        let commerceEvent = MPCommerceEvent(action: .purchase, product: MPProduct())
        commerceEvent.customAttributes = [
            "source": "commerce_level"
        ]

        let properties = kit.buildCommerceEventProperties(
            expandedEvent: expandedEvent!,
            commerceEvent: commerceEvent
        )

        // Commerce event attributes are added after, so they override
        XCTAssertEqual(properties["source"] as? String, "commerce_level")
    }
}
