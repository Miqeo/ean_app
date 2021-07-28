//
//  ProductCell.swift
//  ean_app
//
//  Created by Michał Hęćka on 02/01/2020.
//  Copyright © 2020 Michał Hęćka. All rights reserved.
//

import UIKit

class ProductCell: UICollectionViewCell {
    
    @IBOutlet weak var productImage: UIImageView!
    
    @IBOutlet weak var productTitle: UILabel!
    @IBAction func longPressed(_ sender: Any) {
        print("LongPressed")
    }
}
