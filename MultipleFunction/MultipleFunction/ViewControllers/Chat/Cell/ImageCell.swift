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
    @IBOutlet weak var csWidth: NSLayoutConstraint!
    @IBOutlet weak var csHeight: NSLayoutConstraint!
    
    
    private var heightImage: CGFloat = 200.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        self.imageMe.layer.cornerRadius = 20
        self.imagePeople.layer.cornerRadius = 20
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func parseData(_ message: MessageModel) {
        if message.userId == UIDevice.current.identifierForVendor?.uuidString {
            self.labelNameMe.text = message.userName
            self.imageMe.image = message.image
            self.csWidth.constant = message.image?.size.width ?? 200.0
            self.csHeight.constant = message.image?.size.height ?? 200.0
            self.viewBoundMe.isHidden = false
            self.viewBoundPeople.isHidden = true
        } else {
            self.labelNamePeople.text = message.userName
            self.imagePeople.image = message.image
            self.viewBoundMe.isHidden = true
            self.viewBoundPeople.isHidden = false
        }
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
}
