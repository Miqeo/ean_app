//
//  TitleAndImageViewCell.swift
//  ean_app
//
//  Created by Michał Hęćka on 04/01/2020.
//  Copyright © 2020 Michał Hęćka. All rights reserved.
//

import UIKit

class TitleAndImageViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBOutlet weak var titleOfProduct: UILabel!
    @IBOutlet weak var valueOfProduct: UILabel!
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
}
