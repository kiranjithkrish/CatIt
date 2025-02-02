//
//  SplashView.swift
//  CatIt
//
//  Created by kiranjith on 02/02/2025.
//

import SwiftUI

struct SplashView: View {
	var body: some View {
		VStack {
			Spacer()
			Image(systemName: "cat")
				.resizable()
				.scaledToFit()
				.frame(width: 150, height: 150)
				
			Text("Welcome to CatIt")
				.font(.largeTitle)
				.padding(.top, 20)
			Spacer()
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.background(Color.white)
	}
}


#Preview {
    SplashView()
}
