//
//  ParentTableViewCell.swift
//  SchoolFinder
//
//  Created by Kristen Dhuse on 7/22/16.
//  Copyright © 2016 OSU. All rights reserved.
//

import UIKit

class ParentTableViewCell: UITableViewCell {
    
    // MARK: Properties
    @IBOutlet weak var parentNameLabel: UILabel!
    @IBOutlet weak var studentsLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
