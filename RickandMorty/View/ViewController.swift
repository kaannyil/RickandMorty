//
//  ViewController.swift
//  RickandMorty
//
//  Created by Kaan Yıldırım on 5.08.2023.
//

import UIKit
import SkeletonView

class ViewController: UIViewController {
    
    @IBOutlet weak var featuresCollectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var characterFeatureList = [Results]()
    
    
    var resultSearch = [Results]()
    var isSearching = false
    
    let defaultRadiusSet: CGFloat = 6
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        featuresCollectionView.delegate = self
        featuresCollectionView.dataSource = self
        
        searchBar.delegate = self
        
        title = "Characters"
        
        let layout = UICollectionViewFlowLayout()
        let width = featuresCollectionView.frame.width
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        let cellWidth = (width - 30) / 2
        layout.itemSize = CGSize(width: cellWidth, height: cellWidth * 1.4)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        
        featuresCollectionView.collectionViewLayout = layout
        featuresCollectionView.layer.cornerRadius = defaultRadiusSet
        
        searchBar.layer.borderWidth = 1
        searchBar.layer.borderColor = view.backgroundColor?.cgColor
        
        let url = URL(string: "https://rickandmortyapi.com/api/character")!
        
        takeData(url: url)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        featuresCollectionView.isSkeletonable = true
        featuresCollectionView.showAnimatedGradientSkeleton(usingGradient:
                .init(baseColor: .concrete),
                                                            animation: nil,
                                                            transition: .crossDissolve(0.25))
    }
    
    func takeData(url: URL) {
        // let url = URL(string: "https://rickandmortyapi.com/api/character")!

        URLSession.shared.dataTask(with: url) { data, response, error in
            if error != nil || data == nil {
                print("ERROR !")
                return
            }
            
            do {
                
                let answer = try JSONDecoder().decode(ResultsAnswer.self, from: data!)
                self.characterFeatureList.append(contentsOf: answer.results!)
                
                if let nextURLString = answer.info.next, let nextURL = URL(string: nextURLString) {
                    self.takeData(url: nextURL)
                }
                   
                DispatchQueue.main.async {
                    self.featuresCollectionView.reloadData()
                }
            } catch {
                print(error.localizedDescription)
            }
        }.resume()
    }
    
    func takeData2(url: URL) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if error != nil || data == nil {
                    print("ERROR !")
                    return
                }
                
                do {
                    let answer = try JSONDecoder().decode(ResultsAnswer.self, from: data!)
                    self.characterFeatureList.append(contentsOf: answer.results!)
                    
                    if let nextURLString = answer.info.next, let nextURL = URL(string: nextURLString) {
                        self.takeData(url: nextURL)
                    }
                       
                } catch {
                    print(error.localizedDescription)
                }
            }.resume()
            
            self.featuresCollectionView.stopSkeletonAnimation()
            self.featuresCollectionView.hideSkeleton()
            
            self.featuresCollectionView.reloadData()
        })
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, SkeletonCollectionViewDelegate, SkeletonCollectionViewDataSource {
    
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
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> SkeletonView.ReusableCellIdentifier {
        return CharacterCollectionViewCell.identifier
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // print(characterFeatureList.count)
        
        if isSearching {
            return resultSearch.count
        } else {
            return characterFeatureList.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
        
        cell.characterNameLabel.text = character.name
        // cell.characterGenderLabel.text = "Gender: \(character.gender!)"
        
        if let imageURL = URL(string: "https://rickandmortyapi.com/api/character/avatar/\(character.id!).jpeg") {
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: imageURL)
                
                DispatchQueue.main.async {
                    cell.characterImageView.image = UIImage(data: data!)
                    
                    cell.characterImageView.layer.cornerRadius = self.defaultRadiusSet
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

extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("Result Search: \(searchText)")
        
        if searchText == "" {
            isSearching = false
        } else {
            isSearching = true

            // resultSearch = characterFeatureList.filter({ $0.name?.lowercased().contains(searchText.lowercased()) })
            
            resultSearch = characterFeatureList.filter { result in
                let containsSearchText = result.name?.lowercased().contains(searchText.lowercased()) ?? false
                return containsSearchText
            }
        }
        print(resultSearch.count)
        
        featuresCollectionView.reloadData()
        
    }
}
