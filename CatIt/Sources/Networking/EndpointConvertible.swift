//
//  EndpointConvertible.swift
//  CatIt
//
//  Created by kiranjith on 27/01/2025.
//

import Foundation


protocol EndpointConvertible {
	var endpoint: Endpoint { get }
}

extension Endpoint: EndpointConvertible {
	var endpoint: Endpoint { self }
}
