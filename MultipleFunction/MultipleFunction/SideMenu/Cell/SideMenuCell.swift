//
//  SideMenuCell.swift
//  MultipleFunction
//
//  Created by Sonnv on 21/07/2021.
//

import UIKit

class SideMenuCell: UITableViewCell {
    
    class var identifier: String { return String(describing: self) }
    class var nib: UINib { return UINib(nibName: identifier, bundle: nil) }
    
    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Background
        self.backgroundColor = .clear
        

    }

    func parseData(_ type: TypeSideMenu) {
        // Icon
        self.iconImageView.image = type.image
        self.iconImageView.tintColor = .white

        // Title
        self.titleLabel.textColor = .white
        self.titleLabel.text = type.title
    }
}
