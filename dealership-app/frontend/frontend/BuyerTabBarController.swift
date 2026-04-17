import UIKit

final class BuyerTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = AppTheme.accentDark
        tabBar.backgroundColor = .white
        viewControllers?.first?.tabBarItem.title = "Browse"
        viewControllers?.last?.tabBarItem.title = "Purchases"
    }
}
