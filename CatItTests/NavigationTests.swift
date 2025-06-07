import XCTest
import SwiftUI
@testable import CatIt

final class NavigationTests: XCTestCase {
    func testPushPopAndPopToRoot() {
        let coordinator = NavigationCoordinator()
        coordinator.push { AnyView(Text("A")) }
        XCTAssertEqual(coordinator.path.count, 1)

        coordinator.push { AnyView(Text("B")) }
        XCTAssertEqual(coordinator.path.count, 2)

        coordinator.pop()
        XCTAssertEqual(coordinator.path.count, 1)

        coordinator.popToRoot()
        XCTAssertTrue(coordinator.path.isEmpty)
    }
}
