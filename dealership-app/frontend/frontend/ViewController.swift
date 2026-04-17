//
//  ViewController.swift
//  frontend
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var accountTypeButton: UIButton!
    
    var selectedAccountType = "Buyer"

    override func viewDidLoad() {
        super.viewDidLoad()

        accountTypeButton.setTitle("Buyer", for: .normal)

        let buyer = UIAction(title: "Buyer") { _ in
            self.selectedAccountType = "Buyer"
            self.accountTypeButton.setTitle("Buyer", for: .normal)
        }

        let seller = UIAction(title: "Seller") { _ in
            self.selectedAccountType = "Seller"
            self.accountTypeButton.setTitle("Seller", for: .normal)
        }

        accountTypeButton.menu = UIMenu(title: "", children: [buyer, seller])
        accountTypeButton.showsMenuAsPrimaryAction = true
    }

    @IBAction func createAccountButtonTapped(_ sender: UIButton) {
        let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        if name.isEmpty || email.isEmpty || password.isEmpty {
            showAlert(title: "Missing Info", message: "Please fill in all fields.")
            return
        }

        if CoreDataManager.shared.userExists(email: email) {
            showAlert(title: "User Exists", message: "An account with this email already exists.")
            return
        }

        CoreDataManager.shared.saveUser(
            name: name,
            email: email,
            password: password,
            accountType: selectedAccountType
        )

        if selectedAccountType == "Seller" {
            performSegue(withIdentifier: "goToSellerSide", sender: nil)
        } else {
            performSegue(withIdentifier: "goToBuyerSide", sender: nil)
        }
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
