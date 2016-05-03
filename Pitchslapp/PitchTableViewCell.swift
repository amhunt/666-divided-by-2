//
//  PitchTableViewCell.swift
//  Pitchslapp
//
//  Created by Zachary Stecker on 5/3/16.
//  Copyright © 2016 Social Coderz. All rights reserved.
//

import UIKit

class PitchTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBOutlet weak var pitchLabel: UILabel!
    
}
