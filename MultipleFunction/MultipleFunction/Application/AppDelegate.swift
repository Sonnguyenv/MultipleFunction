//
//  AppDelegate.swift
//  MultipleFunction
//
//  Created by Sonnv on 21/07/2021.
//

import UIKit
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        self.initViews()
        return true
    }

    func initViews() {
        let window = UIWindow(frame: UIScreen.main.bounds)
        if #available(iOS 13.0, *) {
            window.overrideUserInterfaceStyle = .light
        }
        if !Global.shared.displayName.isEmpty {
            window.rootViewController = MainVC()
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

