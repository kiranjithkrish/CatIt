//
//  BreedsView.swift
//  CatIt
//
//  Created by kiranjith on 30/01/2025.
//

import SwiftUI

struct BreedsListView: View {
	@State private var breedsService: BreedsListService
	let rootFlow: RootActions
	
	init(breedsService: BreedsListService, rootFlow: RootFlow) {
		_breedsService = State(wrappedValue: breedsService)
		self.rootFlow = rootFlow
	}
	
	var body: some View {
		Group {
			if let error = breedsService.error {
				VStack {
					Spacer()
					ErrorToastView(message: "Failed to load the breeds")
						.transition(.move(edge: .bottom).combined(with: .opacity))
				}
				.animation(.easeOut, value: error.localizedDescription)
			} else if breedsService.catImages.isEmpty {
				ProgressView()
			} else {
				BreedsList(
					breedData: breedsService.catImages,
					flow: rootFlow,
					breedsService: breedsService
				)
			}
		}
		.task {
			if breedsService.catImages.isEmpty {
				await breedsService.loadBreeds()
			}
		}
		.navigationTitle("Breeds")
	}
}


struct BreedsList: View {
	let breedData: [CatImageInfo]
	let flow: RootActions
	let breedsService: BreedsListService
	
	var body: some View {
		List(breedData) { catInfo in
			if let breed = catInfo.firstBreed {
				Button(action: {
					flow.didSelectBreed(for: breed)
				}) {
					BreedRowView(imageInfo: catInfo)
						.onAppear {
							//loadMoreIfNeeded(currentItem: catInfo)
						}
				}
			}
		}
	}
	
	private func loadMoreIfNeeded(currentItem: CatImageInfo) {
		guard let lastItem = breedsService.catImages.last else { return }
		if lastItem.id == currentItem.id {
			Task {
				//await breedsService.loadBreeds()
			}
		}
	}
}

struct BreedRowView: View {
	let imageInfo: CatImageInfo
	
	var body: some View {
		HStack {
			if let url = URL(string: imageInfo.url) {
				BasicCachedAsyncImage(url: url)
					.frame(width: 80, height: 80)
					.clipShape(RoundedRectangle(cornerRadius: 10))
					.padding()
			}
			
			if let breed = imageInfo.breeds.first {
				VStack(alignment: .leading) {
					Text(breed.name)
						.font(.headline)
					Text(breed.origin ?? "")
						.font(.subheadline)
						.foregroundColor(.gray)
						.lineLimit(2)
				}
			}
			
		}
		.padding(.vertical, 5)
	}
}

struct ErrorView: View {
	let message: String
	
	var body: some View {
		VStack {
			Image(systemName: "exclamationmark.triangle.fill")
				.foregroundColor(.red)
				.font(.largeTitle)
			Text(message)
				.font(.headline)
				.foregroundColor(.red)
				.multilineTextAlignment(.center)
				.padding()
		}
	}
}

//#Preview {
//    BreedsView()
//}
