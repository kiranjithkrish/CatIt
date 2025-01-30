//
//  DecodableEndpoint.swift
//  CatIt
//
//  Created by kiranjith on 27/01/2025.
//

import Foundation

public struct CodableEndpoint<Entity: Decodable>: EndpointConvertible, Sendable {
	let decoder: JSONDecoder
	let endpoint: Endpoint
	
	init(decoder: JSONDecoder = .init(),
		 endpoint: Endpoint) {
		self.decoder = decoder
		self.endpoint = endpoint
	}
}

