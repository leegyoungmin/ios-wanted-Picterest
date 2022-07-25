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
}

// MARK: - Links
struct Links: Codable {
    let download: String
}

// MARK: - Urls
struct Urls: Codable {
    let raw: String
}

typealias Photo = [PhotoElement]
