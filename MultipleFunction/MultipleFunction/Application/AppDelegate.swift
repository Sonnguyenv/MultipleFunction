//
//  AppDelegate.swift
//  MultipleFunction
//
//  Created by Sonnv on 21/07/2021.
//

import UIKit
import Firebase
import FirebaseAuth

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        self.initViews()

        NotificationCenter.default.addObserver(
          self,
          selector: #selector(initViews),
          name: .AuthStateDidChange,
          object: nil)

        return true
    }

    @objc func initViews() {
        let window = UIWindow(frame: UIScreen.main.bounds)
        if #available(iOS 13.0, *) {
            window.overrideUserInterfaceStyle = .light
        }
        if let _ = Auth.auth().currentUser, !Global.shared.displayName.isEmpty {
            let vc = MainVC()
            let navi = UINavigationController(rootViewController: vc)
            window.rootViewController = navi
        } else {
            window.rootViewController = LoginVC()
        }
        window.makeKeyAndVisible()
        self.window = window
    }

    func changeRootViewController(_ vc: UIViewController, animated: Bool = true) {
        guard let window = self.window else {
            return
        }

        window.rootViewController = vc
        // add animation
        UIView.transition(with: window, duration: 0.5, options: [.curveEaseIn], animations: nil, completion: nil)

    }

}

