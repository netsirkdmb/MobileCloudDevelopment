//
//  SchoolTableViewController.swift
//  SchoolFinder
//
//  Created by Kristen Dhuse on 7/23/16.
//  Copyright © 2016 OSU. All rights reserved.
//

import UIKit

class SchoolTableViewController: UITableViewController {
    
    // MARK: Properties
    var schools = [School]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Use the edit button item provided by the table view controller.
        navigationItem.leftBarButtonItem = editButtonItem()
        
        // Load any saved schools, otherwise load sample data.
        if let savedSchools = loadSchools() {
            schools += savedSchools
        }
        else {
            // Load the sample data.
            loadSampleSchools()
        }
        
    }
    
    func loadSampleSchools() {
        let school1 = School(name: "Puesta del Sol Elementary School", type: ["Elementary School (K-5)"], pubOrPri: "Public", location: "98006", language: ["Spanish"], rating: 6)!
        
        let school2 = School(name: "International School", type: ["Middle School (6-8)", "High School (9-12)"], pubOrPri: "Public", location: "98005", language: ["Spanish", "French", "Japanese"], rating: 9)!
        
        let school3 = School(name: "Bright Horizons - West Campus", type: ["Daycare", "Preschool"], pubOrPri: "Private", location: "98004", language: ["Spanish"], rating: 10)!
        
        schools += [school1, school2, school3]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schools.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "SchoolTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! SchoolTableViewCell
        
        // Fetches the appropriate meal for the data source layout.
        let school = schools[indexPath.row]
        
        cell.schoolNameLabel.text = school.name
        cell.locationLabel.text = school.location
        cell.ratingControl.rating = school.rating
        cell.typeOfSchool.text = school.type
        cell.pubPriLabel.text = school.pubOrPri
        
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            schools.removeAtIndex(indexPath.row)
            saveSchools()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    /*
     // Override to support rearranging the table view.
     override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    // MARK: Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowSchoolDetail" {
            let schoolDetailViewController = segue.destinationViewController as! SchoolViewController
            
            // Get the cell that generated this segue.
            if let selectedSchoolCell = sender as? SchoolTableViewCell {
                let indexPath = tableView.indexPathForCell(selectedSchoolCell)!
                let selectedSchool = schools[indexPath.row]
                schoolDetailViewController.school = selectedSchool
            }
        }
        else if segue.identifier == "AddSchool" {
            print("Adding a new school.")
        }
    }
    
    @IBAction func unwindToSchoolList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.sourceViewController as? SchoolViewController, school = sourceViewController.school {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing school.
                schools[selectedIndexPath.row] = school
                tableView.reloadRowsAtIndexPaths([selectedIndexPath], withRowAnimation: .None)
            }
            else {
                // Add a new school.
                let newIndexPath = NSIndexPath(forRow: schools.count, inSection: 0)
                schools.append(school)
                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Bottom)
            }
            // Save the schools.
            saveSchools()
        }
    }
    
    // MARK: NSCoding
    func saveSchools() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(schools, toFile: School.ArchiveURL.path!)
        if !isSuccessfulSave {
            print("Failed to save schools...")
        }
    }
    
    func loadSchools() -> [School]? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(School.ArchiveURL.path!) as? [School]
    }
}
