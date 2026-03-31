//
//  ViewController.swift
//  frontend
//
//  Created by Daniel Bajenov on 2026-03-29.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var accountTypeButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        let buyer = UIAction(title: "Buyer") { _ in
            self.accountTypeButton.setTitle("Buyer", for: .normal)
        }

        let seller = UIAction(title: "Seller") { _ in
            self.accountTypeButton.setTitle("Seller", for: .normal)
        }

        accountTypeButton.menu = UIMenu(title: "", children: [buyer, seller])
        accountTypeButton.showsMenuAsPrimaryAction = true
    }


}

