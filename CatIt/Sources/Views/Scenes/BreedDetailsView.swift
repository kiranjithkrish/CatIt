//
//  BreedDetails.swift
//  CatIt
//
//  Created by kiranjith on 30/01/2025.
//

import SwiftUI

struct BreedDetailsView: View {
	let breed: Breed
    var body: some View {
		VStack {
			Text(breed.name).font(.largeTitle)
			Text(breed.description ?? "No Description")
		}
		.navigationTitle(breed.name)
    }
}

//#Preview {
//    BreedDetails()
//}
