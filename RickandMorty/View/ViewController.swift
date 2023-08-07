//
//  ViewController.swift
//  RickandMorty
//
//  Created by Kaan Yıldırım on 5.08.2023.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var featuresCollectionView: UICollectionView!
    
    var characterFeatureList = [Results]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        featuresCollectionView.delegate = self
        featuresCollectionView.dataSource = self
        
        let layout = UICollectionViewFlowLayout()
        let width = featuresCollectionView.frame.width
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        let cellWidth = (width - 30) / 2
        layout.itemSize = CGSize(width: cellWidth, height: cellWidth * 1.4)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        
        featuresCollectionView.collectionViewLayout = layout
        
        let url = URL(string: "https://rickandmortyapi.com/api/character")!
        
        takeData(url: url)
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
                                
                
                /* if let takeCharacterList = answer.results {
                    self.characterFeatureList = takeCharacterList
                } */
                
                DispatchQueue.main.async {
                    self.featuresCollectionView.reloadData()
                }
            } catch {
                print(error.localizedDescription)
            }
        }.resume()
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let index = sender as? Int
        
        if let destinationVC = segue.destination as? DetailsViewController {
            destinationVC.characterDetails = characterFeatureList[index!]
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(characterFeatureList.count)
        return characterFeatureList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let character = characterFeatureList[indexPath.row]
        
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
                    
                    cell.characterImageView.layer.cornerRadius = 6
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
