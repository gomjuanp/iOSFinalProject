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

        styleButtons(in: view)
    }

    private func styleButtons(in root: UIView) {
        for subview in root.subviews {
            if let button = subview as? UIButton {
                // Capture title before clearing configuration (some storyboard buttons only have configuration titles)
                let rawTitle = (button.title(for: .normal) ?? button.configuration?.title ?? "")
                let normalized = rawTitle.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                let normalizedNoSpaces = normalized.replacingOccurrences(of: " ", with: "")

                // Detect the Login CTA by its target-action or title
                let actions = button.actions(forTarget: self, forControlEvent: .touchUpInside) ?? []
                let isLoginByAction = actions.contains("loginButtonTapped:")
                let isLoginByTitle = normalizedNoSpaces.contains("login")

                // Clear any storyboard/UI configuration and reset visuals
                button.configuration = nil
                let allStates: [UIControl.State] = [.normal, .highlighted, .selected, .disabled, .focused, .application, .reserved]
                for state in allStates { button.setBackgroundImage(nil, for: state) }
                button.layer.shadowOpacity = 0
                button.layer.shadowRadius = 0
                button.layer.shadowOffset = .zero

                if isLoginByAction || isLoginByTitle {
                    // Keep Login as primary (blue pill)
                    let titleToUse = rawTitle.isEmpty ? "Login" : rawTitle
                    button.applyPrimaryStyle(title: titleToUse)
                } else {
                    // Make other buttons (e.g., Sign Up) link-style
                    let titleToUse = rawTitle.isEmpty ? (button.title(for: .normal) ?? "") : rawTitle
                    button.setTitle(titleToUse, for: .normal)
                    button.backgroundColor = .clear
                    button.setTitleColor(AppTheme.accent, for: .normal)
                    button.setTitleColor(AppTheme.accent.withAlphaComponent(0.5), for: .highlighted)
                    button.tintColor = AppTheme.accent
                    button.layer.cornerRadius = 0
                    button.contentEdgeInsets = .zero
                    button.titleEdgeInsets = .zero
                }
            }
            // Recurse into children
            styleButtons(in: subview)
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
