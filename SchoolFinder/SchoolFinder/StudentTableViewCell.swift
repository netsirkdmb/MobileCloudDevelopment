//
//  StudentTableViewCell.swift
//  SchoolFinder
//
//  Created by Kristen Dhuse on 7/22/16.
//  Copyright © 2016 OSU. All rights reserved.
//

import UIKit

class StudentTableViewCell: UITableViewCell {
    
    // MARK: Properties
    @IBOutlet weak var studentNameLabel: UILabel!
    @IBOutlet weak var gradeLabel: UILabel!
    @IBOutlet weak var currentSchoolLabel: UILabel!
    @IBOutlet weak var parentsLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
