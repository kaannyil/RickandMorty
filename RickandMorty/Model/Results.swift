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
    let status: String?
    let image: String?

    init(id: Int, name: String, gender: String, status: String, image: String) {
        self.id = id
        self.name = name
        self.gender = gender
        self.status = status
        self.image = image
    }
}
