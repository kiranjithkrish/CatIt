//
//  RootView.swift
//  CatIt
//
//  Created by kiranjith on 01/02/2025.
//

import SwiftUI

struct RootView: View {
	@StateObject private var coordinator: NavigationCoordinator
	private let flow: RootFlow
	
	init() {
		let navCoordinator = NavigationCoordinator()
		_coordinator = StateObject(wrappedValue: navCoordinator)
		self.flow = RootFlow(coordinator: navCoordinator)
	}
	
    var body: some View {
		NavigationStack(path: $coordinator.path) {
			flow.makeBreedsView()
				.navigationDestination(for: NavigationRoute.self) { route in
					route.builder()
				}
		}
    }
}

#Preview {
    RootView()
}
