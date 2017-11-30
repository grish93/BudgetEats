//
//  RestaurantTableViewCell.swift
//  BudgetEats
//
//  Created by Grishma Athavale on 11/19/17.
//  Copyright © 2017 Grishma Athavale. All rights reserved.
//

import UIKit

class RestaurantTableViewCell: UITableViewCell {

    @IBOutlet var myTitle: UILabel!
    
    @IBOutlet var myImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
