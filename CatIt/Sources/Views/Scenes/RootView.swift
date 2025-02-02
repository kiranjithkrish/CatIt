import SwiftUI

struct RootView: View {
	@StateObject private var coordinator: NavigationCoordinator
	private let rootFlow: RootFlow
	@StateObject private var breedsService: BreedsService
	
	init() {
		let navCoordinator = NavigationCoordinator()
		_coordinator = StateObject(wrappedValue: navCoordinator)
		
		self.rootFlow = RootFlow(coordinator: navCoordinator)
	
		let dataStore = DefaultRESTDataStore()
		let breedsRepo = DefaultBreedsRepository(dataSource: dataStore)
		_breedsService = StateObject(wrappedValue: BreedsService(breedsRepo: breedsRepo))
	}
	
	var body: some View {
		NavigationStack(path: $coordinator.path) {
			BreedsView(breedsService: breedsService, rootFlow: rootFlow)
				.navigationDestination(for: NavigationRoute.self) { route in
					route.builder()
				}
		}
	}
}
