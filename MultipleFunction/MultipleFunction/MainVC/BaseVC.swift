//
//  BaseVC.swift
//  MultipleFunction
//
//  Created by SonNV MacMini on 22/07/2021.
//

import UIKit
import RxSwift

class BaseVC: UIViewController {

    let disposeBag = DisposeBag()

    var abc = false

    override func viewDidLoad() {
        super.viewDidLoad()
        initSideMenu(true)
    }

    func initSideMenu(_ isShow: Bool) {
        if isShow {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "menu"), style: .done,
                                                                    target: self, action: #selector(showSideMenu))
            self.navigationItem.leftBarButtonItem?.tintColor = .black
        } else {
            self.navigationItem.leftBarButtonItem = nil
        }
    }

    @objc func showSideMenu() {
        EventHub.post(SideEvent(.home))
    }

    func login() {
        let mainVC = MainVC()
        (UIApplication.shared.delegate as? AppDelegate)?.changeRootViewController(mainVC)
    }

    func logout() {
        Global.shared.clearAll()
        let loginVC = LoginVC()
        (UIApplication.shared.delegate as? AppDelegate)?.changeRootViewController(loginVC)
    }
}

