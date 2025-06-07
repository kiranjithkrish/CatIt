import XCTest
import SwiftUI
@testable import CatIt

final class BreedDetailsServiceTests: XCTestCase {
    actor MockBreedDetailsRepository: BreedDetailsRepository {
        var images: [CatImageInfo]
        var callCount = 0
        init(images: [CatImageInfo]) { self.images = images }
        func breedImages(page: Int, limit: Int, id: String) async throws -> [CatImageInfo] {
            callCount += 1
            return images
        }
    }

    func testLoadBreedDetailsAppendsData() async throws {
        let breed = Breed(breedId: "abys", uuid: UUID(), name: "Abyssinian", origin: nil, description: nil)
        let image = CatImageInfo(breedId: "img", url: "https://example.com/cat.jpg", uuid: UUID(), breeds: [breed])
        let repo = MockBreedDetailsRepository(images: [image])
        let service = BreedDetailsService(breedDetailsRepo: repo)

        await service.loadBreedDetails(for: "abys")
        XCTAssertEqual(service.breedImages.count, 1)
        XCTAssertNil(service.detailsError)
    }

    func testLoadBreedDetailsStopsWhenNoMorePages() async throws {
        let repo = MockBreedDetailsRepository(images: [])
        let service = BreedDetailsService(breedDetailsRepo: repo)

        await service.loadBreedDetails(for: "abys")
        await service.loadBreedDetails(for: "abys")

        let count = await repo.callCount
        XCTAssertEqual(count, 1)
    }
}
