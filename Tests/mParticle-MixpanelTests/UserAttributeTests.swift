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

    // MARK: - incrementUserAttribute Tests (NEW - TDD)

    func testIncrementUserAttribute_WhenStarted_ReturnsSuccess() {
        let kit = MPKitMixpanel()
        let config: [AnyHashable: Any] = [
            "token": "test-token",
            "useMixpanelPeople": "True"
        ]
        _ = kit.didFinishLaunching(withConfiguration: config)

        let status = kit.incrementUserAttribute("login_count", byValue: NSNumber(value: 1))

        XCTAssertEqual(status.returnCode, MPKitReturnCode.success)
    }

    func testIncrementUserAttribute_WhenNotStarted_ReturnsFail() {
        let kit = MPKitMixpanel()

        let status = kit.incrementUserAttribute("login_count", byValue: NSNumber(value: 1))

        XCTAssertEqual(status.returnCode, MPKitReturnCode.fail)
    }

    func testIncrementUserAttribute_WithNegativeValue_ReturnsSuccess() {
        let kit = MPKitMixpanel()
        let config: [AnyHashable: Any] = [
            "token": "test-token",
            "useMixpanelPeople": "True"
        ]
        _ = kit.didFinishLaunching(withConfiguration: config)

        let status = kit.incrementUserAttribute("credits", byValue: NSNumber(value: -5))

        XCTAssertEqual(status.returnCode, MPKitReturnCode.success)
    }

    func testIncrementUserAttribute_WhenPeopleDisabled_ReturnsSuccess() {
        let kit = MPKitMixpanel()
        let config: [AnyHashable: Any] = [
            "token": "test-token",
            "useMixpanelPeople": "False"
        ]
        _ = kit.didFinishLaunching(withConfiguration: config)

        // Should still succeed but won't call people.increment (no super property equivalent)
        let status = kit.incrementUserAttribute("login_count", byValue: NSNumber(value: 1))

        XCTAssertEqual(status.returnCode, MPKitReturnCode.success)
    }

    // MARK: - removeUserAttribute (key-based) Tests (NEW - TDD)

    func testRemoveUserAttribute_WhenStarted_ReturnsSuccess() {
        let kit = MPKitMixpanel()
        let config: [AnyHashable: Any] = [
            "token": "test-token",
            "useMixpanelPeople": "True"
        ]
        _ = kit.didFinishLaunching(withConfiguration: config)

        let status = kit.removeUserAttribute("old_attribute")

        XCTAssertEqual(status.returnCode, MPKitReturnCode.success)
    }

    func testRemoveUserAttribute_WhenNotStarted_ReturnsFail() {
        let kit = MPKitMixpanel()

        let status = kit.removeUserAttribute("old_attribute")

        XCTAssertEqual(status.returnCode, MPKitReturnCode.fail)
    }

    func testRemoveUserAttribute_WhenPeopleDisabled_ReturnsSuccess() {
        let kit = MPKitMixpanel()
        let config: [AnyHashable: Any] = [
            "token": "test-token",
            "useMixpanelPeople": "False"
        ]
        _ = kit.didFinishLaunching(withConfiguration: config)

        // Should call unregisterSuperProperty instead
        let status = kit.removeUserAttribute("old_attribute")

        XCTAssertEqual(status.returnCode, MPKitReturnCode.success)
    }

    // MARK: - setUserAttribute:values: (array) Tests (NEW - TDD)

    func testSetUserAttributeValues_WhenStarted_ReturnsSuccess() {
        let kit = MPKitMixpanel()
        let config: [AnyHashable: Any] = [
            "token": "test-token",
            "useMixpanelPeople": "True"
        ]
        _ = kit.didFinishLaunching(withConfiguration: config)

        let status = kit.setUserAttribute("favorite_colors", values: ["red", "blue", "green"])

        XCTAssertEqual(status.returnCode, MPKitReturnCode.success)
    }

    func testSetUserAttributeValues_WhenNotStarted_ReturnsFail() {
        let kit = MPKitMixpanel()

        let status = kit.setUserAttribute("favorite_colors", values: ["red", "blue"])

        XCTAssertEqual(status.returnCode, MPKitReturnCode.fail)
    }

    func testSetUserAttributeValues_WhenPeopleDisabled_ReturnsSuccess() {
        let kit = MPKitMixpanel()
        let config: [AnyHashable: Any] = [
            "token": "test-token",
            "useMixpanelPeople": "False"
        ]
        _ = kit.didFinishLaunching(withConfiguration: config)

        // Should use registerSuperProperties with array value
        let status = kit.setUserAttribute("tags", values: ["vip", "early_adopter"])

        XCTAssertEqual(status.returnCode, MPKitReturnCode.success)
    }

    func testSetUserAttributeValues_WithEmptyArray_ReturnsSuccess() {
        let kit = MPKitMixpanel()
        let config: [AnyHashable: Any] = [
            "token": "test-token",
            "useMixpanelPeople": "True"
        ]
        _ = kit.didFinishLaunching(withConfiguration: config)

        let status = kit.setUserAttribute("empty_list", values: [])

        XCTAssertEqual(status.returnCode, MPKitReturnCode.success)
    }

    // MARK: - setUserAttribute(key:value:) Tests

    func testSetUserAttribute_WhenStarted_ReturnsSuccess() {
        let kit = MPKitMixpanel()
        let config: [AnyHashable: Any] = [
            "token": "test-token",
            "useMixpanelPeople": "True"
        ]
        _ = kit.didFinishLaunching(withConfiguration: config)

        let status = kit.setUserAttribute("custom_key", value: "custom_value")

        XCTAssertEqual(status.returnCode, MPKitReturnCode.success)
    }

    func testSetUserAttribute_WhenNotStarted_ReturnsFail() {
        let kit = MPKitMixpanel()

        let status = kit.setUserAttribute("key", value: "value")

        XCTAssertEqual(status.returnCode, MPKitReturnCode.fail)
    }

    func testSetUserAttribute_WithNonMixpanelTypeValue_ReturnsSuccess() {
        let kit = MPKitMixpanel()
        let config: [AnyHashable: Any] = [
            "token": "test-token",
            "useMixpanelPeople": "True"
        ]
        _ = kit.didFinishLaunching(withConfiguration: config)

        struct CustomNonMixpanelType { let id: Int }
        let status = kit.setUserAttribute("customKey", value: CustomNonMixpanelType(id: 42))

        XCTAssertEqual(status.returnCode, MPKitReturnCode.success)
    }

    // MARK: - mixpanelProfileKey Tests

    func testMixpanelProfileKey_MapsReservedKeys() {
        XCTAssertEqual(MPKitMixpanel.mixpanelProfileKey(for: "$FirstName"), "$first_name")
        XCTAssertEqual(MPKitMixpanel.mixpanelProfileKey(for: "$LastName"), "$last_name")
        XCTAssertEqual(MPKitMixpanel.mixpanelProfileKey(for: "$Email"), "$email")
        XCTAssertEqual(MPKitMixpanel.mixpanelProfileKey(for: "$Mobile"), "$phone")
        XCTAssertEqual(MPKitMixpanel.mixpanelProfileKey(for: "$Country"), "$country_code")
        XCTAssertEqual(MPKitMixpanel.mixpanelProfileKey(for: "$City"), "$city")
        XCTAssertEqual(MPKitMixpanel.mixpanelProfileKey(for: "$State"), "$region")
    }

    func testMixpanelProfileKey_PassesThroughUnmappedKeys() {
        XCTAssertEqual(MPKitMixpanel.mixpanelProfileKey(for: "custom_key"), "custom_key")
        XCTAssertEqual(MPKitMixpanel.mixpanelProfileKey(for: "$CustomAttribute"), "$CustomAttribute")
    }
}
