//
//  DecodableEndpoint.swift
//  CatIt
//
//  Created by kiranjith on 27/01/2025.
//

import Foundation

/// A generic endpoint that supports decoding API responses into a specified `Decodable` entity.
///
/// - Note: Use this for endpoints that return JSON data that needs to be automatically decoded.
///
/// # Example Usage:
/// ```swift
/// let endpoint = CodableEndpoint<MyModel>(
///     endpoint: Endpoint(baseURL: url, path: "/data")
/// )
/// ```
///
/// - Parameters:
///   - Entity: The `Decodable` type that the response should be parsed into.
///   - decoder: The `JSONDecoder` used to decode the response data (default: `.init()`).
///   - endpoint: The `Endpoint` configuration for the network request.
public struct CodableEndpoint<Entity: Decodable>: EndpointConvertible {
	let decoder: JSONDecoder
	let endpoint: Endpoint
	
	init(decoder: JSONDecoder = .init(),
		 endpoint: Endpoint) {
		self.decoder = decoder
		self.endpoint = endpoint
	}
}

