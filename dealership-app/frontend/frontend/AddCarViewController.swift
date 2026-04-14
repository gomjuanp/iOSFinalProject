//
//  AddCarViewController.swift
//  frontend
//
//  Created by Ishanpreet Singh on 2026-04-10.
//

import UIKit

class AddCarViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var brandTextField: UITextField!
    @IBOutlet weak var yearTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var imageNameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func saveButtonTapped(_ sender: UIButton) {
        let title = titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let brand = brandTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let year = yearTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let price = priceTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let imageName = imageNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let description = descriptionTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        if title.isEmpty || brand.isEmpty || year.isEmpty || price.isEmpty || description.isEmpty {
            showAlert(title: "Missing Info", message: "Please fill in all required fields.")
            return
        }

        let finalImageName = imageName.isEmpty ? "Mercedes" : imageName

        CoreDataManager.shared.saveCar(
            title: title,
            brand: brand,
            year: year,
            price: price,
            carDescription: description,
            imageName: finalImageName
        )

        NotificationCenter.default.post(name: NSNotification.Name("carSaved"), object: nil)

        print("Saving car: \(title), \(brand), \(year), \(price), image: \(finalImageName)")

        showSuccessAndGoBack()
    }

    func showSuccessAndGoBack() {
        let alert = UIAlertController(
            title: "Success",
            message: "Car saved successfully.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.navigationController?.popViewController(animated: true)
        }))

        present(alert, animated: true)
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
