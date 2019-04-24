//
//  MsgTableViewCell.swift
//  ChatApp
//
//  Created by Focaloid on 18/04/19.
//  Copyright © 2019 Focaloid. All rights reserved.
//

import UIKit

class MsgTableViewCell: UITableViewCell {

    @IBOutlet weak var msg: UILabel!
    @IBOutlet weak var title: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
