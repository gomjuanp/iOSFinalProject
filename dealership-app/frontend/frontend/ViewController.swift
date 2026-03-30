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

        let customer = UIAction(title: "Customer") { _ in
            self.accountTypeButton.setTitle("Customer", for: .normal)
        }

        let dealer = UIAction(title: "Dealer") { _ in
            self.accountTypeButton.setTitle("Dealer", for: .normal)
        }

        accountTypeButton.menu = UIMenu(title: "", children: [customer, dealer])
        accountTypeButton.showsMenuAsPrimaryAction = true
    }


}

