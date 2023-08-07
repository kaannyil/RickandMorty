//
//  Results.swift
//  RickandMorty
//
//  Created by Kaan Yıldırım on 5.08.2023.
//

import Foundation

class Results: Codable {
    let id: Int?
    let name: String?
    let gender: String?
    let image: String?

    init(id: Int, name: String, gender: String, image: String) {
        self.id = id
        self.name = name
        self.gender = gender
        self.image = image
    }
}
