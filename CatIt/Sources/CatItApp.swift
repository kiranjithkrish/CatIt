//
//  CatItApp.swift
//  CatIt
//
//  Created by kiranjith on 26/01/2025.
//

import SwiftUI
import SwiftUI

@main
struct CatItApp: App {
	//@State private var showSplash = true
	@StateObject private var coordinator = NavigationCoordinator()
	
	var body: some Scene {
		WindowGroup {
			ZStack {
				RootView(coordinator: coordinator)
//				if showSplash {
//					SplashView()
//						.transition(.opacity)
//				}
			}
			.onAppear {
				//showSplash = false
//				DispatchQueue.main.asyncAfter(deadline: .now()) {
//					withAnimation {
//						showSplash = false
//					}
//				}
			}
		}
	}
}
