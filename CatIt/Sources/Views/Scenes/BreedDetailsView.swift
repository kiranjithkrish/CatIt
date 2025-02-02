//
//  BreedDetails.swift
//  CatIt
//
//  Created by kiranjith on 30/01/2025.
//

import SwiftUI

struct BreedDetailsView: View {
	@StateObject private var detailsService: BreedDetailsService
	let breed: Breed
	
	init(details: BreedDetailsService, breed: Breed) {
		_detailsService = StateObject(wrappedValue: details)
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
			if let error = detailsService.detailsError {
				VStack {
					Spacer()
					ErrorToastView(message: "Failed to load the images")
						.transition(.move(edge: .bottom).combined(with: .opacity))
				}.animation(.easeOut, value: error.localizedDescription)
			}  else if detailsService.breedImages.isEmpty {
				ZStack {
					ProgressView()
				}.frame(maxWidth: .infinity, maxHeight: .infinity)
			}
			 else {
				CatImagesView(currentBreed: breed, columns: columns, images: detailsService.breedImages, service: detailsService)
			}
		}
		.padding()
		.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
		.navigationTitle(breed.name)
		.task {
			await detailsService.loadBreedDetails(for: breed.breedId)
		}
    }
	
}


struct CatImagesView: View {
	let currentBreed: Breed
	let columns: [GridItem]
	let images: [CatImageInfo]
	let service: BreedDetailsService
	
	var body: some View {
		ScrollView {
			LazyVGrid(columns: columns) {
				ForEach(images) { details in
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
	
	private func loadMoreIfNeeded(currentItem: CatImageInfo) {
		guard let lastItem = images.last else { return }
		if lastItem.id == currentItem.id {
			Task {
				await service.loadBreedDetails(for: currentBreed.breedId)
			}
		}
	}
}

struct ErrorToastView: View {
	let message: String
	
	var body: some View {
		Text(message)
			.font(.subheadline)
			.foregroundColor(.white)
			.padding()
			.background(Color.red.opacity(0.8))
			.clipShape(RoundedRectangle(cornerRadius: 10.0))
			.padding(.horizontal, 20)
			.padding(.bottom, 20)
	}
}

//#Preview {
//    BreedDetails()
//}
