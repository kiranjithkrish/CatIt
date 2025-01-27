//
//  DecodableEndpoint.swift
//  CatIt
//
//  Created by kiranjith on 27/01/2025.
//

import Foundation

struct CodableEndpoint<Entity: Decodable>: EndpointConvertible {
	let decoder: JSONDecoder
	let endpoint: Endpoint
	
	init(_ decoder: JSONDecoder = .init(), _ endpoint: Endpoint) {
		self.decoder = decoder
		self.endpoint = endpoint
	}
}

