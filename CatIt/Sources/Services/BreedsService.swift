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
	
	private var currentPage = 0
	private let pageLimit = 20
	
	@Published var error: Error?
	@Published var catImages: [CatImageInfo] = [] 
	@Published var isLoading = false
	private var hasMore = true
	
	@MainActor
	func loadBreeds() async {
		do {
			let catImages = try await self.breedsRepo.breeds(page: currentPage, limit: pageLimit)
			if catImages.isEmpty {
				hasMore = false
			} else {
				self.catImages.append(contentsOf: catImages)
				currentPage += 1
			}
		} catch {
			self.error = error
		}
		
	}
}

