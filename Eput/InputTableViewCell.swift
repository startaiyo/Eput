//
//  InputTableViewCell.swift
//  Eput
//
//  Created by 土井星太朗 on 2021/09/08.
//

import UIKit

class InputTableViewCell: UITableViewCell {
    @IBOutlet weak var checkBtn: UIButton!
    @IBOutlet weak var inputLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
