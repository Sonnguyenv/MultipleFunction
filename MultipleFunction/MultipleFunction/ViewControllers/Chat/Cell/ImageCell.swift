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
    
    @IBOutlet weak var labelNameMe: UILabel!
    @IBOutlet weak var labelNamePeople: UILabel!
    
    @IBOutlet weak var imageMe: UIImageView!
    @IBOutlet weak var imagePeople: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        self.imageMe.layer.cornerRadius = 10
        self.imagePeople.layer.cornerRadius = 10
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func parseData(_ message: MessageModel) {
        if message.userId == UIDevice.current.identifierForVendor?.uuidString {
            self.labelNameMe.text = message.userName
            self.imageMe.image = message.image?.scaledToSafeUploadSize
            self.viewBoundMe.isHidden = false
            self.viewBoundPeople.isHidden = true
        } else {
            self.labelNamePeople.text = message.userName
            self.imagePeople.image = message.image?.scaledToSafeUploadSize
            self.viewBoundMe.isHidden = true
            self.viewBoundPeople.isHidden = false
        }
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
}
