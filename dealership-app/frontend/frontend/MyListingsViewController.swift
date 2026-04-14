//
//  MyListingsViewController.swift
//  frontend
//
//  Created by Ishanpreet Singh on 2026-04-10.
//

import UIKit

class MyListingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!

    var cars: [Car] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 100
        tableView.backgroundColor = .clear

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

    @objc func refreshCars() {
        loadCars()
    }

    func loadCars() {
        cars = CoreDataManager.shared.fetchCars()
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cars.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let car = cars[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "CarCell") ??
            UITableViewCell(style: .subtitle, reuseIdentifier: "CarCell")

        var content = cell.defaultContentConfiguration()
        content.text = car.title ?? "No Title"
        content.secondaryText = "\(car.brand ?? "") • \(car.year ?? "") • \(car.price ?? "")"

        if let imageName = car.imageName,
           !imageName.isEmpty,
           let image = UIImage(named: imageName) {
            content.image = image
        } else {
            content.image = UIImage(systemName: "car.fill")
        }

        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator

        return cell
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
