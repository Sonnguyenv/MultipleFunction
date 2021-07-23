//
//  MessageCell.swift
//  MultipleFunction
//
//  Created by SonNV MacMini on 22/07/2021.
//

import UIKit

class MessageCell: UITableViewCell {

    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var viewBound: UIView!

    @IBOutlet weak var labelMessage: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.viewBound.backgroundColor = .orange
        self.viewBound.layer.cornerRadius = 20
        self.labelMessage.textColor = .white
    }

    func parseData(_ model: MessageModel) {
        self.labelName.text = model.userName
        self.labelMessage.text = model.content
    }
}
