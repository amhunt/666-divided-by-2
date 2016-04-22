//
//  SetlistTableViewCell.swift
//  Pitchslapp
//
//  Created by Zachary Stecker on 4/22/16.
//  Copyright © 2016 Social Coderz. All rights reserved.
//

import UIKit

class SetlistTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
