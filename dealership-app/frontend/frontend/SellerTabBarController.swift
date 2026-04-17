import UIKit

final class SellerTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = AppTheme.accentDark
        tabBar.backgroundColor = .white

        if let navigationController = viewControllers?.first as? UINavigationController,
           navigationController.viewControllers.isEmpty {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let listingsVC = storyboard.instantiateViewController(withIdentifier: "MyListingsViewController") as? MyListingsViewController {
                listingsVC.title = "Listings"
                navigationController.setViewControllers([listingsVC], animated: false)
            }
        }

        viewControllers?.first?.tabBarItem.title = "Listings"
        viewControllers?.last?.tabBarItem.title = "Dashboard"
    }
}
