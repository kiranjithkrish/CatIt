//
//  CatImages.swift
//  CatIt
//
//  Created by kiranjith on 28/01/2025.
//

import Foundation


struct CatImageInfo: Codable, Identifiable, Sendable {
	typealias ID = String
	let id: ID
	let url: String
	let width: Int
	let height: Int
	let breeds: [Breed]
}
