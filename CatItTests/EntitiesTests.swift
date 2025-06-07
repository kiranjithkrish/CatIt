import XCTest
@testable import CatIt

final class EntitiesTests: XCTestCase {
    func testBreedDecodingGeneratesUniqueIDs() throws {
        let json = """
        {
            "id": "abys",
            "name": "Abyssinian",
            "origin": "Egypt",
            "description": "desc"
        }
        """.data(using: .utf8)!

        let breed1 = try JSONDecoder().decode(Breed.self, from: json)
        let breed2 = try JSONDecoder().decode(Breed.self, from: json)

        XCTAssertEqual(breed1.breedId, "abys")
        XCTAssertNotEqual(breed1.id, breed2.id)
    }

    func testCatImageInfoReturnsFirstBreed() throws {
        let json = """
        {
            "id": "img1",
            "url": "https://example.com/cat.jpg",
            "breeds": [{
                "id": "abc",
                "name": "Cat",
                "origin": "US",
                "description": "desc"
            }]
        }
        """.data(using: .utf8)!

        let info = try JSONDecoder().decode(CatImageInfo.self, from: json)
        XCTAssertEqual(info.firstBreed?.breedId, "abc")
    }
}
