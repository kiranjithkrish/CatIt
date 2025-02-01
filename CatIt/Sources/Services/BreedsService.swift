//
//  BreedsService.swift
//  CatIt
//
//  Created by kiranjith on 29/01/2025.
//

import Foundation


final class BreedsService: ObservableObject {
	private let breedsRepo: BreedsRepository
	
	init(breedsRepo: BreedsRepository) {
		self.breedsRepo = breedsRepo
	}
	
	private let currentPage = 0
	private let pageLimit = 20
	
	@Published var error: Error?
	@Published var catImages: [CatImageInfo] = [] 
	@Published var isLoading = false
	
	@MainActor
	func loadBreeds() async {
		do {
			self.catImages = try await self.breedsRepo.breeds(page: currentPage, limit: pageLimit)
		} catch {
			self.error = error
		}
		
	}
}

