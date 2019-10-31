//
//  PhotoTableViewCell.swift
//  YiZhang-JingweiJian-ProjectImplementation
//
//  Created by Yi Zhang on 31/10/19.
//  Copyright © 2019 Yi Zhang. All rights reserved.
//

import UIKit

class PhotoTableViewCell: UITableViewCell {

    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var timeLable: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
