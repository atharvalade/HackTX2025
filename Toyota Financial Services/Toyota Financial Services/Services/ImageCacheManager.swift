//
//  ImageCacheManager.swift
//  Toyota Financial Services
//
//  Created by Atharva Lade on 10/19/25.
//

import SwiftUI

@MainActor
class ImageCacheManager {
    static let shared = ImageCacheManager()
    
    private let cache = URLCache.shared
    private var preloadingTasks: [URL: Task<Void, Never>] = [:]
    
    private init() {
        // Configure URLCache with larger capacity for images
        let memoryCapacity = 50 * 1024 * 1024  // 50 MB
        let diskCapacity = 100 * 1024 * 1024   // 100 MB
        URLCache.shared = URLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity)
    }
    
    /// Preload a single image URL
    func preloadImage(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        // Check if already cached or being loaded
        let request = URLRequest(url: url)
        if cache.cachedResponse(for: request) != nil {
            return
        }
        
        // Avoid duplicate preload tasks
        guard preloadingTasks[url] == nil else { return }
        
        let task = Task {
            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                
                // Cache the response
                let cachedResponse = CachedURLResponse(response: response, data: data)
                cache.storeCachedResponse(cachedResponse, for: request)
                
                print("✅ Preloaded image: \(url.lastPathComponent)")
            } catch {
                print("❌ Failed to preload image: \(url.lastPathComponent) - \(error.localizedDescription)")
            }
            
            preloadingTasks.removeValue(forKey: url)
        }
        
        preloadingTasks[url] = task
    }
    
    /// Preload multiple images
    func preloadImages(urlStrings: [String]) {
        for urlString in urlStrings {
            preloadImage(urlString: urlString)
        }
    }
    
    /// Check if an image is cached
    func isImageCached(urlString: String) -> Bool {
        guard let url = URL(string: urlString) else { return false }
        let request = URLRequest(url: url)
        return cache.cachedResponse(for: request) != nil
    }
    
    /// Clear all cached images
    func clearCache() {
        cache.removeAllCachedResponses()
        preloadingTasks.values.forEach { $0.cancel() }
        preloadingTasks.removeAll()
    }
}

