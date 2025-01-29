//
//  BreedDetailsRepository.swift
//  CatIt
//
//  Created by kiranjith on 28/01/2025.
//

import Foundation

protocol BreedDetailsRepository {
	func breedDetail() async throws -> Breed
}


struct DefaultBreedDetailsRepository: BreedDetailsRepository {
	let dataSource: RESTDataStore
	
	private enum Endpoints {
		
		static func breedDetail() -> CodableEndpoint<Breed> {
			CodableEndpoint<Breed>(
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
	
	func breedDetail() async throws -> Breed {
		let endpoint = Endpoints.breedDetail()
		let breeds = try await dataSource.getCodable<Breed>(at: endpoint)
		return breeds
	}
}
