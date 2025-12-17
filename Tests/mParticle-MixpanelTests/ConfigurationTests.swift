import XCTest
@testable import mParticle_Mixpanel

final class ConfigurationTests: XCTestCase {

    func testUserIdentificationTypeFromString_CustomerId() {
        let type = UserIdentificationType(rawValue: "CustomerId")
        XCTAssertEqual(type, .customerId)
    }

    func testUserIdentificationTypeFromString_MPID() {
        let type = UserIdentificationType(rawValue: "MPID")
        XCTAssertEqual(type, .mpid)
    }

    func testUserIdentificationTypeFromString_Other() {
        let type = UserIdentificationType(rawValue: "Other")
        XCTAssertEqual(type, .other)
    }

    func testUserIdentificationTypeFromString_InvalidDefaultsToCustomerId() {
        let type = UserIdentificationType(rawValue: "InvalidValue") ?? .customerId
        XCTAssertEqual(type, .customerId)
    }
}
