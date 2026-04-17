import UIKit

final class BuyerProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let headerCard = UIView()
    private let nameLabel = UILabel()
    private let emailLabel = UILabel()
    private let statsLabel = UILabel()
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let logoutButton = UIButton(type: .system)
    private let emptyLabel = UILabel()
    private var purchasedCars: [Car] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        hideStoryboardContent()
        buildUI()
        loadPurchases()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadPurchases()
    }

    private func hideStoryboardContent() {
        view.subviews.forEach { $0.isHidden = true }
        view.backgroundColor = AppTheme.background
    }

    private func buildUI() {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "My Garage"
        titleLabel.font = .systemFont(ofSize: 30, weight: .bold)

        headerCard.translatesAutoresizingMaskIntoConstraints = false
        headerCard.applyCardStyle(cornerRadius: 26)

        nameLabel.font = .systemFont(ofSize: 24, weight: .bold)
        emailLabel.font = .systemFont(ofSize: 15, weight: .medium)
        emailLabel.textColor = AppTheme.subtitle
        statsLabel.font = .systemFont(ofSize: 14)
        statsLabel.textColor = AppTheme.accentDark
        statsLabel.numberOfLines = 0

        let headerStack = UIStackView(arrangedSubviews: [nameLabel, emailLabel, statsLabel])
        headerStack.axis = .vertical
        headerStack.spacing = 10
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        headerCard.addSubview(headerStack)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.register(CarListingCell.self, forCellReuseIdentifier: CarListingCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 160

        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.applySecondaryStyle(title: "Log Out")
        logoutButton.addTarget(self, action: #selector(logOutTapped), for: .touchUpInside)

        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.text = "You have not purchased any vehicles yet."
        emptyLabel.numberOfLines = 0
        emptyLabel.textAlignment = .center
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.isHidden = true

        view.addSubview(titleLabel)
        view.addSubview(headerCard)
        view.addSubview(tableView)
        view.addSubview(logoutButton)
        view.addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            headerCard.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            headerCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headerCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            headerStack.topAnchor.constraint(equalTo: headerCard.topAnchor, constant: 18),
            headerStack.leadingAnchor.constraint(equalTo: headerCard.leadingAnchor, constant: 18),
            headerStack.trailingAnchor.constraint(equalTo: headerCard.trailingAnchor, constant: -18),
            headerStack.bottomAnchor.constraint(equalTo: headerCard.bottomAnchor, constant: -18),

            tableView.topAnchor.constraint(equalTo: headerCard.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: logoutButton.topAnchor, constant: -12),

            logoutButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            logoutButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),

            emptyLabel.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: tableView.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }

    private func loadPurchases() {
        let name = SessionManager.shared.currentUserName ?? "Buyer"
        let email = SessionManager.shared.currentUserEmail ?? "No email"
        purchasedCars = CoreDataManager.shared.fetchPurchasedCarsForCurrentBuyer()
        let totalSpent = purchasedCars.reduce(0) { $0 + ($1.price ?? "").numericValueFromCurrencyText }

        nameLabel.text = name
        emailLabel.text = email
        statsLabel.text = "Purchased vehicles: \(purchasedCars.count)\nTotal spent: $\(Int(totalSpent))"
        emptyLabel.isHidden = !purchasedCars.isEmpty
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        purchasedCars.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CarListingCell.reuseIdentifier, for: indexPath) as! CarListingCell
        cell.configure(with: purchasedCars[indexPath.row])
        return cell
    }

    @objc private func logOutTapped() {
        resetToWelcomeScreen()
    }
}
