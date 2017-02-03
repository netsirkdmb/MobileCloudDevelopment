//
//  SchoolDetailTableViewCell.swift
//  schoolFinder
//
//  Created by Kristen Dhuse on 8/10/16.
//  Copyright © 2016 OSU. All rights reserved.
//

import UIKit

class SchoolDetailTableViewCell: UITableViewCell {

    // MARK: - Properties
    @IBOutlet weak var detailSchoolNameLabel: UILabel!
    @IBOutlet weak var detailTypeOfSchoolLabel: UILabel!
    @IBOutlet weak var detailPublicOrPrivateSchoolLabel: UILabel!
    @IBOutlet weak var detailLocationLabel: UILabel!
    @IBOutlet weak var detailForeignLanguagesTaughtLabel: UILabel!
    @IBOutlet weak var detailRatingLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
