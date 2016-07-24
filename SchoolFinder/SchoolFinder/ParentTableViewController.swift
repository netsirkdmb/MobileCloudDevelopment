//
//  ParentTableViewController.swift
//  SchoolFinder
//
//  Created by Kristen Dhuse on 7/23/16.
//  Copyright © 2016 OSU. All rights reserved.
//

import UIKit

class ParentTableViewController: UITableViewController {

    // MARK: Properties
    var parents = [Parent]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Use the edit button item provided by the table view controller.
        navigationItem.leftBarButtonItem = editButtonItem()
        
        // Load any saved parents, otherwise load sample data.
        if let savedParents = loadParents() {
            parents += savedParents
        }
        else {
            // Load the sample data.
            loadSampleParents()
        }
        
    }
    
    func loadSampleParents() {
        let parent1 = Parent(name: "James Potter", students: ["Harry Potter"])!
        
        let parent2 = Parent(name: "Lily Potter", students: ["Harry Potter"])!
        
        let parent3 = Parent(name: "Mr. Granger", students: ["Hermione Granger"])!
        
        let parent4 = Parent(name: "Mrs. Granger", students: ["Hermione Granger"])!
        
        let parent5 = Parent(name: "Arthur Weasley", students: ["Ron Weasley"])!
        
        let parent6 = Parent(name: "Molly Weasley", students: ["Ron Weasley"])!
        
        parents += [parent1, parent2, parent3, parent4, parent5, parent6]
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
        return parents.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "ParentTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ParentTableViewCell
        
        // Fetches the appropriate meal for the data source layout.
        let parent = parents[indexPath.row]
        
        cell.parentNameLabel.text = parent.name
        cell.studentsLabel.text = parent.students
        
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
            parents.removeAtIndex(indexPath.row)
            saveParents()
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
        if segue.identifier == "ShowParentDetail" {
            let parentDetailViewController = segue.destinationViewController as! ParentViewController
            
            // Get the cell that generated this segue.
            if let selectedParentCell = sender as? ParentTableViewCell {
                let indexPath = tableView.indexPathForCell(selectedParentCell)!
                let selectedParent = parents[indexPath.row]
                parentDetailViewController.parent = selectedParent
            }
        }
        else if segue.identifier == "AddParent" {
            print("Adding a new parent.")
        }
    }
    
    @IBAction func unwindToParentList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.sourceViewController as? ParentViewController, parent = sourceViewController.parent {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing parent.
                parents[selectedIndexPath.row] = parent
                tableView.reloadRowsAtIndexPaths([selectedIndexPath], withRowAnimation: .None)
            }
            else {
                // Add a new parent.
                let newIndexPath = NSIndexPath(forRow: parents.count, inSection: 0)
                parents.append(parent)
                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Bottom)
            }
            // Save the parents.
            saveParents()
        }
    }
    
    // MARK: NSCoding
    func saveParents() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(parents, toFile: Parent.ArchiveURL.path!)
        if !isSuccessfulSave {
            print("Failed to save parents...")
        }
    }
    
    func loadParents() -> [Parent]? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(Parent.ArchiveURL.path!) as? [Parent]
    }
}
