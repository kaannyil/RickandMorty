//
//  ViewController.swift
//  RickandMorty
//
//  Created by Kaan Yıldırım on 5.08.2023.
//

import UIKit.UICollectionView
import UIKit.UISearchBar
import UIKit.UIScrollView

import Alamofire

import SkeletonView

class ViewController: UIViewController {
    
    @IBOutlet weak var featuresCollectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var characterFeatureList = [Results]()
    var currentPage = 1
    
    let baseUrl: String = "https://rickandmortyapi.com/api/character"
     
    var resultSearch = [Results]()
    var isSearching = false
    
    let defaultRadiusSet: CGFloat = 6
    let waitSkeletonTime = 2.5
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        featuresCollectionView.delegate = self
        featuresCollectionView.dataSource = self
        searchBar.delegate = self
        
        title = "Characters"
        
        let layout = UICollectionViewFlowLayout()
        let width = featuresCollectionView.frame.width
        let cellWidth = (width - 30) / 2
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: cellWidth, height: cellWidth * 1.4)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        
        featuresCollectionView.collectionViewLayout = layout
        featuresCollectionView.layer.cornerRadius = defaultRadiusSet
        
        searchBar.layer.borderWidth = 1
        searchBar.layer.borderColor = UIColor.systemBackground.cgColor
        
        fetchAllData()
    }
    
    // MARK: - API Caller
    
    func fetchAllData() {
        self.fetchPageWithAlamofire(url: self.baseUrl)
        // self.fetchPage(url: self.baseUrl)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + waitSkeletonTime, execute: {
            
            self.featuresCollectionView.stopSkeletonAnimation()
            self.featuresCollectionView.hideSkeleton(reloadDataAfter: true,
                                                     transition: .crossDissolve(0.25))
        })
  
        featuresCollectionView.isSkeletonable = true
        featuresCollectionView.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .silver),
                                                            animation: nil,
                                                            transition: .crossDissolve(0.5))
    }

    
    /* // MARK: - Single Page Data
    func takeData(url: URL) {
        // let url = URL(string: "https://rickandmortyapi.com/api/character")!

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received !")
                return
            }
            
            do {
                
                let answer = try JSONDecoder().decode(ResultsAnswer.self, from: data)
                
                if let character = answer.results {
                    self.characterFeatureList = character
                }
                   
                DispatchQueue.main.async {
                    self.featuresCollectionView.reloadData()
                }
            } catch {
                print("JSON Decoding Error: \(error.localizedDescription)")
            }
        }.resume()
    } */

    /* // MARK: - URLSession
    func fetchPage(url: String) {
        guard let url = URL(string: url) else {
            return
        }
            
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received.")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let answer = try decoder.decode(ResultsAnswer.self, from: data)
                
                
                if let characters = answer.results {
                    self.characterFeatureList.append(contentsOf: characters)
                }
                
                if let nextURL = answer.info.next {
                    self.fetchPage(url: nextURL)
                } else {
                    DispatchQueue.main.async {
                        self.processData()
                        self.featuresCollectionView.reloadData()
                    }
                }
                
            } catch {
                print("JSON decoding error: \(error.localizedDescription)")
            }
        }.resume()
    } */
    
    // MARK: - ALAMOFIRE
    func fetchPageWithAlamofire(url: String) {
        guard let url = URL(string: url) else {
            return
        }
        
        AF.request(url, method: .get).responseJSON { response in
            if let data = response.data {
                do {
                    let decoder = JSONDecoder()
                    let answer = try decoder.decode(ResultsAnswer.self, from: data)
                    
                    
                    if let characters = answer.results {
                        self.characterFeatureList.append(contentsOf: characters)
                    }
                    
                    if let nextURL = answer.info.next {
                        self.fetchPageWithAlamofire(url: nextURL)
                    } else {
                        DispatchQueue.main.async {
                            self.processData()
                            self.featuresCollectionView.reloadData()
                        }
                    }
                } catch {
                    print("JSON decoding error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func processData() {
            print("Total Character: \(characterFeatureList.count)")
    }
}

// MARK: - CollectionView
extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource,
                            SkeletonCollectionViewDataSource {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let index = sender as? Int
        
        if isSearching {
            if let destinationVC = segue.destination as? DetailsViewController {
                destinationVC.characterDetails = resultSearch[index!]
            }
        } else {
            if let destinationVC = segue.destination as? DetailsViewController {
                destinationVC.characterDetails = characterFeatureList[index!]
            }
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView,
                                cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return CharacterCollectionViewCell.identifier
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        // print(characterFeatureList.count)
        
        if isSearching {
            return resultSearch.count
        } else {
            return characterFeatureList.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let character: Results
        
        if isSearching {
            character = resultSearch[indexPath.row]
        } else {
            character = characterFeatureList[indexPath.row]
        }
        
        guard let cell = featuresCollectionView.dequeueReusableCell(withReuseIdentifier: CharacterCollectionViewCell.identifier,
                                                                    for: indexPath) as? CharacterCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.backgroundColor = UIColor.systemGray5
        
        cell.characterNameLabel.text = character.name
        
        if let imageURL = URL(string: "https://rickandmortyapi.com/api/character/avatar/\(character.id!).jpeg") {
            
            DispatchQueue.global().async {
                
                if let data = try? Data(contentsOf: imageURL) {
                    DispatchQueue.main.async {
                        
                        cell.characterImageView.image = UIImage(data: data)
                        cell.characterImageView.layer.cornerRadius = self.defaultRadiusSet
                    }
                }
            }
        }
        
        cell.characterImageView.image = UIImage(named: character.image!)
        
        cell.layer.cornerRadius = 6
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.borderWidth = 0.5
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toDetailVC", sender: indexPath.row)
    }
}

// MARK: - SearchBar
extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("Result Search: \(searchText)")
        
        if searchText == "" {
            isSearching = false
            
            // print(characterFeatureList.count)
        } else {
            isSearching = true

            // resultSearch = characterFeatureList.filter({ $0.name?.lowercased().contains(searchText.lowercased()) })
            
            resultSearch = characterFeatureList.filter { result in
                let containsSearchText = result.name?.lowercased().contains(searchText.lowercased()) ?? false
                return containsSearchText
            }
            print(resultSearch.count)
        }
        featuresCollectionView.reloadData()
    }
}
