//
//  BreedDetailsService.swift
//  CatIt
//
//  Created by kiranjith on 30/01/2025.
//


import SwiftUI


final class BreedDetailsService: ObservableObject {
	private let breedDetailsRepo: BreedDetailsRepository
	
	private let currentPage = 0
	private let limit = 20
	private var hasMore = true
	
	@Published var detailsError: Error?
	@Published var breedImages: [CatImageInfo] = []
	
	
	init(breedDetailsRepo: BreedDetailsRepository) {
		self.breedDetailsRepo = breedDetailsRepo
	}
	
	@MainActor
	func loadBreedDetails(for breed: String) async {
		do {
			//async let breed = repo.breedDetail()
			let images = try await self.breedDetailsRepo.breedImages(page: currentPage, limit: limit, id: breed)
			if images.isEmpty {
				hasMore = false
				self.breedImages = images
			} else {
				hasMore = true
				self.breedImages.append(contentsOf: images)
			}
			
		} catch {
			self.detailsError = error
		}
		
	}
}

