//
//  MyListingsViewController.swift
//  frontend
//
//  Created by Ishanpreet Singh on 2026-04-10.
//

import UIKit

class MyListingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!

    private var cars: [Car] = []
    private let emptyLabel = UILabel()
    private let segmentControl = UISegmentedControl(items: ["All", "Active", "Sold"])

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshCars),
            name: NSNotification.Name("carSaved"),
            object: nil
        )

        loadCars()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadCars()
    }

    private func configureUI() {
        view.backgroundColor = AppTheme.background
        title = "My Listings"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeTapped)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addCarTapped)
        )

        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 160
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.register(CarListingCell.self, forCellReuseIdentifier: CarListingCell.reuseIdentifier)

        segmentControl.selectedSegmentIndex = 0
        segmentControl.addTarget(self, action: #selector(filterChanged), for: .valueChanged)
        navigationItem.titleView = segmentControl

        emptyLabel.text = "You have not added any cars yet. Tap + to create your first listing."
        emptyLabel.font = .systemFont(ofSize: 16, weight: .medium)
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.numberOfLines = 0
        emptyLabel.textAlignment = .center
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    @objc private func addCarTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let addVC = storyboard.instantiateViewController(withIdentifier: "AddCarViewController") as? AddCarViewController else { return }
        navigationController?.pushViewController(addVC, animated: true)
    }

    @objc func refreshCars() {
        loadCars()
    }

    @objc private func filterChanged() {
        loadCars()
    }

    private func loadCars() {
        let baseCars = CoreDataManager.shared.fetchCars(sellerOnly: true)
        let dataSet = baseCars.isEmpty ? CoreDataManager.shared.fetchCars() : baseCars

        switch segmentControl.selectedSegmentIndex {
        case 1:
            cars = dataSet.filter { !$0.isSold }
        case 2:
            cars = dataSet.filter { $0.isSold }
        default:
            cars = dataSet
        }

        emptyLabel.isHidden = !cars.isEmpty
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cars.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let car = cars[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: CarListingCell.reuseIdentifier, for: indexPath) as! CarListingCell
        cell.configure(with: car)
        return cell
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let car = cars[indexPath.row]

        let soldAction = UIContextualAction(style: .normal, title: car.isSold ? "Mark Live" : "Mark Sold") { _, _, completion in
            CoreDataManager.shared.toggleSoldStatus(for: car)
            self.loadCars()
            completion(true)
        }
        soldAction.backgroundColor = car.isSold ? AppTheme.warning : AppTheme.success

        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, completion in
            CoreDataManager.shared.deleteCar(car)
            self.loadCars()
            completion(true)
        }

        return UISwipeActionsConfiguration(actions: [deleteAction, soldAction])
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
