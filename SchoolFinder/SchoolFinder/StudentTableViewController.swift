//
//  StudentTableViewController.swift
//  SchoolFinder
//
//  Created by Kristen Dhuse on 7/23/16.
//  Copyright © 2016 OSU. All rights reserved.
//

import UIKit

class StudentTableViewController: UITableViewController {
    
    // MARK: Properties
    var students = [Student]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Use the edit button item provided by the table view controller.
        navigationItem.leftBarButtonItem = editButtonItem()
        
        // Load any saved students, otherwise load sample data.
        if let savedStudents = loadStudents() {
            students += savedStudents
        }
        else {
            // Load the sample data.
            loadSampleStudents()
        }
        
    }
    
    func loadSampleStudents() {
        let student1 = Student(name: "Harry Potter", grade: "6", currentSchool: "International School", pastSchools: ["Puesta del Sol Elementary School", "Bright Horizons - West Campus"], parents: ["James Potter", "Lily Potter"])!
        
        let student2 = Student(name: "Hermione Granger", grade: "7", currentSchool: "International School", pastSchools: ["Puesta del Sol Elementary School", "Bright Horizons - West Campus"], parents: ["Mr. Granger", "Mrs. Granger"])!
        
        let student3 = Student(name: "Ron Weasley", grade: "5", currentSchool: "Puesta del Sol Elementary School", pastSchools: ["Bright Horizons - West Campus"], parents: ["Arthur Weasley", "Molly Weasley"])!
        
        students += [student1, student2, student3]
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
        return students.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "StudentTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! StudentTableViewCell
        
        // Fetches the appropriate meal for the data source layout.
        let student = students[indexPath.row]
        
        cell.studentNameLabel.text = student.name
        cell.gradeLabel.text = student.grade
        cell.currentSchoolLabel.text = student.currentSchool
        cell.parentsLabel.text = student.parents
        
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
            students.removeAtIndex(indexPath.row)
            saveStudents()
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
        if segue.identifier == "ShowStudentDetail" {
            let studentDetailViewController = segue.destinationViewController as! StudentViewController
            
            // Get the cell that generated this segue.
            if let selectedStudentCell = sender as? StudentTableViewCell {
                let indexPath = tableView.indexPathForCell(selectedStudentCell)!
                let selectedStudent = students[indexPath.row]
                studentDetailViewController.student = selectedStudent
            }
        }
        else if segue.identifier == "AddStudent" {
            print("Adding a new student.")
        }
    }
    
    @IBAction func unwindToStudentList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.sourceViewController as? StudentViewController, student = sourceViewController.student {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing student.
                students[selectedIndexPath.row] = student
                tableView.reloadRowsAtIndexPaths([selectedIndexPath], withRowAnimation: .None)
            }
            else {
                // Add a new student.
                let newIndexPath = NSIndexPath(forRow: students.count, inSection: 0)
                students.append(student)
                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Bottom)
            }
            // Save the students.
            saveStudents()
        }
    }
    
    // MARK: NSCoding
    func saveStudents() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(students, toFile: Student.ArchiveURL.path!)
        if !isSuccessfulSave {
            print("Failed to save students...")
        }
    }
    
    func loadStudents() -> [Student]? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(Student.ArchiveURL.path!) as? [Student]
    }
}
