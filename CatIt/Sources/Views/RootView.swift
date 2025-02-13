import SwiftUI

struct RootView: View {
	@StateObject private var coordinator: NavigationCoordinator
	private let rootFlow: RootFlow
	@State private var breedsService: BreedsListService
	
	init(coordinator: NavigationCoordinator) {
		_coordinator = StateObject(wrappedValue: coordinator)
		self.rootFlow = RootFlow(coordinator: coordinator)
		let dataStore = DefaultRESTDataStore()
		let breedsRepo = DefaultBreedsRepository(dataSource: dataStore)
		_breedsService = State(wrappedValue: BreedsListService(breedsRepo: breedsRepo))
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
