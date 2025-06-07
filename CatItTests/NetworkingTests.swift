import XCTest
@testable import CatIt

final class NetworkingTests: XCTestCase {
    func testResponseDecodeSuccess() throws {
        let json = """{"id":"abys","name":"Abyssinian"}""".data(using: .utf8)!
        let response = Response(code: .httpOk, data: json)
        let breed: Breed = try response.decode()
        XCTAssertEqual(breed.name, "Abyssinian")
    }

    func testResponseDecodeFailureWrapsError() throws {
        let json = "{}".data(using: .utf8)!
        let response = Response(code: .httpOk, data: json)
        XCTAssertThrowsError(try response.decode() as Breed) { error in
            guard let networkingError = error as? NetworkingError else {
                return XCTFail("Expected NetworkingError")
            }
            XCTAssertEqual(networkingError.code, .generic)
        }
    }

    func testRESTDataStoreCreatesRequestWithHeaders() async throws {
        struct DummyEndpoint: EndpointConvertible {
            let endpoint: Endpoint
        }

        let endpoint = DummyEndpoint(endpoint: Endpoint(
            baseUrl: URL(string: "https://example.com")!,
            path: "v1/test",
            queryParams: ["page": 1],
            httpMethod: .get,
            authorisation: .custom(apiKey: "x-api-key", value: "123")
        ))

        let store = DefaultRESTDataStore(session: URLSession(configuration: .ephemeral))
        let request = try await store.request(for: endpoint)

        XCTAssertEqual(request.allHTTPHeaderFields?["x-api-key"], "123")
        XCTAssertTrue(request.url?.absoluteString.contains("page=1") ?? false)
    }
}
