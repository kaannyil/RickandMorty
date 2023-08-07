//
//  CharacterCollectionViewCell.swift
//  RickandMorty
//
//  Created by Kaan Yıldırım on 5.08.2023.
//

import UIKit

class CharacterCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var characterImageView: UIImageView!
    @IBOutlet weak var characterNameLabel: UILabel!
    
    static let identifier = "characterCollectionCell"
}
