//
//  receiverCell.swift
//  MySampleApp
//
//  Created by Jay Lad on 03/03/17.
//
//

import UIKit

class receiverCell: UITableViewCell {

    @IBOutlet var lblMessage: UILabel!
    @IBOutlet var lblReceiverName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
