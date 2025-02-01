//
//  BreedsView.swift
//  CatIt
//
//  Created by kiranjith on 30/01/2025.
//

import SwiftUI

struct BreedsView: View {
	@StateObject var breedsService: BreedsService
	let flow: RootFlow
	
    var body: some View {
			Group {
				List(breedsService.catImages) { catInfo in
						if let breed = catInfo.breeds.first {
							Button(action: {
								flow.showBreedDetails(for: breed)
							}) {
								BreedRowView(imageInfo: catInfo)
									.onAppear {
										loadMoreIfNeeded(currentItem: catInfo)
									}
							}
						}
					}
			}
			.task {
				await breedsService.loadBreeds()
			}
			.navigationTitle("Breeds")
		
    }
	
	private func loadMoreIfNeeded(currentItem: CatImageInfo) {
		guard let lastItem = breedsService.catImages.last else { return }
		if lastItem.id == currentItem.id {
			Task {
				await breedsService.loadBreeds()
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
