//
//  AddCarViewController.swift
//  frontend
//
//  Created by Ishanpreet Singh on 2026-04-10.
//

import UIKit
import PhotosUI

class AddCarViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var brandTextField: UITextField!
    @IBOutlet weak var yearTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var imageNameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!

    private let saveButton = UIButton(type: .system)
    private let photoContainerView = UIView()
    private let photoImageView = UIImageView()
    private let photoPlaceholderLabel = UILabel()

    private var savedImageURLString: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    private func configureUI() {
        title = "Add Vehicle"
        view.backgroundColor = AppTheme.background

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeTapped)
        )

        setupTextFields()
        setupPhotoPickerArea()
        setupSaveButton()
        setupDismissKeyboard()
    }

    private func setupTextFields() {
        [titleTextField, brandTextField, yearTextField, priceTextField, imageNameTextField, descriptionTextField].forEach {
            $0?.applyMarketplaceStyle()
        }

        titleTextField.applyMarketplaceStyle(placeholderText: "M5 Competition")
        brandTextField.applyMarketplaceStyle(placeholderText: "BMW")
        yearTextField.applyMarketplaceStyle(placeholderText: "2024")
        priceTextField.applyMarketplaceStyle(placeholderText: "$78,500")
        imageNameTextField.applyMarketplaceStyle(placeholderText: "Asset name or image URL")
        descriptionTextField.applyMarketplaceStyle(placeholderText: "Enter car description...")

        yearTextField.keyboardType = .numberPad
        priceTextField.keyboardType = .numbersAndPunctuation
        imageNameTextField.autocapitalizationType = .none
        imageNameTextField.autocorrectionType = .no
    }

    private func setupPhotoPickerArea() {
        photoContainerView.translatesAutoresizingMaskIntoConstraints = false
        photoContainerView.backgroundColor = .white
        photoContainerView.layer.cornerRadius = 20
        photoContainerView.layer.borderWidth = 1
        photoContainerView.layer.borderColor = UIColor.systemGray5.cgColor
        photoContainerView.clipsToBounds = true
        view.addSubview(photoContainerView)

        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        photoImageView.backgroundColor = UIColor.systemGray6
        photoImageView.contentMode = .scaleAspectFill
        photoImageView.clipsToBounds = true
        photoImageView.isUserInteractionEnabled = true
        photoContainerView.addSubview(photoImageView)

        photoPlaceholderLabel.translatesAutoresizingMaskIntoConstraints = false
        photoPlaceholderLabel.text = "Tap to add a car photo"
        photoPlaceholderLabel.textColor = .systemGray
        photoPlaceholderLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        photoPlaceholderLabel.textAlignment = .center
        photoImageView.addSubview(photoPlaceholderLabel)

        let tap = UITapGestureRecognizer(target: self, action: #selector(selectPhotoTapped))
        photoImageView.addGestureRecognizer(tap)

        NSLayoutConstraint.activate([
            photoContainerView.topAnchor.constraint(equalTo: descriptionTextField.bottomAnchor, constant: 16),
            photoContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            photoContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            photoContainerView.heightAnchor.constraint(equalToConstant: 180),

            photoImageView.topAnchor.constraint(equalTo: photoContainerView.topAnchor),
            photoImageView.bottomAnchor.constraint(equalTo: photoContainerView.bottomAnchor),
            photoImageView.leadingAnchor.constraint(equalTo: photoContainerView.leadingAnchor),
            photoImageView.trailingAnchor.constraint(equalTo: photoContainerView.trailingAnchor),

            photoPlaceholderLabel.centerXAnchor.constraint(equalTo: photoImageView.centerXAnchor),
            photoPlaceholderLabel.centerYAnchor.constraint(equalTo: photoImageView.centerYAnchor)
        ])
    }

    private func setupSaveButton() {
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.setTitle("Publish Listing", for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.setTitleColor(UIColor.white.withAlphaComponent(0.8), for: .highlighted)
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        saveButton.backgroundColor = UIColor.systemBlue
        saveButton.layer.cornerRadius = 28
        saveButton.clipsToBounds = true
        saveButton.addTarget(self, action: #selector(saveButtonTapped(_:)), for: .touchUpInside)

        view.addSubview(saveButton)

        NSLayoutConstraint.activate([
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            saveButton.heightAnchor.constraint(equalToConstant: 56),

            photoContainerView.bottomAnchor.constraint(lessThanOrEqualTo: saveButton.topAnchor, constant: -20)
        ])
    }

    private func setupDismissKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func closeTapped() {
        if navigationController?.viewControllers.first == self {
            dismiss(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func selectPhotoTapped() {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    @objc func saveButtonTapped(_ sender: UIButton) {
        let title = titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let brand = brandTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let year = yearTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let price = priceTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let imageName = imageNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let description = descriptionTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        let hasSelectedPhoto = savedImageURLString != nil
        let hasTypedImage = !imageName.isEmpty

        if title.isEmpty || brand.isEmpty || year.isEmpty || price.isEmpty || description.isEmpty || (!hasSelectedPhoto && !hasTypedImage) {
            showBasicAlert(
                title: "Missing Info",
                message: "Please fill in all required fields and add a photo."
            )
            return
        }

        let imageIdentifier = savedImageURLString ?? imageName

        CoreDataManager.shared.saveCar(
            title: title,
            brand: brand,
            year: year,
            price: price.hasPrefix("$") ? price : "$\(price)",
            carDescription: description,
            imageName: imageIdentifier ?? ""
        )

        NotificationCenter.default.post(name: NSNotification.Name("carSaved"), object: nil)
        showSuccessAndGoBack()
    }

    private func showSuccessAndGoBack() {
        let alert = UIAlertController(
            title: "Listing Published",
            message: "Your car is now live on the marketplace.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.navigationController?.dismiss(animated: true)
        })

        present(alert, animated: true)
    }
}

extension AddCarViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard let provider = results.first?.itemProvider else { return }

        if provider.canLoadObject(ofClass: UIImage.self) {
            provider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
                guard let self = self else { return }

                DispatchQueue.main.async {
                    if let image = object as? UIImage {
                        self.photoImageView.image = image
                        self.photoPlaceholderLabel.isHidden = true

                        if let data = image.jpegData(compressionQuality: 0.85),
                           let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {

                            let filename = "car_\(UUID().uuidString).jpg"
                            let url = docs.appendingPathComponent(filename)

                            do {
                                try data.write(to: url, options: .atomic)
                                self.savedImageURLString = url.absoluteString
                                self.imageNameTextField.text = filename
                            } catch {
                                print("Failed to save image: \(error)")
                            }
                        }
                    }
                }
            }
        }
    }
}
