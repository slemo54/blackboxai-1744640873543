import UIKit

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        tabBar.tintColor = UIColor(named: "Gold")
        tabBar.unselectedItemTintColor = UIColor.lightGray
    }
    
    private func setupViewControllers() {
        // Episodes View Controller
        let episodesVC = EpisodesViewController()
        episodesVC.tabBarItem = UITabBarItem(
            title: "Episodes",
            image: UIImage(systemName: "headphones"),
            selectedImage: UIImage(systemName: "headphones.fill")
        )
        let episodesNav = UINavigationController(rootViewController: episodesVC)
        
        // Library View Controller
        let libraryVC = LibraryViewController()
        libraryVC.tabBarItem = UITabBarItem(
            title: "Library",
            image: UIImage(systemName: "square.stack.fill"),
            selectedImage: nil
        )
        let libraryNav = UINavigationController(rootViewController: libraryVC)
        
        // Blog View Controller
        let blogVC = BlogViewController()
        blogVC.tabBarItem = UITabBarItem(
            title: "Blog",
            image: UIImage(systemName: "newspaper"),
            selectedImage: UIImage(systemName: "newspaper.fill")
        )
        let blogNav = UINavigationController(rootViewController: blogVC)
        
        viewControllers = [episodesNav, libraryNav, blogNav]
    }
}
