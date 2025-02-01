//
//  RESTDataStore.swift
//  CatIt
//
//  Created by kiranjith on 27/01/2025.
//

import Foundation


protocol RESTDataStore: AnyObject, Sendable {
	func request(for endpoint: EndpointConvertible) async throws -> URLRequest
	func getCodable<Result: Decodable>(at endpoint: CodableEndpoint<Result>) async throws -> Result
}

extension RESTDataStore {
	func getCodable<Result: Decodable>(at endpoint: EndpointConvertible) async throws -> Result {
		try await getCodable(at: CodableEndpoint<Result>(endpoint: endpoint.endpoint))
	}
}

actor DefaultRESTDataStore: RESTDataStore {
	
	private let session: SessionAdapter
	
	init(session: URLSession = .shared) {
		self.session = session
	}
	
	func request(for endpoint: any EndpointConvertible) async throws -> URLRequest {
		try makeRequest(for: endpoint)
	}
	
	func getCodable<Result: Sendable>(at endpoint: CodableEndpoint<Result>) async throws -> Result where Result: Decodable {
		let response = try await responseDataTask(for: endpoint)
		return try response.decode()
	}
	
}


extension DefaultRESTDataStore {
	
	private func setupAuthorisation(headers: inout [String:String], endpoint: Endpoint) throws {
		switch endpoint.authorisation {
		case let .custom(key,value):
			headers[key] = value
		default: throw NetworkingError(code: .httpUnauthorised)
		}
	}
	
	private func makeRequest(for endpoint: any EndpointConvertible) throws -> URLRequest {
		let endpoint = endpoint.endpoint
		var headers = endpoint.headers ?? [:]
		try setupAuthorisation(headers: &headers, endpoint: endpoint)
		
		//Create url components
		guard var components = URLComponents(url: endpoint.baseUrl, resolvingAgainstBaseURL: false) else {
			throw NetworkingError(code: .clientError)
		}
		
		// create the path
		let urlPath = components.path
		components.path = "/" + (urlPath + "/" + endpoint.path)
			.components(separatedBy: "/")
			.filter { !$0.isEmpty}
			.joined(separator: "/")
		// query params
		let queryItems: [URLQueryItem] = (components.queryItems ?? []) + (endpoint.queryParams ?? [:])
			.sorted(by: { first, second in
				first.key < second.key
			})
			.map { .init(name: $0.key, value: $0.value.description)}
		
		components.queryItems = queryItems
		
		// construct the final url
		guard let url = components.url else {
			throw NetworkingError(code: .clientError)
		}
		
		var urlRequest = URLRequest(url: url)
		urlRequest.httpMethod = endpoint.httpMethod.rawValue
		if endpoint.httpMethod != .get {
			// to be handled later
		}
		urlRequest.allHTTPHeaderFields = headers
		return urlRequest
		
	}
}

private extension DefaultRESTDataStore {
	func responseDataTask(for endpoint: EndpointConvertible) async throws -> Response {
		let urlRequest = try makeRequest(for: endpoint)
		print(urlRequest.url)
		let (data, _) = try await session.data(for: urlRequest)
		return Response(data: data)
	}
}
