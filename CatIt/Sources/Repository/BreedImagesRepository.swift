//
//  BreedImagesRepository.swift
//  CatIt
//
//  Created by kiranjith on 28/01/2025.
//

import Foundation

protocol BreedImagesRepository {
	func breedImages() async throws -> [BreedImage]
}


struct DefaultBreedImagesRepository: BreedImagesRepository {
	let dataSource: RESTDataStore
	
	private enum Endpoints {
		
		static func breedDetail() -> CodableEndpoint<[BreedImage]> {
			CodableEndpoint<[BreedImage]>(
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
	
	func breedImages() async throws -> [BreedImage] {
		let endpoint = Endpoints.breedDetail()
		let breeds = try await dataSource.getCodable<[BreedImage]>(at: endpoint)
		return breeds
	}
}
