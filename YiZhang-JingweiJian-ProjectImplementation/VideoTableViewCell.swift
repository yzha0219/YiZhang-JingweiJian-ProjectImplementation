//
//  VideoTableViewCell.swift
//  YiZhang-JingweiJian-ProjectImplementation
//
//  Created by Yi Zhang on 9/11/19.
//  Copyright © 2019 Yi Zhang. All rights reserved.
//

import UIKit

class VideoTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
