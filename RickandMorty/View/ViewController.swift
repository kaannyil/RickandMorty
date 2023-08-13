//
//  ViewController.swift
//  RickandMorty
//
//  Created by Kaan Yıldırım on 5.08.2023.
//

import UIKit
import Alamofire
import SkeletonView

class ViewController: UIViewController {
    
    @IBOutlet weak var featuresCollectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    let characterViewModel = CharacterViewModel()
    var characterFeatureList = [Results]()
     
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
    
    // Bazen fotoğraflarda yanlış yüklenlemeler oluyor. Bu yüzden
    // sayfadan ayrıldıktan sonra tekrardan güncelliyorum.
    override func viewDidDisappear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.featuresCollectionView.reloadData()
        }
    }
    
    // MARK: - API Caller
    
    func fetchAllData() {
        takeDataWithGenericLayer()
        
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
    
    // MARK: - Generic Network Layer and Take Data with Alamofire
    func takeDataWithGenericLayer() {
        characterViewModel.getCharacterItems { errorMessage in
            if let errorMessage = errorMessage {
                print("Error: \(errorMessage)")
            }
            
            DispatchQueue.main.async {
                self.featuresCollectionView.reloadData()
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
                destinationVC.characterDetails = characterViewModel.getItems[index!]
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
        if isSearching {
            return resultSearch.count
        } else {
            return characterViewModel.getItems.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let character: Results
        
        if isSearching {
            character = resultSearch[indexPath.row]
        } else {
            character = characterViewModel.getItems[indexPath.row]
        }
        
        guard let cell = featuresCollectionView.dequeueReusableCell(withReuseIdentifier: CharacterCollectionViewCell.identifier,
                                                                    for: indexPath) as? CharacterCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.backgroundColor = UIColor.systemGray5
        
        cell.characterNameLabel.text = character.name
        
        if let characterID = character.id {
            if let imageURL = URL(string: "https://rickandmortyapi.com/api/character/avatar/\(characterID).jpeg") {
                
                DispatchQueue.global().async {
                    
                    if let data = try? Data(contentsOf: imageURL) {
                        DispatchQueue.main.async {
                            
                            cell.characterImageView.image = UIImage(data: data)
                            cell.characterImageView.layer.cornerRadius = self.defaultRadiusSet
                        }
                    }
                }
            }
        }
        
        if let characterImage = character.image {
            cell.characterImageView.image = UIImage(named: characterImage)
        }
        
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
            
        } else {
            isSearching = true

            resultSearch = characterViewModel.getItems.filter { result in
                let containSearchText = result.name?.lowercased().contains(searchText.lowercased()) ?? false
                return containSearchText
            }
            print(resultSearch.count)
        }
        
        DispatchQueue.main.async {
            self.featuresCollectionView.reloadData()
        }
    }
}
