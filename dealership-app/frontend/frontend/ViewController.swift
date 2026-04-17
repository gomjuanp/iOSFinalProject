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
        configureUI()
        configureAccountTypeMenu()
    }

    private func configureUI() {
        view.backgroundColor = AppTheme.background
        nameTextField.applyMarketplaceStyle(placeholderText: "Your full name")
        emailTextField.applyMarketplaceStyle(placeholderText: "name@email.com")
        passwordTextField.applyMarketplaceStyle(placeholderText: "Enter a password")
        passwordTextField.isSecureTextEntry = true
        passwordTextField.autocapitalizationType = .none
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none

        accountTypeButton.applySecondaryStyle(title: "Buyer")
        view.subviews.compactMap { $0 as? UIButton }.forEach { button in
            if button != accountTypeButton {
                button.applyPrimaryStyle()
            }
        }
    }

    private func configureAccountTypeMenu() {
        accountTypeButton.setTitle("Buyer", for: .normal)

        let buyer = UIAction(title: "Buyer") { _ in
            self.selectedAccountType = "Buyer"
            self.accountTypeButton.setTitle("Buyer", for: .normal)
        }

        let seller = UIAction(title: "Seller") { _ in
            self.selectedAccountType = "Seller"
            self.accountTypeButton.setTitle("Seller", for: .normal)
        }

        accountTypeButton.menu = UIMenu(title: "Choose account type", children: [buyer, seller])
        accountTypeButton.showsMenuAsPrimaryAction = true
    }

    @IBAction func createAccountButtonTapped(_ sender: UIButton) {
        let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        if name.isEmpty || email.isEmpty || password.isEmpty {
            showBasicAlert(title: "Missing Info", message: "Please fill in all fields.")
            return
        }

        if CoreDataManager.shared.userExists(email: email) {
            showBasicAlert(title: "User Exists", message: "An account with this email already exists.")
            return
        }

        CoreDataManager.shared.saveUser(
            name: name,
            email: email,
            password: password,
            accountType: selectedAccountType
        )

        SessionManager.shared.saveSession(name: name, email: email, accountType: selectedAccountType)

        presentMarketplaceArea(for: selectedAccountType)
    }
}
