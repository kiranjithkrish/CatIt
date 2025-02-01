//
//  Breed.swift
//  CatIt
//
//  Created by kiranjith on 27/01/2025.
//

import Foundation


struct Breed: Hashable, Codable, Sendable, Identifiable {
	typealias ID = String
	let id: ID
	let name: String
	let origin: String?
	let description: String?
}
