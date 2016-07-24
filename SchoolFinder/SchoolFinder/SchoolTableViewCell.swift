//
//  SchoolTableViewCell.swift
//  SchoolFinder
//
//  Created by Kristen Dhuse on 7/22/16.
//  Copyright © 2016 OSU. All rights reserved.
//

import UIKit

class SchoolTableViewCell: UITableViewCell {
    
    // MARK: Properties
    @IBOutlet weak var schoolNameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var ratingControl: RatingControl!
    @IBOutlet weak var typeOfSchool: TypeOfSchoolControl!
    @IBOutlet weak var pubPriLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
