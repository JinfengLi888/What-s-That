//
//  DescTableViewCell.swift
//  Whatsthat
//
//  Created by Jinfeng on 11/24/17.
//  Copyright © 2017 jinfeng. All rights reserved.
//

import UIKit

class DescTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var ratioLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
