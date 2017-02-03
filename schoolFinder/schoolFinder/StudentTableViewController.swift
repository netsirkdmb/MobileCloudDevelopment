//
//  StudentTableViewController.swift
//  schoolFinder
//
//  Created by Kristen Dhuse on 8/8/16.
//  Copyright © 2016 OSU. All rights reserved.
//

import UIKit
import Foundation

class StudentTableViewController: UITableViewController {
    
    // MARK: Properties
    @IBOutlet var studentTableView: UITableView!
    var students = [Student]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.studentTableView.delegate = self
        
        // Use the edit button item provided by the table view controller.
        navigationItem.leftBarButtonItem = editButtonItem()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // load students every time view changes so that changes to schools are reflected
        getStudentAPIData()
    }
    
    // MARK: API Data
    func getStudentAPIData() {
        // remove all data from students array
        students.removeAll()
        
        let data = "\(globalUsername):\(globalPassword)".dataUsingEncoding(NSUTF8StringEncoding)
        let base64 = data!.base64EncodedStringWithOptions([])
        
        // check that URL is valid and setup URL request
        let studentsEndpoint: String = "http://ec2-52-10-238-162.us-west-2.compute.amazonaws.com:5600/students"
        guard let url = NSURL(string: studentsEndpoint) else {
            print("Error: cannot create URL")
            return
        }
        let urlRequest = NSMutableURLRequest(URL: url)
        urlRequest.HTTPMethod = "GET"
        urlRequest.setValue("Basic \(base64)", forHTTPHeaderField: "Authorization")
        
        // start NSURLSession
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        
        let task = session.dataTaskWithRequest(urlRequest, completionHandler: { (data, response, message) in
            // check for any errors
            guard message == nil else {
                print("error calling GET on /students")
                print(message)
                return
            }
            // make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            // parse the result as JSON, since that's what the API provides
            do {
                guard let studentsJSON = try NSJSONSerialization.JSONObjectWithData(responseData, options: []) as? [[String: AnyObject]] else {
                    print("error trying to convert data to JSON 1")
                    return
                }
                // the studentsJSON object is an array of dictionaries
                for studentObject in studentsJSON {
                    guard let _id = studentObject["_id"] as? String else {
                        print("Could not get _id from JSON")
                        return
                    }
                    guard let studentName = studentObject["studentName"] as? String else {
                        print("Could not get schoolName from JSON")
                        return
                    }
                    guard let grade = studentObject["grade"] as? String else {
                        print("Could not get pubOrPri from JSON")
                        return
                    }
                    guard let currentSchoolName = studentObject["currentSchoolName"] as? String else {
                        print("Could not get location from JSON")
                        return
                    }
                    guard let currentSchoolID = studentObject["currentSchoolST"] as? String else {
                        print("Could not get rating from JSON")
                        return
                    }
                    guard let pastSchoolsName = studentObject["pastSchoolsName"] as? [String] else {
                        print("Could not get pastSchoolsName from JSON")
                        return
                    }
                    guard let pastSchoolsID = studentObject["pastSchoolsST"] as? [String] else {
                        print("Could not get pastSchoolsID from JSON")
                        return
                    }
                    guard let pastSchoolsDict = studentObject["pastSchoolsDict"] as? [String: String] else {
                        print("Could not get pastSchoolsDict from JSON")
                        return
                    }
                    let studentData = Student(_id: _id, studentName: studentName, grade: grade, currentSchoolName: currentSchoolName, currentSchoolID: currentSchoolID, pastSchoolsName: pastSchoolsName,
                        pastSchoolsID: pastSchoolsID, pastSchoolsDict: pastSchoolsDict)
                    self.students.append(studentData!)
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.studentTableView.reloadData()
                }
            } catch {
                print("error trying to convert data to JSON 2")
                return
            }
        })
        task.resume()
    }
    
    func editStudentAPIData(student: Student) {
        let _id = student._id
        
        let data = "\(globalUsername):\(globalPassword)".dataUsingEncoding(NSUTF8StringEncoding)
        let base64 = data!.base64EncodedStringWithOptions([])
        
        // check that URL is valid and setup URL request
        let studentsEndpoint: String = "http://ec2-52-10-238-162.us-west-2.compute.amazonaws.com:5600/students/" + _id!
        guard let url = NSURL(string: studentsEndpoint) else {
            print("Error: cannot create URL")
            return
        }
        let urlRequest = NSMutableURLRequest(URL: url)
        urlRequest.HTTPMethod = "PUT"
        urlRequest.setValue("Basic \(base64)", forHTTPHeaderField: "Authorization")
        
        let jsonStudent: NSData
        jsonStudent = student.toJSON()
        urlRequest.HTTPBody = jsonStudent
        urlRequest.allHTTPHeaderFields!["Content-Type"] = "application/json"
        
        // start NSURLSession
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        
        let task = session.dataTaskWithRequest(urlRequest, completionHandler: { (data, response, message) in
            // check for any errors
            guard message == nil else {
                print("error calling PUT on /students/_id")
                print(message)
                return
            }
            // make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            // parse the result as JSON, since that's what the API provides
            do {
                guard let studentsJSON = try NSJSONSerialization.JSONObjectWithData(responseData, options: []) as? [String: String] else {
                    print(NSString(data: responseData, encoding: NSUTF8StringEncoding))
                    print("error trying to convert data to JSON 1")
                    return
                }
                
                // the studentsJSON object is a dictionary
                if (studentsJSON["message"] != "Student successfully updated in database.") {
                    print("error trying to update student in database")
                    return
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.studentTableView.reloadData()
                }
            } catch {
                print("error trying to convert data to JSON 2")
                return
            }
        })
        task.resume()
    }
    
    func deleteStudentAPIData(student: Student) {
        let _id = student._id
        
        let data = "\(globalUsername):\(globalPassword)".dataUsingEncoding(NSUTF8StringEncoding)
        let base64 = data!.base64EncodedStringWithOptions([])
        
        // check that URL is valid and setup URL request
        let studentsEndpoint: String = "http://ec2-52-10-238-162.us-west-2.compute.amazonaws.com:5600/students/" + _id!
        guard let url = NSURL(string: studentsEndpoint) else {
            print("Error: cannot create URL")
            return
        }
        let urlRequest = NSMutableURLRequest(URL: url)
        urlRequest.HTTPMethod = "DELETE"
        urlRequest.setValue("Basic \(base64)", forHTTPHeaderField: "Authorization")
        
        // start NSURLSession
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        
        let task = session.dataTaskWithRequest(urlRequest, completionHandler: { (data, response, message) in
            // check for any errors
            guard message == nil else {
                print("error calling DELETE on /students/_id")
                print(message)
                return
            }
            // make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            // parse the result as JSON, since that's what the API provides
            do {
                guard let studentsJSON = try NSJSONSerialization.JSONObjectWithData(responseData, options: []) as? [String: String] else {
                    print(NSString(data: responseData, encoding: NSUTF8StringEncoding))
                    print("error trying to convert data to JSON 1")
                    return
                }
                
                // the studentsJSON object is a dictionary
                if (studentsJSON["message"] != "The student with student_id: " + _id! + " has been removed from the database.") {
                    print("error trying to delete student from database")
                    return
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.studentTableView.reloadData()
                }
            } catch {
                print("error trying to convert data to JSON 2")
                return
            }
        })
        task.resume()
    }
    
    func addStudentAPIData(student: Student) {
        let data = "\(globalUsername):\(globalPassword)".dataUsingEncoding(NSUTF8StringEncoding)
        let base64 = data!.base64EncodedStringWithOptions([])
        
        // check that URL is valid and setup URL request
        let studentsEndpoint: String = "http://ec2-52-10-238-162.us-west-2.compute.amazonaws.com:5600/students"
        guard let url = NSURL(string: studentsEndpoint) else {
            print("Error: cannot create URL")
            return
        }
        let urlRequest = NSMutableURLRequest(URL: url)
        urlRequest.HTTPMethod = "POST"
        urlRequest.setValue("Basic \(base64)", forHTTPHeaderField: "Authorization")
        
        let jsonStudent: NSData
        jsonStudent = student.toJSON()
        urlRequest.HTTPBody = jsonStudent
        urlRequest.allHTTPHeaderFields!["Content-Type"] = "application/json"
        
        // start NSURLSession
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        
        let task = session.dataTaskWithRequest(urlRequest, completionHandler: { (data, response, message) in
            // check for any errors
            guard message == nil else {
                print("error calling POST on /students")
                print(message)
                return
            }
            // make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            // parse the result as JSON, since that's what the API provides
            do {
                guard let studentsJSON = try NSJSONSerialization.JSONObjectWithData(responseData, options: []) as? [String: String] else {
                    print(NSString(data: responseData, encoding: NSUTF8StringEncoding))
                    print("error trying to convert data to JSON 1")
                    return
                }
                
                // the studentsJSON object is a dictionary
                if (studentsJSON["message"] != "Student successfully added to database.") {
                    print("error trying to add student to database")
                    return
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.studentTableView.reloadData()
                }
            } catch {
                print("error trying to convert data to JSON 2")
                return
            }
        })
        task.resume()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
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
        
        // Fetches the appropriate student for the data source layout.
        let student = students[indexPath.row]
        
        cell.studentNameLabel.text = student.studentName
        cell.gradeLabel.text = student.grade
        
        return cell
    }
    
    // Support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let student = students[indexPath.row]
            // Delete the row from the data source
            students.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            deleteStudentAPIData(student)
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
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowStudentDetail" {
            let nav = segue.destinationViewController as! UINavigationController
            let studentDetailViewController = nav.topViewController as! StudentDetailViewController
            
            // Get the cell that generated this segue.
            if let selectedStudentCell = sender as? StudentTableViewCell {
                let indexPath = studentTableView.indexPathForCell(selectedStudentCell)!
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
            if let selectedIndexPath = studentTableView.indexPathForSelectedRow {
                // Update an existing student.
                students[selectedIndexPath.row] = student
                studentTableView.reloadRowsAtIndexPaths([selectedIndexPath], withRowAnimation: .None)
                editStudentAPIData(student)
            }
            else {
                addStudentAPIData(student)
            }
        } else if let detailSourceViewController = sender.sourceViewController as? StudentDetailViewController, student = detailSourceViewController.student {
            if let selectedIndexPath = studentTableView.indexPathForSelectedRow {
                // Update an existing student.
                students[selectedIndexPath.row] = student
                studentTableView.reloadRowsAtIndexPaths([selectedIndexPath], withRowAnimation: .None)
            }
        }
    }
}
