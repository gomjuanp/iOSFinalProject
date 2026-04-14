//
//  ViewController.swift
//  frontend
//
//  Created by Daniel Bajenov on 2026-03-29.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var accountTypeButton: UIButton!
    
    var selectedAccountType: String = "Buyer"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectedAccountType = "Buyer"
        accountTypeButton.setTitle("Buyer", for: .normal)
        setupAccountTypeMenu()
    }
    
    func setupAccountTypeMenu() {
        let buyer = UIAction(title: "Buyer") { [weak self] _ in
            self?.selectedAccountType = "Buyer"
            self?.accountTypeButton.setTitle("Buyer", for: .normal)
            print("Selected Buyer")
        }

        let seller = UIAction(title: "Seller") { [weak self] _ in
            self?.selectedAccountType = "Seller"
            self?.accountTypeButton.setTitle("Seller", for: .normal)
            print("Selected Seller")
        }

        accountTypeButton.menu = UIMenu(title: "Choose Account Type", children: [buyer, seller])
        accountTypeButton.showsMenuAsPrimaryAction = true
    }

    @IBAction func createAccountButtonTapped(_ sender: UIButton) {
        print("Create Account tapped")
        print("Current selectedAccountType = \(selectedAccountType)")
        
        if selectedAccountType == "Seller" {
            performSegue(withIdentifier: "goToSellerSide", sender: nil)
        } else {
            performSegue(withIdentifier: "goToBuyerSide", sender: nil)
        }
    }
}
