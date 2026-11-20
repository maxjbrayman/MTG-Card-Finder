//
//  ImageManager.swift
//  MTG Card Finder
//
//  Created by Max Brayman on 11/4/26.
//

import UIKit

class ImageManager {
    static let shared = ImageManager()
    var cache = NSCache<NSString, UIImage>()
    
    func loadImage(from urlString: String?) async -> UIImage? {
        guard let urlString else { return nil }
        
        let cacheKey = NSString(string: urlString)
        if let cachedImage = cache.object(forKey: cacheKey) {
            return cachedImage
        }
        
        guard let url = URL(string: urlString) else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else { return nil }
            
            cache.setObject(image, forKey: cacheKey)
            return image
        } catch {
            return nil
        }
    }
}
