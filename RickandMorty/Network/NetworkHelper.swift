//
//  NetworkHelper.swift
//  RickandMorty
//
//  Created by Kaan Yıldırım on 13.08.2023.
//

import Foundation

enum ErrorTypes: String, Error {
    case invalidURL = "Invalid URL."
    case invalidData = "Invalid Data."
    case generalError = "General Error."
}

class NetworkHelper {
    static let shared = NetworkHelper()
    
    var baseURL = "https://rickandmortyapi.com/api/"
}
