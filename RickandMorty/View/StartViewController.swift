//
//  StartViewController.swift
//  RickandMorty
//
//  Created by Kaan Yıldırım on 7.08.2023.
//

import UIKit

class StartViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func startButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "toVC", sender: nil)
    }
}
