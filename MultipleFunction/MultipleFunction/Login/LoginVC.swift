//
//  LoginVC.swift
//  MultipleFunction
//
//  Created by SonNV MacMini on 22/07/2021.
//

import UIKit
import RxSwift
import RxCocoa

class LoginVC: BaseVC {
    @IBOutlet weak var textFieldName: UITextField!
    @IBOutlet weak var buttonLogin: UIButton!

//    let disposeBag = DisposeBag()

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

        buttonLogin.rx.tap.subscribe(onNext: {
            if Global.shared.displayName.isEmpty {
                return
            }
            self.login()
        }).disposed(by: disposeBag)
    }
}
