import UIKit

struct AppTheme {
    static let background = UIColor(red: 0.96, green: 0.97, blue: 0.99, alpha: 1.0)
    static let card = UIColor.white
    static let accent = UIColor(red: 0.10, green: 0.40, blue: 0.96, alpha: 1.0)
    static let accentDark = UIColor(red: 0.05, green: 0.24, blue: 0.64, alpha: 1.0)
    static let success = UIColor.systemGreen
    static let warning = UIColor.systemOrange
    static let subtitle = UIColor.secondaryLabel
}

extension UIView {
    func applyCardStyle(cornerRadius: CGFloat = 22) {
        backgroundColor = AppTheme.card
        layer.cornerRadius = cornerRadius
        layer.shadowColor = UIColor.black.withAlphaComponent(0.12).cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 18
        layer.shadowOffset = CGSize(width: 0, height: 10)
    }
}

extension UIButton {
    func applyPrimaryStyle(title: String? = nil) {
        if let title {
            setTitle(title, for: .normal)
        }
        backgroundColor = AppTheme.accent
        setTitleColor(.white, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        layer.cornerRadius = 16
        layer.shadowColor = AppTheme.accent.cgColor
        layer.shadowOpacity = 0.25
        layer.shadowRadius = 12
        layer.shadowOffset = CGSize(width: 0, height: 6)
        contentEdgeInsets = UIEdgeInsets(top: 14, left: 18, bottom: 14, right: 18)
    }

    func applySecondaryStyle(title: String? = nil) {
        if let title {
            setTitle(title, for: .normal)
        }
        backgroundColor = UIColor.systemGray6
        setTitleColor(.label, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        layer.cornerRadius = 16
        contentEdgeInsets = UIEdgeInsets(top: 14, left: 18, bottom: 14, right: 18)
    }
}

extension UITextField {
    func applyMarketplaceStyle(placeholderText: String? = nil) {
        if let placeholderText {
            placeholder = placeholderText
        }
        backgroundColor = .white
        layer.cornerRadius = 16
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray5.cgColor
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 10))
        leftViewMode = .always
        font = .systemFont(ofSize: 16, weight: .medium)
        autocorrectionType = .no
        autocapitalizationType = .words
    }
}

extension UIViewController {
    func resetToWelcomeScreen() {
        SessionManager.shared.clearSession()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let initialController = storyboard.instantiateInitialViewController() else { return }

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let sceneDelegate = windowScene.delegate as? SceneDelegate,
           let window = sceneDelegate.window {
            window.rootViewController = initialController
            window.makeKeyAndVisible()
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
        } else {
            initialController.modalPresentationStyle = .fullScreen
            present(initialController, animated: true)
        }
    }

    func showBasicAlert(title: String, message: String, handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: handler))
        present(alert, animated: true)
    }


    func presentMarketplaceArea(for accountType: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let identifier = accountType == "Seller" ? "SellerTabBarController" : "BuyerTabBarController"
        guard let tabBarController = storyboard.instantiateViewController(withIdentifier: identifier) as? UITabBarController else { return }
        if accountType == "Seller" {
            tabBarController.selectedIndex = 1
        }
        tabBarController.modalPresentationStyle = .fullScreen
        present(tabBarController, animated: true)
    }
}

extension String {
    var numericValueFromCurrencyText: Double {
        let cleaned = replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression)
        return Double(cleaned) ?? 0
    }
}
