//
//  CharacterManager.swift
//  RickandMorty
//
//  Created by Kaan Yıldırım on 13.08.2023.
//

import Foundation

// MARK: - Farklı Yöntemle veriler çekilmek istendiğinde ara katman görevi görecek.
class CharacterManager {
    static let shared = CharacterManager()
    
    func getCharacterItems (page: Int, completion: @escaping (ResultsAnswer?, String?) -> ()) {
     
        let url = URL(string: "\(NetworkHelper().baseURL)character?page=\(page)")
        
        NetworkManager.shared.performSegue(type: ResultsAnswer.self, url: url!) { result in
            switch result {
            case .success(let items):
                completion(items, nil)
            case .failure(let error):
                completion(nil, error.rawValue)
            }
        }
    }
}
