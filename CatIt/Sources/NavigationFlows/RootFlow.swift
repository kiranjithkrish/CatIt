//
//  RootFlow.swift
//  CatIt
//
//  Created by kiranjith on 30/01/2025.
//

import Foundation
import SwiftUI

protocol RootActions {
	func didSelectBreed(_ breed: Breed)
	func didReload()
}

final class RootFlow {
	let coordinator: NavigationCoordinator
	init(coordinator: NavigationCoordinator) {
		self.coordinator = coordinator
	}
	@MainActor func makeBreedsView(breedsService: BreedsService) -> some View {
		BreedsView(breedsService: breedsService, flow: self)
	}
	
	@MainActor func showBreedDetails(for breed: Breed) {
			// Assemble the dependencies for the details screen.
		let dataStore = DefaultRESTDataStore()
		let repository = DefaultBreedDetailsRepository(dataSource: dataStore)
		let viewModel = BreedDetailsService(breedDetailsRepo: repository)
		let detailsView = BreedDetailsView(details: viewModel, breed: breed)
	
		coordinator.push({  AnyView(detailsView)  })
	}
	
	@MainActor func makeBreedsView() -> AnyView {
		let dataStore = DefaultRESTDataStore()
		let breedsRepo = DefaultBreedsRepository(dataSource: dataStore)
		let breedsService = BreedsService(breedsRepo: breedsRepo)
		return AnyView(BreedsView(breedsService: breedsService, flow: self))
	}
	
	

}
