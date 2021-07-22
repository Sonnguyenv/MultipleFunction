//
//  TabBarController.swift
//  MultipleFunction
//
//  Created by Sonnv on 11/06/2021.
//

import UIKit

enum TypeTabbar {
    case home
    case heart
    case search

    var title: String {
        switch self {
        case .home:
            return "Home"
        case .heart:
            return "Favorites"
        case .search:
            return "Film"
        }
    }
    
    var image: UIImage? {
        switch self {
        case .home:
            return UIImage(named: "home")
        case .heart:
            return UIImage(named: "heart")
        case .search:
            return UIImage(named: "search")
        }
    }
}

class TabBarController: UITabBarController {

    private let typeTabbars: [TypeTabbar] = [.home, .heart, .search]
    private let listVC: [UIViewController] = [HomeVC(), MusicVC(), FilmVC()]
    private var index: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTabbar()
    }
    
    func setupTabbar() {
        var viewControllers: [UIViewController] = []
        self.typeTabbars.enumerated().forEach { index, type in
            guard let vc = listVC[safe: index] else {return}
            let navi = UINavigationController(rootViewController: vc)
            navi.tabBarItem = UITabBarItem(title: type.title, image: type.image, selectedImage: type.image)
            vc.navigationItem.title = type.title
            viewControllers.append(navi)
        }
        
        self.viewControllers = viewControllers
        self.tabBar.tintColor = .black
        self.delegate = self
    }
}

extension TabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
    }
}

class TabbarEvent: EventType {

}
