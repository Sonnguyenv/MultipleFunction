//
//  HouseVC.swift
//  MultipleFunction
//
//  Created by Sonnv on 21/07/2021.
//

import UIKit

class HouseVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .green
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "menu"), style: .done, target: self, action: #selector(showSideMenu))
    }

    @objc func showSideMenu() {
        EventHub.post(SideEvent())
    }
}

class SideEvent: EventType {

}
