//
//  CatItApp.swift
//  CatIt
//
//  Created by kiranjith on 26/01/2025.
//

import SwiftUI

@main
struct CatItApp: App {
    var body: some Scene {
        WindowGroup {
			let breedsRepo = DefaultBreedsRepository(dataSource: DefaultRESTDataStore())
			let viewModel = BreedsService(breedsRepo: breedsRepo)
			let flow = BreedsFlow(selectedBreed: nil)
			
			BreedsView(breedsService: viewModel, flow: flow)
        }
    }
}
