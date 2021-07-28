//
//  SettingsViewCell.swift
//  ean
//
//  Created by Michał Hęćka on 12/01/2020.
//  Copyright © 2020 Michał Hęćka. All rights reserved.
//

import UIKit

class SettingsViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var isTrue: UISwitch!
    
}
