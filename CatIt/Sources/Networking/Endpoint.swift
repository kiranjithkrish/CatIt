//
//  Endpoint.swift
//  CatIt
//
//  Created by kiranjith on 27/01/2025.
//

import Foundation

typealias JSON = [String: Any]

protocol Body {
	var json: JSON? { get }
}

extension Body where Self: Encodable {
	var json: JSON? {
		nil // To be handled later if post is needed
	}
}

extension Dictionary: Body where Key == String {
	var json: JSON? { self }
}

enum HTTPMethod: String {
	case get = "GET"
	case post = "POST"
}

/// Represents an API endpoint configuration.
struct Endpoint {
	
	enum AuthorizationType: Equatable {
		case none
		case bearer
		case basic(username: String, password: String)
		case custom(apiKey: String, value: String)
	}
	
	enum Encoding {
		case json
	}
	
	let baseUrl: URL
	let path: String
	let body: Body
	//Automatic string conversion using the description property.
	let queryParams: [String: CustomStringConvertible]?
	let httpMethod: HTTPMethod
	let headers: [String: String]?
	let authorisation: AuthorizationType
	
	init(baseUrl: URL,
		 path: String,
		 body: Body = [String:Any](),
		 queryParams: [String : CustomStringConvertible]? = nil,
		 httpMethod: HTTPMethod,
		 headers: [String : String]? = nil,
		 authorisation: AuthorizationType) {
		self.baseUrl = baseUrl
		self.path = path
		self.body = body
		self.queryParams = queryParams
		self.httpMethod = httpMethod
		self.headers = headers
		self.authorisation = authorisation
	}
}

/// A protocol for types that can be converted into an `Endpoint`.
protocol EndpointConvertible {
	var endpoint: Endpoint { get }
}

extension Endpoint: EndpointConvertible {
	var endpoint: Endpoint { self }
}
