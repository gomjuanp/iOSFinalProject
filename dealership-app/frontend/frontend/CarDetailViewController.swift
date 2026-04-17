import UIKit
import CoreData

final class CarDetailViewController: UIViewController {
    var car: Car?

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let carImageView = UIImageView()
    private let titleLabel = UILabel()
    private let priceLabel = UILabel()
    private let specsLabel = UILabel()
    private let sellerLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let buyButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        hideStoryboardContent()
        buildUI()
        renderCar()
    }

    private func hideStoryboardContent() {
        view.subviews.forEach { $0.isHidden = true }
        view.backgroundColor = AppTheme.background
    }

    private func buildUI() {
        title = "Vehicle Details"
        navigationItem.largeTitleDisplayMode = .never

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 16

        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -20),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32)
        ])

        carImageView.translatesAutoresizingMaskIntoConstraints = false
        carImageView.heightAnchor.constraint(equalToConstant: 260).isActive = true
        carImageView.layer.cornerRadius = 26
        carImageView.clipsToBounds = true
        carImageView.backgroundColor = .systemGray6

        let infoCard = UIView()
        infoCard.applyCardStyle()
        let infoStack = UIStackView(arrangedSubviews: [titleLabel, priceLabel, specsLabel, sellerLabel])
        infoStack.axis = .vertical
        infoStack.spacing = 10
        infoStack.translatesAutoresizingMaskIntoConstraints = false
        infoCard.addSubview(infoStack)
        NSLayoutConstraint.activate([
            infoStack.topAnchor.constraint(equalTo: infoCard.topAnchor, constant: 18),
            infoStack.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 18),
            infoStack.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor, constant: -18),
            infoStack.bottomAnchor.constraint(equalTo: infoCard.bottomAnchor, constant: -18)
        ])

        titleLabel.font = .systemFont(ofSize: 26, weight: .bold)
        titleLabel.numberOfLines = 0
        priceLabel.font = .systemFont(ofSize: 24, weight: .heavy)
        priceLabel.textColor = AppTheme.accentDark
        specsLabel.font = .systemFont(ofSize: 15, weight: .medium)
        specsLabel.textColor = AppTheme.subtitle
        sellerLabel.font = .systemFont(ofSize: 14)
        sellerLabel.textColor = .secondaryLabel

        let descriptionCard = UIView()
        descriptionCard.applyCardStyle()
        let descriptionHeader = UILabel()
        descriptionHeader.text = "Description"
        descriptionHeader.font = .systemFont(ofSize: 20, weight: .bold)
        descriptionLabel.font = .systemFont(ofSize: 16)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textColor = .label

        let descriptionStack = UIStackView(arrangedSubviews: [descriptionHeader, descriptionLabel])
        descriptionStack.axis = .vertical
        descriptionStack.spacing = 12
        descriptionStack.translatesAutoresizingMaskIntoConstraints = false
        descriptionCard.addSubview(descriptionStack)
        NSLayoutConstraint.activate([
            descriptionStack.topAnchor.constraint(equalTo: descriptionCard.topAnchor, constant: 18),
            descriptionStack.leadingAnchor.constraint(equalTo: descriptionCard.leadingAnchor, constant: 18),
            descriptionStack.trailingAnchor.constraint(equalTo: descriptionCard.trailingAnchor, constant: -18),
            descriptionStack.bottomAnchor.constraint(equalTo: descriptionCard.bottomAnchor, constant: -18)
        ])

        buyButton.applyPrimaryStyle(title: "Buy This Vehicle")
        buyButton.addTarget(self, action: #selector(buyNowTapped), for: .touchUpInside)

        [carImageView, infoCard, descriptionCard, buyButton].forEach { contentStack.addArrangedSubview($0) }
    }

    private func renderCar() {
        guard let car else {
            showBasicAlert(title: "No Car Found", message: "This vehicle could not be loaded.") { _ in
                self.navigationController?.popViewController(animated: true)
            }
            return
        }

        let title = [car.brand ?? "", car.title ?? ""].joined(separator: " ").trimmingCharacters(in: .whitespaces)
        titleLabel.text = title.isEmpty ? "Vehicle Details" : title
        priceLabel.text = car.price?.isEmpty == false ? car.price : "$0"
        specsLabel.text = [car.year ?? "", car.isSold ? "Sold" : "Available now"].filter { !$0.isEmpty }.joined(separator: " • ")
        let seller = car.sellerEmail ?? "Marketplace Seller"
        sellerLabel.text = "Seller: \(seller)"
        descriptionLabel.text = car.carDescription?.isEmpty == false ? car.carDescription : "No description added yet."
        carImageView.setCarImage(from: car.imageName)

        if car.isSold {
            buyButton.isEnabled = false
            buyButton.backgroundColor = UIColor.systemGray4
            buyButton.setTitle("Already Sold", for: .normal)
        }
    }

    @objc private func buyNowTapped() {
        guard let car else { return }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let confirmVC = storyboard.instantiateViewController(withIdentifier: "ConfirmPurchaseViewController") as? ConfirmPurchaseViewController else { return }
        confirmVC.car = car
        navigationController?.pushViewController(confirmVC, animated: true)
    }
}
