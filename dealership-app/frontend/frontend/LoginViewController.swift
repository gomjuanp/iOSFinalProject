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
    }

    @IBAction func loginButtonTapped(_ sender: UIButton) {
        let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        if email.isEmpty || password.isEmpty {
            showAlert(title: "Missing Info", message: "Please enter email and password.")
            return
        }

        if let user = CoreDataManager.shared.loginUser(email: email, password: password) {
            if user.accountType == "Seller" {
                performSegue(withIdentifier: "loginToSellerSide", sender: nil)
            } else {
                performSegue(withIdentifier: "loginToBuyerSide", sender: nil)
            }
        } else {
            showAlert(title: "Login Failed", message: "Invalid email or password.")
        }
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
