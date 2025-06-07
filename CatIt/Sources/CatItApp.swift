//
//  CatItApp.swift
//  CatIt
//
//  Created by kiranjith on 26/01/2025.
//

import SwiftUI

@main
struct CatItApp: App {
	@State private var showSplash = true
	@StateObject private var coordinator = NavigationCoordinator()
	
	var body: some Scene {
		WindowGroup {
			ZStack {
				RootView(coordinator: coordinator)
				if showSplash {
					SplashView()
						.transition(.opacity)
				}
			}
			.onAppear {
				DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
					withAnimation {
						showSplash = false
					}
				}
			}
		}
	}
}
