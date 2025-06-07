//
//  Session.swift
//  CatIt
//
//  Created by kiranjith on 30/01/2025.
//

import Foundation

protocol SessionAdapter: Sendable {
	func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: SessionAdapter {}
