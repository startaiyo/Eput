//
//  TagTableViewCell.swift
//  Eput
//
//  Created by 土井星太朗 on 2021/10/21.
//

import UIKit

class TagTableViewCell: UITableViewCell {

    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var tagCheckBtn: CheckBox!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
