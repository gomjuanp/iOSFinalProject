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
        styleButtons(in: view)
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

    private func styleButtons(in root: UIView) {
        for subview in root.subviews {
            if let button = subview as? UIButton {
                if button == accountTypeButton {
                    // keep as configured
                } else {
                    // Determine identity BEFORE clearing configuration
                    let rawTitle = (button.title(for: .normal) ?? button.configuration?.title ?? "")
                    let normalized = rawTitle.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                    let normalizedNoSpaces = normalized.replacingOccurrences(of: " ", with: "")

                    // Detect the Create Account button by its target-action
                    let actions = button.actions(forTarget: self, forControlEvent: .touchUpInside) ?? []
                    let isCreateByAction = actions.contains("createAccountButtonTapped:")
                    let isLoginByTitle = normalizedNoSpaces.contains("login")
                    let isCreateByTitle = normalized.contains("create") && normalized.contains("account")

                    // Clear any storyboard/UI configuration and reset visuals
                    button.configuration = nil
                    let allStates: [UIControl.State] = [.normal, .highlighted, .selected, .disabled, .focused, .application, .reserved]
                    for state in allStates {
                        button.setBackgroundImage(nil, for: state)
                    }
                    button.backgroundColor = .clear
                    button.layer.cornerRadius = 0
                    button.layer.shadowOpacity = 0
                    button.layer.shadowRadius = 0
                    button.layer.shadowOffset = .zero
                    button.contentEdgeInsets = .zero
                    button.titleEdgeInsets = .zero

                    // Restore title if it was only set via configuration
                    if (button.title(for: .normal) ?? "").isEmpty, !rawTitle.isEmpty {
                        button.setTitle(rawTitle, for: .normal)
                    }

                    if isLoginByTitle {
                        // Link-style for Login: blue text, no background
                        button.setTitleColor(AppTheme.accent, for: .normal)
                        button.setTitleColor(AppTheme.accent.withAlphaComponent(0.5), for: .highlighted)
                        button.setTitleColor(AppTheme.accent.withAlphaComponent(0.5), for: .disabled)
                        button.tintColor = AppTheme.accent
                    } else if isCreateByAction || isCreateByTitle {
                        // Primary CTA should keep the blue pill style with white text
                        let displayTitle = rawTitle.isEmpty ? "Create Account" : rawTitle
                        button.setTitle(displayTitle, for: .normal)
                        button.applyPrimaryStyle()
                        button.setTitleColor(.white, for: .normal)
                        button.setTitleColor(UIColor.white.withAlphaComponent(0.7), for: .highlighted)
                        button.tintColor = .white
                    } else {
                        // Leave any other buttons plain with default label color
                        button.setTitleColor(.label, for: .normal)
                    }
                }
            }
            // Recurse into children
            styleButtons(in: subview)
        }
    }
}

