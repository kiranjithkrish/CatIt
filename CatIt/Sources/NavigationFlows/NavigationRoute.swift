//
//  NavigationRoute.swift
//  CatIt
//
//  Created by kiranjith on 01/02/2025.
//

import SwiftUI


struct NavigationRoute: Hashable {
	let id = UUID()
	let builder: () -> AnyView
	
	static func ==(lhs: NavigationRoute, rhs: NavigationRoute) -> Bool {
		lhs.id == rhs.id
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}


final class NavigationCoordinator: ObservableObject {
	@Published var path: [NavigationRoute] = []
	
	func push(_ viewBuilder: @escaping () -> AnyView) {
		let route = NavigationRoute(builder: viewBuilder)
		print("Pushing route with id \(route.id)") // Debug log
		path.append(route)
		print(path.count)
	}
	
	func pop() {
		_ = path.popLast()
	}
	
	func popToRoot() {
		path.removeAll()
	}
}
