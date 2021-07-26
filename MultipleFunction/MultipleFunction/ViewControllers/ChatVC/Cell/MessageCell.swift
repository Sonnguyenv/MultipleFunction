//
//  MessageCell.swift
//  MultipleFunction
//
//  Created by SonNV MacMini on 22/07/2021.
//

import UIKit

class MessageCell: UITableViewCell {
    @IBOutlet weak var viewMe: UIView!
    @IBOutlet weak var viewPeople: UIView!
    
    @IBOutlet weak var viewBoundMe: UIView!
    @IBOutlet weak var labelNameMe: UILabel!
    @IBOutlet weak var labelMessageMe: UILabel!

    @IBOutlet weak var viewBoundPeople: UIView!
    @IBOutlet weak var labelNamePeople: UILabel!
    @IBOutlet weak var labelMessagePeople: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.viewBoundMe.backgroundColor = .orange
        self.viewBoundMe.layer.cornerRadius = 20
        self.labelMessageMe.textColor = .white
        
        self.viewBoundPeople.backgroundColor = .gray
        self.viewBoundPeople.layer.cornerRadius = 20
        self.labelMessagePeople.textColor = .white
    }

    func parseData(_ model: MessageModel) {
        if model.userId == UIDevice.current.identifierForVendor?.uuidString {
            self.viewMe.isHidden = false
            self.viewPeople.isHidden = true
            
            self.labelNameMe.text = model.userName
            self.labelMessageMe.text = model.content
        } else {
            self.viewMe.isHidden = true
            self.viewPeople.isHidden = false
            
            self.labelNamePeople.text = model.userName
            self.labelMessagePeople.text = model.content
        }
    }
}
