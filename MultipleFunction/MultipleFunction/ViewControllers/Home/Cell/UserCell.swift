//
//  UserCell.swift
//  MultipleFunction
//
//  Created by SonNV MacMini on 23/07/2021.
//

import UIKit

class UserCell: UITableViewCell {

    @IBOutlet weak var labelName: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    func parseData(_ room: RoomModel) {
        self.labelName.text = room.name
    }
}
