//
//  BreedDetailsService.swift
//  CatIt
//
//  Created by kiranjith on 30/01/2025.
//

import Foundation


class BreedDetailsService {
	private let breedDetailsRepo: BreedDetailsRepository
	
	var error: Error?
	var breedDetails: (Breed, [CatImageInfo])?
	
	init(breedDetailsRepo: BreedDetailsRepository) {
		self.breedDetailsRepo = breedDetailsRepo
	}
	
	@MainActor
	func loadBreedDetails() async {
		do {
			// risk of failure if one endpoint fails.
			let repo = self.breedDetailsRepo
			async let breed = repo.breedDetail()
			async let images = repo.breedImages()
			self.breedDetails = try await (breed,images)
		} catch {
			self.error = error
		}
		
	}
}

