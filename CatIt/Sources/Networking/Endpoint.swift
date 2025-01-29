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
	let parameters: Body
	//Automatic string conversion using the description property.
	let queryParams: [String: CustomStringConvertible]?
	let httpMethod: HTTPMethod
	let headers: [String: String]?
	let authorisation: AuthorizationType
	
	init(baseUrl: URL,
		 path: String,
		 parameters: Body = [String:Any](),
		 queryParams: [String : CustomStringConvertible]? = nil,
		 httpMethod: HTTPMethod,
		 headers: [String : String]? = nil,
		 authorisation: AuthorizationType) {
		self.baseUrl = baseUrl
		self.path = path
		self.parameters = parameters
		self.queryParams = queryParams
		self.httpMethod = httpMethod
		self.headers = headers
		self.authorisation = authorisation
	}
}
