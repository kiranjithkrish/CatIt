import XCTest
@testable import CatIt

final class RepositoryTests: XCTestCase {
    actor MockRESTDataStore: RESTDataStore {
        var lastEndpoint: Endpoint?
        var result: [CatImageInfo]
        init(result: [CatImageInfo]) { self.result = result }
        func request(for endpoint: EndpointConvertible) async throws -> URLRequest {
            throw NSError(domain: "", code: 0)
        }
        func getCodable<Result: Decodable>(at endpoint: CodableEndpoint<Result>) async throws -> Result {
            lastEndpoint = endpoint.endpoint
            return result as! Result
        }
    }

    func testBreedsRepositoryPassesCorrectEndpoint() async throws {
        let breed = Breed(breedId: "b", uuid: UUID(), name: "name", origin: nil, description: nil)
        let image = CatImageInfo(breedId: "1", url: "url", uuid: UUID(), breeds: [breed])
        let store = MockRESTDataStore(result: [image])
        let repo = DefaultBreedsRepository(dataSource: store)

        let images = try await repo.breeds(page: 2, limit: 5)
        XCTAssertEqual(images.count, 1)
        let endpoint = await store.lastEndpoint
        XCTAssertEqual(endpoint?.path, "v1/images/search")
        XCTAssertEqual(endpoint?.queryParams?["page"]?.description, "2")
        XCTAssertEqual(endpoint?.queryParams?["limit"]?.description, "5")
    }

    func testBreedDetailsRepositoryPassesCorrectEndpoint() async throws {
        let breed = Breed(breedId: "b", uuid: UUID(), name: "name", origin: nil, description: nil)
        let image = CatImageInfo(breedId: "1", url: "url", uuid: UUID(), breeds: [breed])
        let store = MockRESTDataStore(result: [image])
        let repo = DefaultBreedDetailsRepository(dataSource: store)

        _ = try await repo.breedImages(page: 1, limit: 3, id: "b")
        let endpoint = await store.lastEndpoint
        XCTAssertEqual(endpoint?.queryParams?["breed_id"]?.description, "b")
    }
}
