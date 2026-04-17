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

        // Try URL first (http/https/file)
        if let url = URL(string: value), let scheme = url.scheme?.lowercased() {
            if scheme == "http" || scheme == "https" {
                URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                    var image: UIImage?
                    if let data, let remoteImage = UIImage(data: data) {
                        image = remoteImage
                        self?.cache.setObject(remoteImage, forKey: value as NSString)
                    }
                    DispatchQueue.main.async { completion(image) }
                }.resume()
                return
            } else if scheme == "file" {
                if let data = try? Data(contentsOf: url), let img = UIImage(data: data) {
                    self.cache.setObject(img, forKey: value as NSString)
                    completion(img)
                    return
                }
            }
        }

        // Fallback: treat as a local filename in Documents directory
        if let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = docs.appendingPathComponent(value)
            if let data = try? Data(contentsOf: fileURL), let img = UIImage(data: data) {
                self.cache.setObject(img, forKey: value as NSString)
                completion(img)
                return
            }
        }

        // If all else fails
        completion(nil)
        return
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
