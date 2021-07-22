//
//  HouseVC.swift
//  MultipleFunction
//
//  Created by Sonnv on 21/07/2021.
//

import UIKit
import RxSwift
import RxCocoa

class HomeVC: BaseVC {

    @IBOutlet weak var buttonGoto: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        buttonGoto.layer.cornerRadius = 20

        buttonGoto.rx.tap.subscribe(onNext: {
            let vc = ChatVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: disposeBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.tabBarController?.tabBar.isHidden = false
    }
}
