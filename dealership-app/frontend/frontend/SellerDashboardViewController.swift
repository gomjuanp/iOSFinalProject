import UIKit

final class SellerDashboardViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let greetingLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let totalValueLabel = UILabel()
    private let activeValueLabel = UILabel()
    private let soldValueLabel = UILabel()
    private let recentTitleLabel = UILabel()
    private let recentDescriptionLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        hideStoryboardContent()
        buildUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshDashboard()
    }

    private func hideStoryboardContent() {
        view.subviews.forEach { $0.isHidden = true }
        view.backgroundColor = AppTheme.background
    }

    private func buildUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 18

        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -20),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32)
        ])

        let heroCard = UIView()
        heroCard.applyCardStyle(cornerRadius: 28)
        heroCard.backgroundColor = AppTheme.accentDark
        heroCard.translatesAutoresizingMaskIntoConstraints = false
        heroCard.heightAnchor.constraint(equalToConstant: 180).isActive = true

        greetingLabel.font = .systemFont(ofSize: 28, weight: .bold)
        greetingLabel.textColor = .white
        subtitleLabel.font = .systemFont(ofSize: 15, weight: .medium)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.85)
        subtitleLabel.numberOfLines = 0

        let heroStack = UIStackView(arrangedSubviews: [greetingLabel, subtitleLabel])
        heroStack.axis = .vertical
        heroStack.spacing = 10
        heroStack.translatesAutoresizingMaskIntoConstraints = false
        heroCard.addSubview(heroStack)
        NSLayoutConstraint.activate([
            heroStack.leadingAnchor.constraint(equalTo: heroCard.leadingAnchor, constant: 20),
            heroStack.trailingAnchor.constraint(equalTo: heroCard.trailingAnchor, constant: -20),
            heroStack.centerYAnchor.constraint(equalTo: heroCard.centerYAnchor)
        ])

        let statsStack = UIStackView(arrangedSubviews: [
            makeStatCard(title: "Total Listings", valueLabel: totalValueLabel),
            makeStatCard(title: "Active", valueLabel: activeValueLabel),
            makeStatCard(title: "Sold", valueLabel: soldValueLabel)
        ])
        statsStack.axis = .horizontal
        statsStack.spacing = 12
        statsStack.distribution = .fillEqually

        let quickActionsCard = UIView()
        quickActionsCard.applyCardStyle()
        let actionsTitle = UILabel()
        actionsTitle.text = "Quick Actions"
        actionsTitle.font = .systemFont(ofSize: 20, weight: .bold)

        let listingsButton = UIButton(type: .system)
        listingsButton.applyPrimaryStyle(title: "Manage My Listings")
        listingsButton.addTarget(self, action: #selector(openListings), for: .touchUpInside)

        let addButton = UIButton(type: .system)
        addButton.applySecondaryStyle(title: "Add New Vehicle")
        addButton.addTarget(self, action: #selector(openAddCar), for: .touchUpInside)

        let logoutButton = UIButton(type: .system)
        logoutButton.applySecondaryStyle(title: "Log Out")
        logoutButton.addTarget(self, action: #selector(logOutTapped), for: .touchUpInside)

        let actionButtonsStack = UIStackView(arrangedSubviews: [listingsButton, addButton, logoutButton])
        actionButtonsStack.axis = .vertical
        actionButtonsStack.spacing = 12
        actionButtonsStack.translatesAutoresizingMaskIntoConstraints = false
        quickActionsCard.addSubview(actionsTitle)
        quickActionsCard.addSubview(actionButtonsStack)
        actionsTitle.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            actionsTitle.topAnchor.constraint(equalTo: quickActionsCard.topAnchor, constant: 18),
            actionsTitle.leadingAnchor.constraint(equalTo: quickActionsCard.leadingAnchor, constant: 18),

            actionButtonsStack.topAnchor.constraint(equalTo: actionsTitle.bottomAnchor, constant: 16),
            actionButtonsStack.leadingAnchor.constraint(equalTo: quickActionsCard.leadingAnchor, constant: 18),
            actionButtonsStack.trailingAnchor.constraint(equalTo: quickActionsCard.trailingAnchor, constant: -18),
            actionButtonsStack.bottomAnchor.constraint(equalTo: quickActionsCard.bottomAnchor, constant: -18)
        ])

        let recentCard = UIView()
        recentCard.applyCardStyle()
        let recentHeader = UILabel()
        recentHeader.text = "Latest Listing"
        recentHeader.font = .systemFont(ofSize: 20, weight: .bold)
        recentTitleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        recentDescriptionLabel.font = .systemFont(ofSize: 14)
        recentDescriptionLabel.textColor = AppTheme.subtitle
        recentDescriptionLabel.numberOfLines = 0

        let recentStack = UIStackView(arrangedSubviews: [recentHeader, recentTitleLabel, recentDescriptionLabel])
        recentStack.axis = .vertical
        recentStack.spacing = 10
        recentStack.translatesAutoresizingMaskIntoConstraints = false
        recentCard.addSubview(recentStack)
        NSLayoutConstraint.activate([
            recentStack.topAnchor.constraint(equalTo: recentCard.topAnchor, constant: 18),
            recentStack.leadingAnchor.constraint(equalTo: recentCard.leadingAnchor, constant: 18),
            recentStack.trailingAnchor.constraint(equalTo: recentCard.trailingAnchor, constant: -18),
            recentStack.bottomAnchor.constraint(equalTo: recentCard.bottomAnchor, constant: -18)
        ])

        [heroCard, statsStack, quickActionsCard, recentCard].forEach { contentStack.addArrangedSubview($0) }
    }

    private func makeStatCard(title: String, valueLabel: UILabel) -> UIView {
        let card = UIView()
        card.applyCardStyle()
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 13, weight: .medium)
        titleLabel.textColor = AppTheme.subtitle

        valueLabel.font = .systemFont(ofSize: 28, weight: .bold)
        valueLabel.textColor = AppTheme.accentDark

        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -18),
            card.heightAnchor.constraint(equalToConstant: 110)
        ])
        return card
    }

    private func refreshDashboard() {
        let name = SessionManager.shared.currentUserName ?? "Seller"
        greetingLabel.text = "Welcome back, \(name)"
        subtitleLabel.text = "Manage your dealership inventory, add new vehicles, and keep track of sold cars from one clean dashboard."

        let stats = CoreDataManager.shared.sellerDashboardStats()
        totalValueLabel.text = "\(stats.total)"
        activeValueLabel.text = "\(stats.active)"
        soldValueLabel.text = "\(stats.sold)"

        if let recentCar = CoreDataManager.shared.fetchCars(sellerOnly: true).first ?? CoreDataManager.shared.fetchCars().first {
            recentTitleLabel.text = [recentCar.brand ?? "", recentCar.title ?? ""].joined(separator: " ").trimmingCharacters(in: .whitespaces)
            recentDescriptionLabel.text = [recentCar.year ?? "", recentCar.price ?? "", recentCar.isSold ? "Sold" : "Live on marketplace"]
                .filter { !$0.isEmpty }
                .joined(separator: " • ")
        } else {
            recentTitleLabel.text = "No listings yet"
            recentDescriptionLabel.text = "Tap Add New Vehicle to publish your first car on the marketplace."
        }
    }

    @objc private func openListings() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let listingsVC = storyboard.instantiateViewController(withIdentifier: "MyListingsViewController") as? MyListingsViewController else { return }
        let nav = UINavigationController(rootViewController: listingsVC)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }

    @objc private func openAddCar() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let addVC = storyboard.instantiateViewController(withIdentifier: "AddCarViewController") as? AddCarViewController else { return }
        let nav = UINavigationController(rootViewController: addVC)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }

    @objc private func logOutTapped() {
        resetToWelcomeScreen()
    }
}
