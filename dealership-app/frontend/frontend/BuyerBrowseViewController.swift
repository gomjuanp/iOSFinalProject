import UIKit

final class BuyerBrowseViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating {
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let emptyLabel = UILabel()
    private let searchController = UISearchController(searchResultsController: nil)
    private var cars: [Car] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        hideStoryboardContent()
        configureNavigation()
        buildUI()
        loadCars()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadCars()
    }

    private func hideStoryboardContent() {
        view.subviews.forEach { $0.isHidden = true }
        view.backgroundColor = AppTheme.background
    }

    private func configureNavigation() {
        title = "Marketplace"
        navigationController?.navigationBar.prefersLargeTitles = true
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search by brand, model, year or price"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    private func buildUI() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.register(CarListingCell.self, forCellReuseIdentifier: CarListingCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 160

        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.text = "No vehicles found yet. Ask a seller to add a listing."
        emptyLabel.font = .systemFont(ofSize: 16, weight: .medium)
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.textAlignment = .center
        emptyLabel.numberOfLines = 0
        emptyLabel.isHidden = true

        view.addSubview(tableView)
        view.addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }

    private func loadCars(searchText: String? = nil) {
        cars = CoreDataManager.shared.fetchCars(searchText: searchText, availableOnly: true)
        emptyLabel.isHidden = !cars.isEmpty
        tableView.reloadData()
    }

    func updateSearchResults(for searchController: UISearchController) {
        loadCars(searchText: searchController.searchBar.text)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cars.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let car = cars[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: CarListingCell.reuseIdentifier, for: indexPath) as! CarListingCell
        cell.configure(with: car)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let detailVC = storyboard.instantiateViewController(withIdentifier: "CarDetailViewController") as? CarDetailViewController else { return }
        detailVC.car = cars[indexPath.row]
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
