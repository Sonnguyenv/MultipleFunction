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

class BaseVC: UIViewController, BaseView {

    let child = SpinnerViewController()

    let disposeBag = DisposeBag()

    let currentUser = Auth.auth().currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerKeyboardNotifications()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
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
    
    func handleError(_ error: Error, option: Any?) {
        onDismissProgress()
        let alertError = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alertError.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alertError, animated: true, completion: nil)
    }
    
    func onShowProgress() {
        // add the spinner view controller
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        self.addChild(child)
        self.child.view.frame = view.frame
        self.view.addSubview(child.view)
        self.child.didMove(toParent: self)

    }

    func onDismissProgress() {
        self.child.willMove(toParent: nil)
        self.child.view.removeFromSuperview()
        self.child.removeFromParent()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func addSideMenu() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "menu"), style: .done,
                                                                target: self, action: #selector(showSideMenu))
        self.navigationItem.leftBarButtonItem?.tintColor = .black
    }
    
    @objc func showSideMenu() {
        EventHub.post(SideEvent())
    }
    
    private func registerKeyboardNotifications() {
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
            .subscribe(onNext: { notification in
                self.keyboardWillShow(notification as NSNotification)
        }).disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
            .map({$0})
            .subscribe(onNext: { notification in
                self.keyboardWillHide(notification as NSNotification)
        }).disposed(by: disposeBag)
    }
    
    @objc private func keyboardWillShow(_ notification: NSNotification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        let bottom = keyboardViewEndFrame.height - view.safeAreaInsets.bottom
        self.heightKeyboard(height: bottom)
    }

    @objc private func keyboardWillHide(_ notification: NSNotification) {
        self.keyboardHide()
    }
    
    func heightKeyboard(height: CGFloat) {
        
    }
    
    func keyboardHide() {
    
    }
}

