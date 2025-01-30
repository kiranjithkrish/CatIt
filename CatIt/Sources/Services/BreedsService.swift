//
//  BreedsService.swift
//  CatIt
//
//  Created by kiranjith on 29/01/2025.
//

import Foundation

@Observable
final class BreedsService {
	private let breedsRepo: BreedsRepository
	
	init(breedsRepo: BreedsRepository) {
		self.breedsRepo = breedsRepo
	}
	
	var error: Error?
	var breeds: [Breed]?
	
	@MainActor
	func loadBreeds() async {
		do {
			self.breeds = try await self.breedsRepo.breeds()
		} catch {
			self.error = error
		}
		
	}
}

