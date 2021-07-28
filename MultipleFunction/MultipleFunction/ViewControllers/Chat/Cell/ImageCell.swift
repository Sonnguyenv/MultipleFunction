//
//  ImageCell.swift
//  MultipleFunction
//
//  Created by Sonnv on 28/07/2021.
//

import UIKit

class ImageCell: UITableViewCell {

    @IBOutlet weak var viewBoundMe: UIView!
    @IBOutlet weak var viewBoundPeople: UIView!
    
    @IBOutlet weak var imageMe: UIImageView!
    @IBOutlet weak var imagePeople: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func parseData(_ message: MessageModel) {
        if message.userId == UIDevice.current.identifierForVendor?.uuidString {
            self.imageMe.image = message.image
            self.viewBoundMe.isHidden = false
            self.viewBoundPeople.isHidden = true
        } else {
            self.imagePeople.image = message.image
            self.viewBoundMe.isHidden = true
            self.viewBoundPeople.isHidden = false
        }
    }
}
