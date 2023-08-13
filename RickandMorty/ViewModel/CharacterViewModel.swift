//
//  CharacterViewModel.swift
//  RickandMorty
//
//  Created by Kaan Yıldırım on 13.08.2023.
//

import Foundation

class CharacterViewModel {
    var getItems = [Results]()
    
    func getCharacterItems(page: Int = 1, completion: @escaping (String?) -> ()) {
    
        CharacterManager.shared.getCharacterItems(page: page) { items,
            errorMessage in
            
            if let items = items {
                self.getItems.append(contentsOf: items.results)
                
                if items.info.next != nil {
                    // Recursive Call
                    self.getCharacterItems(page: page + 1, completion: completion)
                } else {
                    completion(errorMessage)
                }
            } else {
                completion(errorMessage)
            }
            
            /* if let items = items {
                self.getItems = items.results
            }
            completion(errorMessage) */
        }
    }
}
