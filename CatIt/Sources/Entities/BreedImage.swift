//
//  CatImages.swift
//  CatIt
//
//  Created by kiranjith on 28/01/2025.
//

import Foundation


struct CatImageInfo: Codable, Identifiable, Sendable {
	
	
	//typealias ID = String
	
	let breedId: String
	let url: String
	let uuid: UUID 
	let breeds: [Breed]
	var id:UUID { uuid }
	
	enum CodingKeys: String, CodingKey {
		case breedId = "id"
		case url, breeds
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.breedId = try container.decode(String.self, forKey: .breedId)
		self.url = try container.decode(String.self, forKey: .url)
		self.breeds = try container.decode([Breed].self, forKey: .breeds)
		self.uuid = UUID()
		print("id", self.uuid)
	}
	
	var firstBreed: Breed? {
		breeds.first
	}
}
