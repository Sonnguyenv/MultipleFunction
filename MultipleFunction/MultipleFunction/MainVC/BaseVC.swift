//
//  BaseVC.swift
//  MultipleFunction
//
//  Created by SonNV MacMini on 22/07/2021.
//

import UIKit
import RxSwift
import FirebaseAuth
import FirebaseFirestore

class BaseVC: UIViewController {

    let child = SpinnerViewController()

    let disposeBag = DisposeBag()

    let user = Auth.auth().currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Actions
    @objc func logout() {
        let alertController = UIAlertController(
            title: nil,
            message: "Are you sure you want to sign out?",
            preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)

        let signOutAction = UIAlertAction( title: "Sign Out", style: .destructive) { _ in
            do {
                Global.shared.clearAll()
                try Auth.auth().signOut()
            } catch {
                print("Error signing out: \(error.localizedDescription)")
            }
        }
        alertController.addAction(signOutAction)

        present(alertController, animated: true)
    }

    func onShowProgress() {
        // add the spinner view controller
        self.addChild(child)
        self.child.view.frame = view.frame
        self.view.addSubview(child.view)
        self.child.didMove(toParent: self)

    }

    func onDismissProgress() {
        self.child.willMove(toParent: nil)
        self.child.view.removeFromSuperview()
        self.child.removeFromParent()
    }
}

