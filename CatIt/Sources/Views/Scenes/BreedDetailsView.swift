//
//  BreedDetails.swift
//  CatIt
//
//  Created by kiranjith on 30/01/2025.
//

import SwiftUI

struct BreedDetailsView: View {
	@ObservedObject private var detailsService: BreedDetailsService
	let breed: Breed
	
	init(details: BreedDetailsService, breed: Breed) {
		self.detailsService = details
		self.breed = breed
	}
	
	private let columns: [GridItem] = [
		GridItem(.flexible(), spacing: 10),
		GridItem(.flexible(), spacing: 10),
		GridItem(.flexible(), spacing: 10)
	]
	
    var body: some View {
		VStack(alignment: .leading) {
			Text(breed.description ?? "No Description")
				.font(.subheadline)
			
			if detailsService.breedImages.isEmpty {
				ProgressView()
					.padding()
			} else {
				ScrollView {
					LazyVGrid(columns: columns) {
						ForEach(detailsService.breedImages) { details in
							if let url = URL(string: details.url) {
								BasicCachedAsyncImage(url: url)
									.aspectRatio(contentMode: .fill)
									.frame(width: 120, height: 120)
									.clipped()
									.onAppear {
										loadMoreIfNeeded(currentItem: details)
									}
							}
						}
						
					}
				}
			}
		}
		.padding()
		.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
		.navigationTitle(breed.name)
		.task {
			await detailsService.loadBreedDetails(for: breed.id)
		}
    }
	
	private func loadMoreIfNeeded(currentItem: CatImageInfo) {
		guard let lastItem = detailsService.breedImages.last else { return }
		if lastItem.id == currentItem.id {
			Task {
				await detailsService.loadBreedDetails(for: breed.id)
			}
		}
	}
}

//#Preview {
//    BreedDetails()
//}
