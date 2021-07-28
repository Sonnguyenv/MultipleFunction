//
//  ProfileVC.swift
//  MultipleFunction
//
//  Created by Sonnv on 27/07/2021.
//

import UIKit

class ProfileVC: UIViewController {

    @IBOutlet weak var labelName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
        
        self.labelName.text = Global.shared.displayName
    }
}
