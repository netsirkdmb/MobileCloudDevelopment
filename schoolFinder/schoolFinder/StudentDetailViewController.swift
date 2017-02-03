//
//  StudentDetailViewController.swift
//  schoolFinder
//
//  Created by Kristen Dhuse on 8/9/16.
//  Copyright © 2016 OSU. All rights reserved.
//

import UIKit

class StudentDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate {

    // MARK: Properties
    @IBOutlet weak var studentDetailNameLabel: UILabel!
    @IBOutlet weak var studentDetailGradeLabel: UILabel!
    @IBOutlet weak var studentDetailCurrentSchoolButton: UIButton!
    @IBOutlet weak var pastSchoolsTableView: UITableView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    var student: Student?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // connect data
        self.pastSchoolsTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        pastSchoolsTableView.delegate = self
        pastSchoolsTableView.dataSource = self

        // Set up views of Student.
        let student = self.student
        navigationItem.title = student!.studentName
        studentDetailNameLabel.text = student!.studentName
        studentDetailGradeLabel.text = student!.grade
        if student!.currentSchoolName == "" {
            studentDetailCurrentSchoolButton.setTitle("N/A", forState: UIControlState.Normal)
            studentDetailCurrentSchoolButton.enabled = false
        } else {
            studentDetailCurrentSchoolButton.setTitle(student!.currentSchoolName, forState: UIControlState.Normal)
            studentDetailCurrentSchoolButton.enabled = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return student!.pastSchoolsID!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "PastSchoolsTableViewCell"
        let cell: PastSchoolsTableViewCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! PastSchoolsTableViewCell
        
        // Fetches the appropriate past school for the data source layout.
        let pastSchool = student!.pastSchoolsName![indexPath.row]
        
        cell.studentDetailPastSchoolsLabel.text = pastSchool
        
        return cell
    }
    
    // Support conditional editing of the table view.
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
         if editButton === sender {
            let nav = segue.destinationViewController as! UINavigationController
            let studentViewController = nav.topViewController as! StudentViewController
            studentViewController.student = student
         } else if studentDetailCurrentSchoolButton === sender {
            let currentNav = segue.destinationViewController as! UINavigationController
            let currentSchoolViewController = currentNav.topViewController as! SchoolDetailViewController
            currentSchoolViewController.school_id = student?.currentSchoolID
         } else if segue.identifier == "ShowPastSchoolDetail" {
            let pastNav = segue.destinationViewController as! UINavigationController
            let pastSchoolViewController = pastNav.topViewController as! SchoolDetailViewController
            
            // Get the cell that generated this segue.
            if let selectedSchoolCell = sender as? PastSchoolsTableViewCell {
                let indexPath = pastSchoolsTableView.indexPathForCell(selectedSchoolCell)!
                let selectedSchool = student!.pastSchoolsName![indexPath.row]
                let pastSchoolID = globalSchoolsDict[selectedSchool]
                pastSchoolViewController.school_id = pastSchoolID
            }
        }
    }

}
