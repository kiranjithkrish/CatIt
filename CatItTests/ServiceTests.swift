import XCTest
@testable import CatIt

final class ServiceTests: XCTestCase {
    actor MockBreedsRepository: BreedsRepository {
        var images: [CatImageInfo]
        var callCount = 0
        init(images: [CatImageInfo]) { self.images = images }
        func breeds(page: Int, limit: Int) async throws -> [CatImageInfo] {
            callCount += 1
            return images
        }
    }

    func testLoadBreedsAppendsData() async throws {
        let breedJSON = """
        {
            "id": "abys",
            "name": "Abyssinian",
            "origin": "Egypt",
            "description": "desc"
        }
        """.data(using: .utf8)!
        let breed = try JSONDecoder().decode(Breed.self, from: breedJSON)
        let image = CatImageInfo(breedId: "img", url: "https://example.com/cat.jpg", uuid: UUID(), breeds: [breed])

        let repo = MockBreedsRepository(images: [image])
        let service = BreedsService(breedsRepo: repo)

        await service.loadBreeds()
        XCTAssertEqual(service.catImages.count, 1)
        XCTAssertNil(service.error)
    }

    func testLoadBreedsStopsWhenNoMorePages() async throws {
        let repo = MockBreedsRepository(images: [])
        let service = BreedsService(breedsRepo: repo)

        await service.loadBreeds() // first call sets hasMore false
        await service.loadBreeds() // should not call repo again
        let count = await repo.callCount
        XCTAssertEqual(count, 1)
    }
}
