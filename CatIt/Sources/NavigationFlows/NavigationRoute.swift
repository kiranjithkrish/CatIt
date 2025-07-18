//
//  NavigationRoute.swift
//  CatIt
//
//  Created by kiranjith on 01/02/2025.
//

import SwiftUI


protocol Navigator {
	func push(_ route: NavigationRoute)
		// You could also add modal or pop operations here.
}

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
