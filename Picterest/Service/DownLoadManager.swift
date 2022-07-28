//
//  FileManager.swift
//  Picterest
//
//  Created by 이경민 on 2022/07/28.
//

import Foundation

class DownLoadManager {
    var folderURL: URL? {
        return FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first?.appendingPathComponent(name)
    }
    var name: String = "Picterest"
    
    init() {
        createFolder()
    }
    
    func fetchData(key: String) -> Data? {
        guard let writeURL = folderURL?.appendingPathComponent(key) else {
            return nil
        }
        return FileManager.default.contents(atPath: writeURL.path)
    }
    
    func uploadData(_ key: String, data: Data) -> Bool {
        guard let writeURL = folderURL?.appendingPathComponent(key) else {
            return false
        }
        try? data.write(to: writeURL)
        
        return true
    }
    
    private func createFolder() {
        guard let folderURL = folderURL else {
            return
        }

        if FileManager.default.fileExists(atPath: folderURL.path) {
            return
        }
        
        try? FileManager.default.createDirectory(
            at: folderURL,
            withIntermediateDirectories: true
        )
    }
}
