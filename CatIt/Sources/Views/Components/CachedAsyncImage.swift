
//
//  BasicCachedAsyncImage.swift
//  CatIt
//
//  Created by kiranjith on 30/01/2025.
//


import SwiftUI


struct BasicCachedAsyncImage: View {
	private let url: URL?
	private let urlCache: URLCache
	
	@State private var loadedImage: Image? = nil
	@State private var isLoading = false
	@State private var loadError: Error? = nil
	
	var body: some View {
		Group {
			if let image = loadedImage {
				image
					.resizable()
					.aspectRatio(contentMode: .fill)
			} else if isLoading {
				ProgressView()
			} else if let _ = loadError {
				Image(systemName: "exclamationmark.triangle")
					.foregroundColor(.red)
			} else {
				Color.gray
					.onAppear {
						Task { await load() }
					}
			}
		}
	}
	
	init(url: URL?, urlCache: URLCache = .shared) {
		self.url = url
		self.urlCache = urlCache
	}
	
	private func load() async {
		isLoading = true
		do {
			let image = try await loadImage()
			loadedImage = image
		} catch {
			loadError = error
		}
		isLoading = false
	}
	
	private func loadImage() async throws -> Image {
		guard let url = url else {
			throw BasicCacheImageError.invalidURL
		}
		
		let request = URLRequest(url: url)
		
		if let cachedResponse = urlCache.cachedResponse(for: request),
		   let uiImage = UIImage(data: cachedResponse.data) {
			let loadedImage = Image(uiImage: uiImage)
			return loadedImage
		}
		
		let configuration = URLSessionConfiguration.default
		configuration.urlCache = urlCache
		
		let session = URLSession(configuration: configuration)
		let (data, response) = try await session.data(for: request)
		let cachedResponse = CachedURLResponse(response: response, data: data)
		urlCache.storeCachedResponse(cachedResponse, for: request)
		
		guard let uiImage = UIImage(data: data) else {
			throw BasicCacheImageError.invalidImageData
		}
		return Image(uiImage: uiImage)
		
		
	}
}


enum BasicCacheImageError: Error {
	case invalidURL
	case invalidImageData
}
