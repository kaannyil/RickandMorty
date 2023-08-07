//
//  Info.swift
//  RickandMorty
//
//  Created by Kaan Yıldırım on 6.08.2023.
//

import Foundation

class Info: Codable {
    let count: Int?
    let pages: Int?
    let next: String?
    let prev: String?
    
    init(count: Int, pages: Int, next: String, prev: String) {
        self.count = count
        self.pages = pages
        self.next = next
        self.prev = prev
    }
}
