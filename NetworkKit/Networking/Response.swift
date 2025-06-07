//
//  Response.swift
//  CatIt
//
//  Created by kiranjith on 27/01/2025.
//

import Foundation

/// Performs a network request and handles errors.
///
/// - Parameter endpoint: The API endpoint to request data from.
/// - Returns: A `Response` object containing the fetched data.
/// - Throws: A `NetworkingError` if the request fails.

struct Response {
	let data: Data
	let code: NetworkingError.Code
	
	init(code: NetworkingError.Code, data: Data) {
		self.data = data
		self.code = code
	}
	
	func decode<Entity: Decodable>(with decoder: JSONDecoder = JSONDecoder()) throws -> Entity {
		do {
			return try decoder.decode(Entity.self, from: data)
		} catch let error as NetworkingError {
			throw error  // Directly throw known `NetworkingError`
		} catch {
			throw NetworkingError(code: .generic, error: error) // Wrap unknown errors
		}
	}
}

