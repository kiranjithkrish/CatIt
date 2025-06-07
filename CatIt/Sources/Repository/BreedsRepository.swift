//
//  BreedsRepository.swift
//  CatIt
//
//  Created by kiranjith on 28/01/2025.
//

import Foundation
import NetworkKit

protocol BreedsRepository: Sendable {
	func breeds(page: Int, limit: Int) async throws -> [CatImageInfo]
}

actor ASingleton {
    static let shared = ASingleton()
    private(set) var someProperty: String
    private init() {
        self.someProperty = "someProperty"
    }
}


struct DefaultBreedsRepository: BreedsRepository {
	let dataSource: RESTDataStore
	
	private enum Endpoints {
		static func breeds(page: Int, limit: Int) -> CodableEndpoint<[CatImageInfo]> {
			CodableEndpoint(
				endpoint: Endpoint(
					baseUrl: URL(string: "https://api.thecatapi.com/")!,
					path:  "v1/images/search",
					queryParams: ["page":page, "limit": limit, "has_breeds": true], httpMethod: .get,
					authorisation: .custom(apiKey: "x-api-key", value: "live_WCeRxR4cQXW5mKDvMPB9pHNoBYDoyix65jFLHGgQc5we6JpPYLVC3gWz0vv0IK89")
				)
			)
		}
	}
	
	init(dataSource: any RESTDataStore) {
		self.dataSource = dataSource
	}
	
	func breeds(page: Int, limit: Int) async throws -> [CatImageInfo] {
		let endpoint = Endpoints.breeds(page: page, limit: limit)
		let breeds = try await dataSource.getCodable<[Breed]>(at: endpoint)
		return breeds
	}
	
}
