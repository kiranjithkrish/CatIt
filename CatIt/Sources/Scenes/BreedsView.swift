//
//  BreedsView.swift
//  CatIt
//
//  Created by kiranjith on 30/01/2025.
//

import SwiftUI

struct BreedsView: View {
	@Bindable private var breedsService: BreedsService
	@Bindable private var flow: BreedsFlow
	
	init(breedsService: BreedsService, flow: BreedsFlow) {
		self.breedsService = breedsService
		self.flow = flow
	}
	
    var body: some View {
		NavigationStack {
			List(breedsService.breeds ?? []) { breed in
				Button(breed.name) {
					flow.didSelectBreed(breed) // ✅ Calls Flow directly
				}
			}
			.task {
				await breedsService.loadBreeds()
			}
			.navigationDestination(item: $flow.selectedBreed) { breed in
				BreedDetailsView(breed: breed)
			}
		}
    }
}

//#Preview {
//    BreedsView()
//}
