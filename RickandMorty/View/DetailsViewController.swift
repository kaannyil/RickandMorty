//
//  DetailsViewController.swift
//  RickandMorty
//
//  Created by Kaan Yıldırım on 6.08.2023.
//

import UIKit

class DetailsViewController: UIViewController {
    @IBOutlet weak var detailsImageView: UIImageView!
    @IBOutlet weak var detailsNameLabel: UILabel!
    @IBOutlet weak var detailsGenderLabel: UILabel!
    @IBOutlet weak var detailsStatusLabel: UILabel!
    @IBOutlet weak var detailsView: UIView!
    
    var characterDetails: Results?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailsView.backgroundColor = UIColor.systemGray6
        detailsImageView.layer.cornerRadius = 6
        
        detailsView.layer.cornerRadius = 6
        detailsView.layer.borderWidth = 0.5
        detailsView.layer.borderColor = UIColor.lightGray.cgColor
        
        if let character = characterDetails {
            // Bu kodu resim ismiyle değiştireceksin. Deneyeceksin.
            if let url = URL(string: "https://rickandmortyapi.com/api/character/avatar/\(character.id!).jpeg") {
                    
                DispatchQueue.global().async {
                    let data = try? Data(contentsOf: url)
                    
                    DispatchQueue.main.async {
                        self.detailsImageView.image = UIImage(data: data!)
                    }
                }
            }
            
            navigationItem.title = character.name
            
            detailsNameLabel.text = "Name: \(character.name!)"
            detailsGenderLabel.text = "Gender: \(character.gender!)"
            detailsStatusLabel.text = "Status: \(character.status!)"
            
        }
    }
}
