import Foundation

final class SessionManager {
    static let shared = SessionManager()

    private enum Keys {
        static let name = "currentUserName"
        static let email = "currentUserEmail"
        static let accountType = "currentUserAccountType"
    }

    private let defaults = UserDefaults.standard

    private init() {}

    var currentUserName: String? {
        defaults.string(forKey: Keys.name)
    }

    var currentUserEmail: String? {
        defaults.string(forKey: Keys.email)
    }

    var currentAccountType: String? {
        defaults.string(forKey: Keys.accountType)
    }

    var isBuyer: Bool {
        currentAccountType == "Buyer"
    }

    var isSeller: Bool {
        currentAccountType == "Seller"
    }

    func saveSession(name: String, email: String, accountType: String) {
        defaults.set(name, forKey: Keys.name)
        defaults.set(email, forKey: Keys.email)
        defaults.set(accountType, forKey: Keys.accountType)
    }

    func clearSession() {
        defaults.removeObject(forKey: Keys.name)
        defaults.removeObject(forKey: Keys.email)
        defaults.removeObject(forKey: Keys.accountType)
    }
}
