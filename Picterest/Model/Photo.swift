//
//  Photo.swift
//  Picterest
//
//  Created by 이경민 on 2022/07/25.
//

import Foundation
import UIKit

// MARK: - PhotoElement
struct PhotoElement: Codable {
    let id: String
    let width, height: Int
    let color: String
    let urls: Urls
    let links: Links
    var ratio: CGFloat {
        return CGFloat(height) / CGFloat(width)
    }
}

// MARK: - Links
struct Links: Codable {
    let download: String
}

// MARK: - Urls
struct Urls: Codable {
    let raw, full, regular, small: String
    let thumb, smallS3: String

    enum CodingKeys: String, CodingKey {
        case raw, full, regular, small, thumb
        case smallS3 = "small_s3"
    }
}

typealias Photo = [PhotoElement]
