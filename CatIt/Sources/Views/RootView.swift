import SwiftUI

struct RootView: View {
	@StateObject private var coordinator: NavigationCoordinator
	private let rootFlow: RootFlow
	@StateObject private var breedsService: BreedsService
	
	init(coordinator: NavigationCoordinator) {
		
		_coordinator = StateObject(wrappedValue: coordinator)
		
		self.rootFlow = RootFlow(coordinator: coordinator)
	
		let dataStore = DefaultRESTDataStore()
		let breedsRepo = DefaultBreedsRepository(dataSource: dataStore)
		_breedsService = StateObject(wrappedValue: BreedsService(breedsRepo: breedsRepo))
	}
	
	var body: some View {
		NavigationStack(path: $coordinator.path) {
			BreedsListView(breedsService: breedsService, rootFlow: rootFlow)
				.navigationDestination(for: NavigationRoute.self) { route in
					route.builder()
				}
		}
	}
}
