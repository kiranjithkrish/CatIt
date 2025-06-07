//
//  NetworkingError.swift
//  CatIt
//
//  Created by kiranjith on 27/01/2025.
//

import Foundation


struct NetworkingError: Error, Equatable {
	
	static func ==(lhs: NetworkingError, rhs: NetworkingError) -> Bool {
		return lhs.code == rhs.code
	}
	
	struct Code: ExpressibleByIntegerLiteral, CustomStringConvertible, Equatable {
		let value: Int
		
		static var jsonMapping: Code { 101 }
		static var generic: Code { 0 }
		
		init(integerLiteral value: IntegerLiteralType) {
			self.value = value
		}
		
		init(_ value: Int) {
			self.value = value
		}
		
		var description: String {
			switch self {
			case .jsonMapping:  return "jsonMapping"
			case .generic: return "generic"
			default: return "\(value)"
			}
		}
		
	}
	
	let code: Code
	let error: Error?
	
	init(code: Code, error: Error? = nil) {
		self.code = code
		self.error = error
	}
}

extension NetworkingError.Code {
	static var httpOk: Self { 200 }
	static var clientError: Self { 400 }
	static var serverError: Self { 500 }
	static var httpUnauthorised: Self { 401 }
	static var httpNotFound: Self { 404 }
	static var httpForbidden: Self { 403 }
	var httpOk: Bool {
		value < 400
	}
}
