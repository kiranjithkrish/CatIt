//
//  Breed.swift
//  CatIt
//
//  Created by kiranjith on 27/01/2025.
//

import Foundation


struct Breed: Hashable, Codable, Sendable, Identifiable {
	let breedId: String
	let uuid: UUID
	let name: String
	let origin: String?
	let description: String?
	
	var id: UUID { uuid }
	
	enum CodingKeys: String, CodingKey {
		case breedId = "id"
		case name, origin, description
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.breedId = try container.decode(String.self, forKey: .breedId)
		self.name = try container.decode(String.self, forKey: .name)
		self.origin = try container.decodeIfPresent(String.self, forKey: .origin)
		self.description = try container.decodeIfPresent(String.self, forKey: .description)
		self.uuid = UUID() // Generate a new UUID since API doesn't provide one.
	}
}
