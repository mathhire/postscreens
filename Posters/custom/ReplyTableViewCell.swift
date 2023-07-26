//
//  ReplyTableViewCell.swift
//  Posters
//
//  Created by Administrator on 3/6/23.
//

import UIKit

class ReplyTableViewCell: UITableViewCell {

    @IBOutlet weak var btn_like: UIButton!
    @IBOutlet weak var replyLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var lbl_num_like: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
