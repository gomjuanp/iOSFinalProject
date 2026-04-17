import UIKit

final class CarImageLoader {
    static let shared = CarImageLoader()
    private let cache = NSCache<NSString, UIImage>()
    private init() {}

    func loadImage(from value: String?, completion: @escaping (UIImage?) -> Void) {
        guard let value, !value.isEmpty else {
            completion(nil)
            return
        }

        if let cached = cache.object(forKey: value as NSString) {
            completion(cached)
            return
        }

        if let local = UIImage(named: value) {
            cache.setObject(local, forKey: value as NSString)
            completion(local)
            return
        }

        guard let url = URL(string: value),
              let scheme = url.scheme?.lowercased(),
              scheme == "http" || scheme == "https" else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            var image: UIImage?
            if let data, let remoteImage = UIImage(data: data) {
                image = remoteImage
                self?.cache.setObject(remoteImage, forKey: value as NSString)
            }
            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }
}

extension UIImageView {
    func setCarImage(from value: String?, placeholderSystemName: String = "car.fill") {
        image = UIImage(systemName: placeholderSystemName)
        tintColor = AppTheme.accentDark
        contentMode = .scaleAspectFill
        clipsToBounds = true

        CarImageLoader.shared.loadImage(from: value) { [weak self] loadedImage in
            if let loadedImage {
                self?.image = loadedImage
                self?.tintColor = nil
            }
        }
    }
}
