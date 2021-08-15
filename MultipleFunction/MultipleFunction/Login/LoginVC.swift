//
//  LoginVC.swift
//  MultipleFunction
//
//  Created by SonNV MacMini on 22/07/2021.
//

import UIKit
import RxSwift
import RxCocoa
import FirebaseAuth

class LoginVC: BaseVC {
    @IBOutlet weak var textFieldName: UITextField!
    @IBOutlet weak var buttonLogin: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        buttonLogin.layer.cornerRadius = 20

        textFieldName.rx.text.orEmpty
            .subscribe(onNext: { text in
                Global.shared.displayName = text
            }).disposed(by: disposeBag)

        textFieldName.rx.text.orEmpty
            .map({$0.count > 3})
            .bind(onNext: { isEnable in
                self.buttonLogin.setTitleColor(isEnable ? .black : .gray, for: .normal)
            })
            .disposed(by: disposeBag)

        let editingDidEndOnExit = textFieldName.rx.controlEvent([.editingDidEndOnExit]).single()
        let actionLogin = buttonLogin.rx.tap.single()

        Observable.merge(actionLogin, editingDidEndOnExit)
            .do(onNext: {
                if !Global.shared.displayName.isEmpty {
                    self.onShowProgress()
                }
            })
            .subscribe(onNext: {
                if !Global.shared.displayName.isEmpty {
                    Auth.auth().signInAnonymously()
                }
            }, onCompleted: {
                self.onDismissProgress()
            }).disposed(by: disposeBag)
        
    }
}
