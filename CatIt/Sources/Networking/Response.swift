//
//  Response.swift
//  CatIt
//
//  Created by kiranjith on 27/01/2025.
//

import Foundation


struct Response {
	let data: Data
	
	init(data: Data) {
		self.data = data
	}
	
	func decode<Entity: Decodable>(with decoder: JSONDecoder = JSONDecoder()) throws -> Entity {
		do {
			return try decoder.decode(Entity.self, from: data)
		} catch {
			throw NetworkingError(code: .jsonMapping)
		}
	}
}

