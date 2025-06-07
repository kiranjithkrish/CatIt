//
//  BreedDetailsRepository.swift
//  CatIt
//
//  Created by kiranjith on 28/01/2025.
//

import Foundation
import NetworkKit

protocol BreedDetailsRepository: Sendable {
	func breedImages(page: Int, limit: Int, id: String) async throws -> [CatImageInfo]
}

struct DefaultBreedDetailsRepository: BreedDetailsRepository {
	let dataSource: RESTDataStore
	
	private enum Endpoints {
		static func breedImages(page: Int, limit: Int, id: String) -> CodableEndpoint<[CatImageInfo]> {
			CodableEndpoint(
				endpoint: Endpoint(
					baseUrl: URL(string: "https://api.thecatapi.com/")!,
					path:  "v1/images/search",
					queryParams: ["page":page, "limit": limit, "has_breeds": true, "breed_id": id, "size" : "small"], httpMethod: .get,
					authorisation: .custom(apiKey: "x-api-key", value: "live_WCeRxR4cQXW5mKDvMPB9pHNoBYDoyix65jFLHGgQc5we6JpPYLVC3gWz0vv0IK89")
				)
			)
		}
	}
	
	init(dataSource: any RESTDataStore) {
		self.dataSource = dataSource
	}
	
	func breedImages(page: Int, limit: Int, id breedId: String) async throws -> [CatImageInfo] {
		let endpoint = Endpoints.breedImages(page: page, limit: limit, id: breedId)
		let breeds = try await dataSource.getCodable<[BreedImage]>(at: endpoint)
		return breeds
	}
}
