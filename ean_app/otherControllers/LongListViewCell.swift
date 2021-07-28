//
//  LongListViewCell.swift
//  
//
//  Created by Michał Hęćka on 08/01/2020.
//

import UIKit

class LongListViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBOutlet weak var valueOfProduct: UILabel!
    @IBOutlet weak var selectProduct: UIButton!
    @IBOutlet weak var valueBack: DesignableView!
    
    
    
}
