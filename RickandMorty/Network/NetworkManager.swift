//
//  NetworkManager.swift
//  RickandMorty
//
//  Created by Kaan Yıldırım on 13.08.2023.
//

import Foundation
import Alamofire

class NetworkManager {
    static let shared = NetworkManager()
    
    func performSegue <T: Codable>(type: T.Type, url: URL,
                                   completion: @escaping (Result<T, ErrorTypes>) -> ()) {
        AF.request(url, method: .get).responseJSON { response in
            if let data = response.data {
                self.handleResponse(data: data) { response in
                    completion(response)
                }
            }
        }
        
        /* URLSession.shared.dataTask(with: url) { data, response, error in
            if let _ = error {
                completion(.failure(.generalError))
            } else if let data = data {
                self.handleResponse(data: data) { response in
                    completion(response)
                }
            }
        } */
    }
    
    private func handleResponse <T: Codable>(data: Data,
                                             completion: @escaping (Result<T, ErrorTypes>) -> ()) {
        do {
            let decoder = JSONDecoder()
            let RMArray = try decoder.decode(T.self, from: data)
            completion(.success(RMArray))
        } catch let DecodingError {
            print("Decoding Error: \(DecodingError)")
            completion(.failure(.invalidData))
        }
    }
}
