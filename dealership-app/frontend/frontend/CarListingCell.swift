import UIKit
import CoreData

final class CarListingCell: UITableViewCell {
    static let reuseIdentifier = "CarListingCell"

    private let cardView = UIView()
    private let carImageView = UIImageView()
    private let titleLabel = UILabel()
    private let priceLabel = UILabel()
    private let metaLabel = UILabel()
    private let badgeLabel = UILabel()
    private let descriptionLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        setupLayout()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        carImageView.image = nil
    }

    private func setupLayout() {
        cardView.applyCardStyle()
        cardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardView)

        carImageView.translatesAutoresizingMaskIntoConstraints = false
        carImageView.layer.cornerRadius = 18
        carImageView.clipsToBounds = true
        carImageView.backgroundColor = UIColor.systemGray6

        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        priceLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        priceLabel.textColor = AppTheme.accentDark
        metaLabel.font = .systemFont(ofSize: 13, weight: .medium)
        metaLabel.textColor = AppTheme.subtitle
        descriptionLabel.font = .systemFont(ofSize: 13)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 2

        badgeLabel.font = .systemFont(ofSize: 12, weight: .bold)
        badgeLabel.textAlignment = .center
        badgeLabel.layer.cornerRadius = 11
        badgeLabel.clipsToBounds = true

        let textStack = UIStackView(arrangedSubviews: [titleLabel, priceLabel, metaLabel, descriptionLabel])
        textStack.axis = .vertical
        textStack.spacing = 6
        textStack.translatesAutoresizingMaskIntoConstraints = false

        badgeLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(carImageView)
        cardView.addSubview(textStack)
        cardView.addSubview(badgeLabel)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),

            carImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            carImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 14),
            carImageView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -14),
            carImageView.widthAnchor.constraint(equalToConstant: 120),

            textStack.leadingAnchor.constraint(equalTo: carImageView.trailingAnchor, constant: 14),
            textStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            textStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),
            textStack.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -16),

            badgeLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 14),
            badgeLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),
            badgeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 70),
            badgeLabel.heightAnchor.constraint(equalToConstant: 22),
        ])
    }

    func configure(with car: Car) {
        let title = [car.brand ?? "", car.title ?? ""].joined(separator: " ").trimmingCharacters(in: .whitespaces)
        titleLabel.text = title.isEmpty ? "Car Listing" : title
        priceLabel.text = car.price?.isEmpty == false ? car.price : "$0"
        metaLabel.text = [car.year ?? "", car.sellerEmail ?? "Marketplace Seller"]
            .filter { !$0.isEmpty }
            .joined(separator: " • ")
        descriptionLabel.text = car.carDescription?.isEmpty == false ? car.carDescription : "No description added yet."

        let isSold = car.isSold
        badgeLabel.text = isSold ? "SOLD" : "LIVE"
        badgeLabel.backgroundColor = isSold ? UIColor.systemGray5 : UIColor.systemGreen.withAlphaComponent(0.18)
        badgeLabel.textColor = isSold ? .secondaryLabel : UIColor.systemGreen

        carImageView.setCarImage(from: car.imageName)
    }
}
