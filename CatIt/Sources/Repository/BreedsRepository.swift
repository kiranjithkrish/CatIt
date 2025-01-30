//
//  BreedsRepository.swift
//  CatIt
//
//  Created by kiranjith on 28/01/2025.
//

import Foundation

protocol BreedsRepository: Sendable {
	func breeds() async throws -> [Breed]
}


struct DefaultBreedsRepository: BreedsRepository {
	let dataSource: RESTDataStore
	
	private enum Endpoints {
		static func breeds() -> CodableEndpoint<[Breed]> {
			CodableEndpoint<[Breed]>(
				endpoint: Endpoint(
					baseUrl: URL(string: "https://api.thecatapi.com/")!,
					path: "v1/breeds",
					httpMethod: .get,
					authorisation: .custom(apiKey: "x-api-key", value: "live_WCeRxR4cQXW5mKDvMPB9pHNoBYDoyix65jFLHGgQc5we6JpPYLVC3gWz0vv0IK89")
				)
			)
		}
	}
	
	init(dataSource: any RESTDataStore) {
		self.dataSource = dataSource
	}
	
	func breeds() async throws -> [Breed] {
		let endpoint = Endpoints.breeds()
		let breeds = try await dataSource.getCodable<[Breed]>(at: endpoint)
		return breeds
	}
	
}
