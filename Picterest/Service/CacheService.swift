//
//  CacheService.swift
//  Picterest
//
//  Created by 이경민 on 2022/07/27.
//

import Foundation

class CacheService {
    static let shared = CacheService()
    
    let cache = NSCache<NSString,NSData>()
    
    func fetchData(_ key: String) -> Data? {
        guard let data = cache.object(forKey: key as NSString) else {
            return nil
        }
        return Data(referencing: data)
    }
    
    func uploadData(key: String, data: Data) {
        cache.setObject(NSData(data: data), forKey: key as NSString)
    }
}
