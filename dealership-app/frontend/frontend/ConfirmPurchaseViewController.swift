import UIKit
import CoreData

final class ConfirmPurchaseViewController: UIViewController {
    var car: Car?

    private let stack = UIStackView()
    private let summaryTitleLabel = UILabel()
    private let summaryBodyLabel = UILabel()
    private let confirmButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        hideStoryboardContent()
        buildUI()
        renderSummary()
    }

    private func hideStoryboardContent() {
        view.subviews.forEach { $0.isHidden = true }
        view.backgroundColor = AppTheme.background
    }

    private func buildUI() {
        title = "Confirm Purchase"
        navigationItem.largeTitleDisplayMode = .never

        let card = UIView()
        card.applyCardStyle()
        card.translatesAutoresizingMaskIntoConstraints = false

        summaryTitleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        summaryBodyLabel.font = .systemFont(ofSize: 16)
        summaryBodyLabel.textColor = AppTheme.subtitle
        summaryBodyLabel.numberOfLines = 0

        stack.axis = .vertical
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.addArrangedSubview(summaryTitleLabel)
        stack.addArrangedSubview(summaryBodyLabel)
        card.addSubview(stack)

        confirmButton.applyPrimaryStyle(title: "Confirm and Buy")
        confirmButton.addTarget(self, action: #selector(confirmPurchaseTapped), for: .touchUpInside)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(card)
        view.addSubview(confirmButton)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            card.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20),

            confirmButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            confirmButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            confirmButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24)
        ])
    }

    private func renderSummary() {
        guard let car else { return }
        let title = [car.brand ?? "", car.title ?? ""].joined(separator: " ").trimmingCharacters(in: .whitespaces)
        summaryTitleLabel.text = title.isEmpty ? "Marketplace Purchase" : title
        let seller = car.sellerEmail ?? "Marketplace Seller"
        summaryBodyLabel.text = "Price: \(car.price ?? "$0")\nYear: \(car.year ?? "N/A")\nSeller: \(seller)\n\nAfter confirmation, this car will be marked as sold and added to your purchase history."

        if car.isSold {
            confirmButton.isEnabled = false
            confirmButton.backgroundColor = UIColor.systemGray4
            confirmButton.setTitle("Already Sold", for: .normal)
        }
    }

    @objc private func confirmPurchaseTapped() {
        guard SessionManager.shared.isBuyer else {
            showBasicAlert(title: "Buyer Account Required", message: "Please log in with a buyer account to complete a purchase.")
            return
        }

        guard let car else { return }

        if CoreDataManager.shared.purchase(car: car) {
            let alert = UIAlertController(
                title: "Purchase Complete",
                message: "Your vehicle has been added to your purchases.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "View Purchases", style: .default, handler: { _ in
                self.navigationController?.popToRootViewController(animated: false)
                self.tabBarController?.selectedIndex = 1
            }))
            present(alert, animated: true)
        } else {
            showBasicAlert(title: "Purchase Failed", message: "This car may already be sold. Please refresh and try again.")
        }
    }
}
