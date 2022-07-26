//
//  BundleExtension.swift
//  Picterest
//
//  Created by 이경민 on 2022/07/25.
//

import Foundation

extension Bundle {
    var accessKey: String {
        guard let key = Self.main.object(forInfoDictionaryKey: "ACCESSKEY") as? String else {
            print("Could not find key")
            return ""
        }
        return key.replacingOccurrences(of: " ", with: "")
    }
}
