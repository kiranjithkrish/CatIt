//
//  CatImage.swift
//  CatIt
//
//  Created by kiranjith on 27/01/2025.
//

import Foundation

struct CatImage: Identifiable, Codable {
	typealias ID = String
	let id: ID
	let url: String
	let breeds: [Breed]?
}
