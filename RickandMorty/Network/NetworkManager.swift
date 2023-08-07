//
//  NetworkManager.swift
//  RickandMorty
//
//  Created by Kaan Yıldırım on 6.08.2023.
//

import Foundation

class NetworkManager {
    func takeData(url: URL, completion: @escaping ([ResultsAnswer]?)-> ()) {
        
        let url = URL(string: "https://rickandmortyapi.com/api/character")!
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print(error.localizedDescription)
                completion(nil)
            } else if let data = data {
                let characterArray = try? JSONDecoder().decode(ResultsAnswer.self, from: data)
                
                if let takeCharacterList = characterArray {
                    completion([takeCharacterList])
                }
            }
            /* let url = URL(string: "https://rickandmortyapi.com/api/character")!
             
             URLSession.shared.dataTask(with: url) { data, response, error in
             if error != nil || data == nil {
             print("ERROR !")
             return
             }
             
             do {
             let answer = try JSONDecoder().decode(ResultsAnswer.self, from: data!)
             
             if let takeCharacterList = answer.results {
             self.characterFeatureList = takeCharacterList
             }
             
             DispatchQueue.main.async {
             self.featuresCollectionView.reloadData()
             }
             } catch {
             print(error.localizedDescription)
             }
             }.resume() */
            
        }.resume()
    }
}
