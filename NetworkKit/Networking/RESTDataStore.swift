//
//  RESTDataStore.swift
//  CatIt
//
//  Created by kiranjith on 27/01/2025.
//

import Foundation

/// A protocol defining a RESTful data store for making network requests.
///
/// This protocol provides methods for creating `URLRequest` instances and
/// retrieving `Decodable` objects
/// from API endpoints. It conforms to `Sendable`, making it safe for concurrent access.
public protocol RESTDataStore: AnyObject, Sendable {
	func request(for endpoint: EndpointConvertible) async throws -> URLRequest
	func getCodable<Result: Decodable>(at endpoint: CodableEndpoint<Result>) async throws -> Result
}

extension RESTDataStore {
	func getCodable<Result: Decodable>(at endpoint: EndpointConvertible) async throws -> Result {
		try await getCodable(at: CodableEndpoint<Result>(endpoint: endpoint.endpoint))
	}
}

final class DefaultRESTDataStore: RESTDataStore {
	
	private let session: SessionAdapter
	
	internal actor RequestState {
		var cache: [URLRequest: Task<Response, Error>] = [:]
		
		func clear(for request: URLRequest) async {
			cache[request] = nil
		}
		
		func set(_ task: Task<Response, Error>, for request: URLRequest) async {
			cache[request] = task
		}
		
		func get(for request: URLRequest) async -> Task<Response, Error>? {
			cache[request]
		}
	}
	
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
	
	/// Creates a `URLRequest` from an `EndpointConvertible`. Note only GET methods are handled now. Post and body encoding are not handled.
	///
	/// - Parameter endpoint: The API endpoint to create a request for.
	/// - Returns: A configured `URLRequest` instance.
	/// - Throws: A `NetworkingError` if request creation fails.
	private func makeRequest(for endpoint: any EndpointConvertible) throws -> URLRequest {
		let endpoint = endpoint.endpoint
		var headers = endpoint.headers ?? [:]
		try setupAuthorisation(headers: &headers, endpoint: endpoint)
		guard var components = URLComponents(url: endpoint.baseUrl, resolvingAgainstBaseURL: false) else {
			throw NetworkingError(code: .clientError)
		}
		
		let urlPath = components.path
		components.path = "/" + (urlPath + "/" + endpoint.path)
			.components(separatedBy: "/")
			.filter { !$0.isEmpty}
			.joined(separator: "/")
		let queryItems: [URLQueryItem] = (components.queryItems ?? []) + (endpoint.queryParams ?? [:])
			.sorted(by: { first, second in
				first.key < second.key
			})
			.map { .init(name: $0.key, value: $0.value.description)}
		
		components.queryItems = queryItems
		
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
	
	/// Performs a network request and handles errors.
	///
	/// - Parameter endpoint: The API endpoint to request data from.
	/// - Returns: A `Response` object containing the fetched data.
	/// - Throws: A `NetworkingError` if the request fails.
	func response(at endpoint: EndpointConvertible) async throws -> Response {
		do {
			return try await responseDataTask(for: endpoint)
			
		} catch let error as NetworkingError {
			throw error 
			
		} catch {
			throw NetworkingError(code: .generic, error: error)
		}
	}
	/// Performs a network request and returns a `Response` object.
	///
	/// - Parameter endpoint: The API endpoint to request data from.
	/// - Returns: A `Response` object containing the fetched data.
	/// - Throws: A `NetworkingError` if the request fails.
	func responseDataTask(for endpoint: EndpointConvertible) async throws -> Response {
		guard let request = try? makeRequest(for: endpoint) else {
			throw NetworkingError(code: .generic)
		}
		
		do {
			let (data, response) = try await session.data(for: request)
			// What about the response? This is a generic code which will fail if the endpoint has a modified design
			let code = NetworkingError.Code((response as? HTTPURLResponse)?.statusCode ?? -1)
			
			return Response(code: code, data: data)
			
		} catch {
			throw NetworkingError(code: .generic, error: error)
		}
	}

}
