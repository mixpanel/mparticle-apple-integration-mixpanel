import XCTest
@testable import mParticle_Mixpanel

final class KitRegistrationTests: XCTestCase {

    func testKitCode_Returns10() {
        let kitCode = MPKitMixpanel.kitCode()
        XCTAssertEqual(kitCode, NSNumber(value: 10))
    }
}
