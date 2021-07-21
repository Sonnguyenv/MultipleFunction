//
//  TabBarController.swift
//  MultipleFunction
//
//  Created by Sonnv on 11/06/2021.
//

import UIKit

enum TypeTabbar {
    case house
    case music
    case film
    
    var title: String {
        switch self {
        case .house:
            return "House"
        case .music:
            return "Music"
        case .film:
            return "Film"
        }
    }
    
    var image: UIImage? {
        switch self {
        case .house:
            return UIImage(systemName: "house.fill")!
        case .music:
            return UIImage(systemName: "music.note")!
        case .film:
            return UIImage(systemName: "film.fill")!
        }
    }
}

class TabBarController: UITabBarController {

    private let typeTabbars: [TypeTabbar] = [.house, .music, .film]
    private let listVC: [UIViewController] = [HouseVC(), MusicVC(), FilmVC()]
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
            navi.tabBarItem = UITabBarItem(title: "", image: type.image, selectedImage: type.image)
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

