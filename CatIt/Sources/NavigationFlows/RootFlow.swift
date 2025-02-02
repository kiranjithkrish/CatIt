//
//  RootFlow.swift
//  CatIt
//
//  Created by kiranjith on 30/01/2025.
//

import Foundation
import SwiftUI

protocol RootActions {
	func didSelectBreed(for breed: Breed)
}

final class RootFlow: RootActions {
	
	private let coordinator: NavigationCoordinator
	
	init(coordinator: NavigationCoordinator) {
		self.coordinator = coordinator
	}
	
	func didSelectBreed(for breed: Breed) {
		let dataStore = DefaultRESTDataStore()
		let repository = DefaultBreedDetailsRepository(dataSource: dataStore)
		let viewModel = BreedDetailsService(breedDetailsRepo: repository)
		let detailsView = BreedDetailsView(details: viewModel, breed: breed)
		coordinator.push({  AnyView(detailsView)  })
	}

}
