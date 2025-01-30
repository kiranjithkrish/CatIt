//
//  RootFlow.swift
//  CatIt
//
//  Created by kiranjith on 30/01/2025.
//

import Foundation


protocol BreedsActions {
	func didSelectBreed(_ breed: Breed)
	func didReload()
}

@Observable
final class BreedsFlow: BreedsActions {
	 var selectedBreed: Breed?
	
	init(selectedBreed: Breed? = nil) {
		self.selectedBreed = selectedBreed
	}
	
	func didSelectBreed(_ breed: Breed) {
		selectedBreed = breed
	}
	
	func didReload() {
		
	}
}
