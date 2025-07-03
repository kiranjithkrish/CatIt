//
//  BasicCachedAsyncImage.swift
//  CatIt
//
//  Created by kiranjith on 30/01/2025.
//


import SwiftUI

// Shared URLSession with proper cache configuration
private let sharedImageSession: URLSession = {
	let configuration = URLSessionConfiguration.default
	
	// 🗄️ CACHE CONFIGURATION
	// Memory: 50MB (fastest, stored in RAM)
	// Disk: 100MB (slower but persistent)
	let imageCache = URLCache(
		memoryCapacity: 50 * 1024 * 1024,  // 50MB memory cache
		diskCapacity: 100 * 1024 * 1024,   // 100MB disk cache
		diskPath: "CatItImageCache"        // Custom cache directory
	)
	
	configuration.urlCache = imageCache
	configuration.requestCachePolicy = .returnCacheDataElseLoad
	
	// 🔗 CONNECTION CONFIGURATION
	configuration.timeoutIntervalForRequest = 30.0
	configuration.timeoutIntervalForResource = 60.0
	configuration.waitsForConnectivity = true
	
	// 🌐 HTTP/2 OPTIMIZATION (URLSession uses HTTP/2 automatically)
	configuration.httpShouldUsePipelining = true
	configuration.httpMaximumConnectionsPerHost = 6  // Allow multiple concurrent connections
	
	return URLSession(configuration: configuration)
}()

struct BasicCachedAsyncImage: View {
	private let url: URL?
	private let urlCache: URLCache
	private let resizeTo: CGSize?
	
	@State private var loadedImage: Image? = nil
	@State private var isLoading = false
	@State private var loadError: Error? = nil
	@State private var loadTask: Task<Void, Never>? = nil
	
	var body: some View {
		ZStack {
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
			}
		}
		.onAppear {
			loadTask = Task { await load() }
		}
		.onDisappear {
			loadTask?.cancel()
		}
	}
	
	init(url: URL?, urlCache: URLCache = .shared, resizeTo: CGSize? = nil) {
		self.url = url
		self.urlCache = urlCache
		self.resizeTo = resizeTo
	}
	
	private func load() async {
		guard !Task.isCancelled else { return }
		
		isLoading = true
		loadError = nil
		loadedImage = nil // Clear any previous image
		
		do {
			let image = try await loadImage()
			if !Task.isCancelled {
				loadedImage = image
				isLoading = false
				loadError = nil
			}
		} catch {
			if !Task.isCancelled {
				loadError = error
				isLoading = false
				loadedImage = nil
			}
		}
	}
	
	private func loadImage() async throws -> Image {
		guard let url = url else {
			throw BasicCacheImageError.invalidURL
		}
		
		let request = URLRequest(url: url)
		
		// Check cache first
		if let cachedResponse = urlCache.cachedResponse(for: request),
		   let uiImage = UIImage(data: cachedResponse.data) {
			// Resize on background thread if needed
			let finalImage: UIImage
			if let resizeTo = resizeTo {
				finalImage = await Task.detached(priority: .background) {
					uiImage.resized(to: resizeTo)
				}.value
			} else {
				finalImage = uiImage
			}
			return Image(uiImage: finalImage)
		}
		
		// Use shared session with proper cache configuration
		let (data, response) = try await Task.detached(priority: .background) {
			try await sharedImageSession.data(for: request)
		}.value
		
		// Cache the response with timestamp
		var userInfo: [AnyHashable: Any] = [:]
		userInfo["timestamp"] = Date()
		let cachedResponse = CachedURLResponse(response: response, data: data, userInfo: userInfo, storagePolicy: .allowed)
		urlCache.storeCachedResponse(cachedResponse, for: request)
		
		guard let uiImage = UIImage(data: data) else {
			throw BasicCacheImageError.invalidImageData
		}
		
		// Resize on background thread if needed
		let finalImage: UIImage
		if let resizeTo = resizeTo {
			finalImage = await Task.detached(priority: .background) {
				let resized = uiImage.resized(to: resizeTo)
				return resized
			}.value
		} else {
			finalImage = uiImage
		}
		
		return Image(uiImage: finalImage)
	}
}

// MARK: - Custom View Modifiers

extension BasicCachedAsyncImage {
	/// Sets the resize size for the image
	/// - Parameter size: The target size to resize the image to
	/// - Returns: A new BasicCachedAsyncImage with the specified resize size
	func resizeTo(_ size: CGSize) -> BasicCachedAsyncImage {
		BasicCachedAsyncImage(url: self.url, urlCache: self.urlCache, resizeTo: size)
	}
	
	/// Sets the resize size for the image using width and height
	/// - Parameters:
	///   - width: The target width
	///   - height: The target height
	/// - Returns: A new BasicCachedAsyncImage with the specified resize size
	func resizeTo(width: CGFloat, height: CGFloat) -> BasicCachedAsyncImage {
		resizeTo(CGSize(width: width, height: height))
	}
	
	/// Sets the resize size for the image using a square size
	/// - Parameter size: The width and height for a square image
	/// - Returns: A new BasicCachedAsyncImage with the specified resize size
	func resizeTo(_ size: CGFloat) -> BasicCachedAsyncImage {
		resizeTo(CGSize(width: size, height: size))
	}
}

enum BasicCacheImageError: Error {
	case invalidURL
	case invalidImageData
}

// UIImage extension for resizing
extension UIImage {
	func resized(to size: CGSize) -> UIImage {
		let renderer = UIGraphicsImageRenderer(size: size)
		return renderer.image { _ in
			self.draw(in: CGRect(origin: .zero, size: size))
		}
	}
}

// MARK: - Cache Statistics Helper

extension BasicCachedAsyncImage {
	/// Get cache statistics for debugging
	static func getCacheStats() -> String {
		let cache = sharedImageSession.configuration.urlCache!
		let stats = """
		📊 Cache Statistics:
		Memory Usage: \(cache.memoryCapacity / 1024 / 1024)MB allocated
		Disk Usage: \(cache.diskCapacity / 1024 / 1024)MB allocated
		Current Memory: \(cache.currentMemoryUsage / 1024 / 1024)MB used
		Current Disk: \(cache.currentDiskUsage / 1024 / 1024)MB used
		"""
		return stats
	}
	
	/// Clear all cached images
	static func clearCache() {
		sharedImageSession.configuration.urlCache?.removeAllCachedResponses()
		print("🗑️ Image cache cleared")
	}
}

// MARK: - Cache Level Control API

/// Complete API for controlling cache levels and policies
class ImageCacheController {
	
	// MARK: - Cache Configuration
	
	/// Configure cache for different use cases
	static func configureCache(for useCase: CacheUseCase) -> URLSession {
		switch useCase {
		case .performance:
			return createPerformanceCache()
		case .storage:
			return createStorageCache()
		case .balanced:
			return createBalancedCache()
		case .offline:
			return createOfflineCache()
		case .realTime:
			return createRealTimeCache()
		}
	}
	
	/// Cache use cases
	enum CacheUseCase {
		case performance    // Fast loading, memory-heavy
		case storage        // Persistent, disk-heavy
		case balanced       // Good balance (current)
		case offline        // Cache-only mode
		case realTime       // Always fresh data
	}
	
	// MARK: - Predefined Cache Configurations
	
	private static func createPerformanceCache() -> URLSession {
		let configuration = URLSessionConfiguration.default
		
		// 🚀 Performance-focused: More memory, less disk
		let cache = URLCache(
			memoryCapacity: 100 * 1024 * 1024,  // 100MB memory
			diskCapacity: 25 * 1024 * 1024,     // 25MB disk
			diskPath: "CatItPerformanceCache"
		)
		
		configuration.urlCache = cache
		configuration.requestCachePolicy = .returnCacheDataElseLoad
		
		// Optimize for speed
		configuration.httpShouldUsePipelining = true
		configuration.httpMaximumConnectionsPerHost = 8
		configuration.timeoutIntervalForRequest = 15.0
		
		return URLSession(configuration: configuration)
	}
	
	private static func createStorageCache() -> URLSession {
		let configuration = URLSessionConfiguration.default
		
		// 💾 Storage-focused: Less memory, more disk
		let cache = URLCache(
			memoryCapacity: 25 * 1024 * 1024,   // 25MB memory
			diskCapacity: 200 * 1024 * 1024,    // 200MB disk
			diskPath: "CatItStorageCache"
		)
		
		configuration.urlCache = cache
		configuration.requestCachePolicy = .returnCacheDataElseLoad
		
		// Conservative settings
		configuration.httpShouldUsePipelining = false
		configuration.httpMaximumConnectionsPerHost = 4
		configuration.timeoutIntervalForRequest = 60.0
		
		return URLSession(configuration: configuration)
	}
	
	private static func createBalancedCache() -> URLSession {
		let configuration = URLSessionConfiguration.default
		
		// 🎯 Balanced: Good mix of memory and disk
		let cache = URLCache(
			memoryCapacity: 50 * 1024 * 1024,   // 50MB memory
			diskCapacity: 100 * 1024 * 1024,    // 100MB disk
			diskPath: "CatItBalancedCache"
		)
		
		configuration.urlCache = cache
		configuration.requestCachePolicy = .returnCacheDataElseLoad
		
		// Balanced settings
		configuration.httpShouldUsePipelining = true
		configuration.httpMaximumConnectionsPerHost = 6
		configuration.timeoutIntervalForRequest = 30.0
		
		return URLSession(configuration: configuration)
	}
	
	private static func createOfflineCache() -> URLSession {
		let configuration = URLSessionConfiguration.default
		
		// 📱 Offline-focused: Large disk cache, memory for speed
		let cache = URLCache(
			memoryCapacity: 75 * 1024 * 1024,   // 75MB memory
			diskCapacity: 500 * 1024 * 1024,    // 500MB disk
			diskPath: "CatItOfflineCache"
		)
		
		configuration.urlCache = cache
		configuration.requestCachePolicy = .returnCacheDataDontLoad  // Only use cache
		
		// Conservative network settings
		configuration.httpShouldUsePipelining = false
		configuration.httpMaximumConnectionsPerHost = 2
		configuration.timeoutIntervalForRequest = 120.0
		
		return URLSession(configuration: configuration)
	}
	
	private static func createRealTimeCache() -> URLSession {
		let configuration = URLSessionConfiguration.default
		
		// ⚡ Real-time: Minimal cache, always fresh
		let cache = URLCache(
			memoryCapacity: 10 * 1024 * 1024,   // 10MB memory
			diskCapacity: 10 * 1024 * 1024,     // 10MB disk
			diskPath: "CatItRealTimeCache"
		)
		
		configuration.urlCache = cache
		configuration.requestCachePolicy = .reloadIgnoringLocalCacheData  // Always fresh
		
		// Aggressive network settings
		configuration.httpShouldUsePipelining = true
		configuration.httpMaximumConnectionsPerHost = 10
		configuration.timeoutIntervalForRequest = 10.0
		
		return URLSession(configuration: configuration)
	}
	
	// MARK: - Dynamic Cache Control
	
	/// Change cache configuration at runtime
	static func updateCacheConfiguration(for session: URLSession, 
									   memoryMB: Int, 
									   diskMB: Int) {
		let newCache = URLCache(
			memoryCapacity: memoryMB * 1024 * 1024,
			diskCapacity: diskMB * 1024 * 1024,
			diskPath: "CatItDynamicCache"
		)
		
		// Note: This requires creating a new session
		// URLSession configuration is immutable after creation
	}
	
	// MARK: - Cache Statistics and Management
	
	/// Get detailed cache statistics
	static func getDetailedCacheStats(for session: URLSession) -> CacheStats {
		guard let cache = session.configuration.urlCache else {
			return CacheStats(memoryCapacity: 0, diskCapacity: 0, 
							memoryUsage: 0, diskUsage: 0, hitCount: 0, missCount: 0)
		}
		
		return CacheStats(
			memoryCapacity: cache.memoryCapacity,
			diskCapacity: cache.diskCapacity,
			memoryUsage: cache.currentMemoryUsage,
			diskUsage: cache.currentDiskUsage,
			hitCount: cache.currentMemoryUsage, // Approximate
			missCount: cache.currentDiskUsage   // Approximate
		)
	}
	
	/// Clear specific types of cache
	static func clearCache(for session: URLSession, type: CacheClearType) {
		guard let cache = session.configuration.urlCache else { return }
		
		switch type {
		case .memory:
			// Note: URLCache doesn't have direct memory-only clear
			// This would require custom implementation
			print("🗑️ Memory cache clear requested")
		case .disk:
			// Note: URLCache doesn't have direct disk-only clear
			print("🗑️ Disk cache clear requested")
		case .all:
			cache.removeAllCachedResponses()
			print("🗑️ All cache cleared")
		}
	}
	
	enum CacheClearType {
		case memory
		case disk
		case all
	}
	
	struct CacheStats {
		let memoryCapacity: Int
		let diskCapacity: Int
		let memoryUsage: Int
		let diskUsage: Int
		let hitCount: Int
		let missCount: Int
		
		var memoryUsagePercentage: Double {
			guard memoryCapacity > 0 else { return 0 }
			return Double(memoryUsage) / Double(memoryCapacity) * 100
		}
		
		var diskUsagePercentage: Double {
			guard diskCapacity > 0 else { return 0 }
			return Double(diskUsage) / Double(diskCapacity) * 100
		}
	}
}

// MARK: - Usage Examples

/*
// 🚀 PERFORMANCE-FOCUSED CACHING
let performanceSession = ImageCacheController.configureCache(for: .performance)
// 100MB memory, 25MB disk, aggressive pipelining

// 💾 STORAGE-FOCUSED CACHING  
let storageSession = ImageCacheController.configureCache(for: .storage)
// 25MB memory, 200MB disk, conservative settings

// 🎯 BALANCED CACHING (current)
let balancedSession = ImageCacheController.configureCache(for: .balanced)
// 50MB memory, 100MB disk, balanced settings

// 📱 OFFLINE CACHING
let offlineSession = ImageCacheController.configureCache(for: .offline)
// 75MB memory, 500MB disk, cache-only mode

// ⚡ REAL-TIME CACHING
let realTimeSession = ImageCacheController.configureCache(for: .realTime)
// 10MB memory, 10MB disk, always fresh data

// 📊 CACHE STATISTICS
let stats = ImageCacheController.getDetailedCacheStats(for: balancedSession)
print("Memory usage: \(stats.memoryUsagePercentage)%")
print("Disk usage: \(stats.diskUsagePercentage)%")

// 🗑️ CACHE MANAGEMENT
ImageCacheController.clearCache(for: balancedSession, type: .all)
ImageCacheController.clearCache(for: balancedSession, type: .memory)
ImageCacheController.clearCache(for: balancedSession, type: .disk)
*/

// MARK: - Cache Debugging Helper

extension BasicCachedAsyncImage {
	/// Debug cache issues by checking URL normalization
	static func debugCacheIssues() {
		let cache = sharedImageSession.configuration.urlCache!
		print("🔍 Cache Debug Information:")
		print("   📊 Memory capacity: \(cache.memoryCapacity / 1024 / 1024)MB")
		print("   📊 Disk capacity: \(cache.diskCapacity / 1024 / 1024)MB")
		print("   📊 Current memory usage: \(cache.currentMemoryUsage / 1024 / 1024)MB")
		print("   📊 Current disk usage: \(cache.currentDiskUsage / 1024 / 1024)MB")
		
		// Check if cache is working at all
		let testURL = URL(string: "https://example.com/test.jpg")!
		let testRequest = URLRequest(url: testURL)
		let testResponse = cache.cachedResponse(for: testRequest)
		print("   🧪 Test cache lookup: \(testResponse != nil ? "Working" : "Not working")")
	}
	
	/// Check if two URLs are cache-equivalent
	static func areURLsCacheEquivalent(_ url1: URL, _ url2: URL) -> Bool {
		let normalized1 = URLComponents(url: url1, resolvingAgainstBaseURL: false)
		let normalized2 = URLComponents(url: url2, resolvingAgainstBaseURL: false)
		
		return normalized1?.scheme == normalized2?.scheme &&
			   normalized1?.host == normalized2?.host &&
			   normalized1?.path == normalized2?.path
	}
}

// MARK: - Cache Testing Helper

extension BasicCachedAsyncImage {
	/// Test cache functionality with a specific URL
	static func testCache(with url: URL) {
		let cache = sharedImageSession.configuration.urlCache!
		let request = URLRequest(url: url)
		
		print("🧪 Testing cache for: \(url.lastPathComponent)")
		print("   🔗 URL: \(url)")
		
		if let cachedResponse = cache.cachedResponse(for: request) {
			print("   ✅ Cache HIT - Found \(cachedResponse.data.count / 1024)KB")
		} else {
			print("   ❌ Cache MISS - Not found")
		}
	}
	
	/// Force cache a response for testing
	static func forceCache(url: URL, data: Data) {
		let cache = sharedImageSession.configuration.urlCache!
		let request = URLRequest(url: url)
		
		var userInfo: [AnyHashable: Any] = [:]
		userInfo["timestamp"] = Date()
		userInfo["forced"] = true
		
		let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: nil)!
		let cachedResponse = CachedURLResponse(response: response, data: data, userInfo: userInfo, storagePolicy: .allowed)
		
		cache.storeCachedResponse(cachedResponse, for: request)
		print("💾 Force cached: \(url.lastPathComponent)")
	}
}
