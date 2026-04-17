//
//  LoginViewController.swift
//  frontend
//
//  Created by Ishanpreet Singh on 2026-04-16.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    private func configureUI() {
        view.backgroundColor = AppTheme.background
        emailTextField.applyMarketplaceStyle(placeholderText: "name@email.com")
        passwordTextField.applyMarketplaceStyle(placeholderText: "Enter password")
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        passwordTextField.isSecureTextEntry = true
        passwordTextField.autocapitalizationType = .none

        view.subviews.compactMap { $0 as? UIButton }.forEach { button in
            button.applyPrimaryStyle()
        }
    }

    @IBAction func loginButtonTapped(_ sender: UIButton) {
        let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        if email.isEmpty || password.isEmpty {
            showBasicAlert(title: "Missing Info", message: "Please enter email and password.")
            return
        }

        if let user = CoreDataManager.shared.loginUser(email: email, password: password) {
            SessionManager.shared.saveSession(
                name: user.name ?? "User",
                email: user.email ?? email,
                accountType: user.accountType ?? "Buyer"
            )

            presentMarketplaceArea(for: user.accountType ?? "Buyer")
        } else {
            showBasicAlert(title: "Login Failed", message: "Invalid email or password.")
        }
    }
}
