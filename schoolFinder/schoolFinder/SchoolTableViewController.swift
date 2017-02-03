//
//  SchoolTableViewController.swift
//  SchoolFinder
//
//  Created by Kristen Dhuse on 7/22/16.
//  Copyright © 2016 OSU. All rights reserved.
//

import UIKit
import Foundation

var globalSchoolsDict: [String: String] = [:]

class SchoolTableViewController: UITableViewController {
    
    // MARK: Properties
    @IBOutlet var schoolTableView: UITableView!
    var schools = [School]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.schoolTableView.delegate = self
        
        // Use the edit button item provided by the table view controller.
        navigationItem.leftBarButtonItem = editButtonItem()
        
        getSchoolAPIData()
        
    }
    
    // MARK: API Data
    func getSchoolAPIData() {
        // remove all data from schools array
        schools.removeAll()
        globalSchoolsDict = [:]
        
        let data = "\(globalUsername):\(globalPassword)".dataUsingEncoding(NSUTF8StringEncoding)
        let base64 = data!.base64EncodedStringWithOptions([])
        
        // check that URL is valid and setup URL request
        let schoolsEndpoint: String = "http://ec2-52-10-238-162.us-west-2.compute.amazonaws.com:5600/schools"
        guard let url = NSURL(string: schoolsEndpoint) else {
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
                print("error calling GET on /schools")
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
                guard let schoolsJSON = try NSJSONSerialization.JSONObjectWithData(responseData, options: []) as? [[String: AnyObject]] else {
                    print("error trying to convert data to JSON 1")
                    return
                }
                // the schoolsJSON object is an array of dictionaries
                for schoolObject in schoolsJSON {
                    guard let _id = schoolObject["_id"] as? String else {
                        print("Could not get _id from JSON")
                        return
                    }
                    guard let schoolName = schoolObject["schoolName"] as? String else {
                        print("Could not get schoolName from JSON")
                        return
                    }
                    guard let schoolType = schoolObject["typeOfSchool"] as? [String] else {
                        print("Could not get typeOfSchool from JSON")
                        return
                    }
                    guard let schoolPubOrPri = schoolObject["pubOrPri"] as? String else {
                        print("Could not get pubOrPri from JSON")
                        return
                    }
                    guard let schoolLocation = schoolObject["location"] as? String else {
                        print("Could not get location from JSON")
                        return
                    }
                    guard let schoolLanguages = schoolObject["foreignLanguagesTaught"] as? [String] else {
                        print("Could not get foreignLanguagesTaught from JSON")
                        return
                    }
                    guard let schoolRating = schoolObject["rating"] as? Int else {
                        print("Could not get rating from JSON")
                        return
                    }
                    let schoolData = School(_id: _id, schoolName: schoolName, typeOfSchool: schoolType, pubOrPri: schoolPubOrPri, location: schoolLocation, foreignLanguagesTaught: schoolLanguages, rating: schoolRating)
                    self.schools.append(schoolData!)
                    globalSchoolsDict[schoolName] = _id
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.schoolTableView.reloadData()
                }
            } catch {
                print("error trying to convert data to JSON 2")
                return
            }
        })
        task.resume()
    }
    
    func editSchoolAPIData(school: School) {
        let _id = school._id
        
        let data = "\(globalUsername):\(globalPassword)".dataUsingEncoding(NSUTF8StringEncoding)
        let base64 = data!.base64EncodedStringWithOptions([])
        
        // check that URL is valid and setup URL request
        let schoolsEndpoint: String = "http://ec2-52-10-238-162.us-west-2.compute.amazonaws.com:5600/schools/" + _id!
        guard let url = NSURL(string: schoolsEndpoint) else {
            print("Error: cannot create URL")
            return
        }
        let urlRequest = NSMutableURLRequest(URL: url)
        urlRequest.HTTPMethod = "PUT"
        urlRequest.setValue("Basic \(base64)", forHTTPHeaderField: "Authorization")
        
        let jsonSchool: NSData
        jsonSchool = school.toJSON()
        urlRequest.HTTPBody = jsonSchool
        urlRequest.allHTTPHeaderFields!["Content-Type"] = "application/json"
        
        // start NSURLSession
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        
        let task = session.dataTaskWithRequest(urlRequest, completionHandler: { (data, response, message) in
            // check for any errors
            guard message == nil else {
                print("error calling PUT on /schools/_id")
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
                guard let schoolsJSON = try NSJSONSerialization.JSONObjectWithData(responseData, options: []) as? [String: String] else {
                    print(NSString(data: responseData, encoding: NSUTF8StringEncoding))
                    print("error trying to convert data to JSON 1")
                    return
                }
                
                // the schoolsJSON object is a dictionary
                if (schoolsJSON["message"] != "School successfully updated in database.") {
                    print("error trying to update school in database")
                    return
                }
                self.getSchoolAPIData()
                dispatch_async(dispatch_get_main_queue()) {
                    self.schoolTableView.reloadData()
                }
            } catch {
                print("error trying to convert data to JSON 2")
                return
            }
        })
        task.resume()
    }
    
    func deleteSchoolAPIData(school: School) {
        let _id = school._id
        
        let data = "\(globalUsername):\(globalPassword)".dataUsingEncoding(NSUTF8StringEncoding)
        let base64 = data!.base64EncodedStringWithOptions([])
        
        // check that URL is valid and setup URL request
        let schoolsEndpoint: String = "http://ec2-52-10-238-162.us-west-2.compute.amazonaws.com:5600/schools/" + _id!
        guard let url = NSURL(string: schoolsEndpoint) else {
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
                print("error calling DELETE on /schools/_id")
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
                guard let schoolsJSON = try NSJSONSerialization.JSONObjectWithData(responseData, options: []) as? [String: String] else {
                    print(NSString(data: responseData, encoding: NSUTF8StringEncoding))
                    print("error trying to convert data to JSON 1")
                    return
                }
                
                // the schoolsJSON object is a dictionary
                if (schoolsJSON["message"] != "The school with school_id: " + _id! + " has been removed from the database.") {
                    print("error trying to delete school from database")
                    return
                }
                self.getSchoolAPIData()
                dispatch_async(dispatch_get_main_queue()) {
                    self.schoolTableView.reloadData()
                }
            } catch {
                print("error trying to convert data to JSON 2")
                return
            }
        })
        task.resume()
    }
    
    func addSchoolAPIData(school: School) {
        let data = "\(globalUsername):\(globalPassword)".dataUsingEncoding(NSUTF8StringEncoding)
        let base64 = data!.base64EncodedStringWithOptions([])
        
        // check that URL is valid and setup URL request
        let schoolsEndpoint: String = "http://ec2-52-10-238-162.us-west-2.compute.amazonaws.com:5600/schools"
        guard let url = NSURL(string: schoolsEndpoint) else {
            print("Error: cannot create URL")
            return
        }
        let urlRequest = NSMutableURLRequest(URL: url)
        urlRequest.HTTPMethod = "POST"
        urlRequest.setValue("Basic \(base64)", forHTTPHeaderField: "Authorization")
        
        let jsonSchool: NSData
        jsonSchool = school.toJSON()
        urlRequest.HTTPBody = jsonSchool
        urlRequest.allHTTPHeaderFields!["Content-Type"] = "application/json"
        
        // start NSURLSession
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        
        let task = session.dataTaskWithRequest(urlRequest, completionHandler: { (data, response, message) in
            // check for any errors
            guard message == nil else {
                print("error calling POST on /schools")
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
                guard let schoolsJSON = try NSJSONSerialization.JSONObjectWithData(responseData, options: []) as? [String: String] else {
                    print(NSString(data: responseData, encoding: NSUTF8StringEncoding))
                    print("error trying to convert data to JSON 1")
                    return
                }
                
                // the schoolsJSON object is a dictionary
                if (schoolsJSON["message"] != "School successfully added to database.") {
                    print("error trying to add school to database")
                    return
                }
                self.getSchoolAPIData()
                dispatch_async(dispatch_get_main_queue()) {
                    self.schoolTableView.reloadData()
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
        return schools.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "SchoolTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! SchoolTableViewCell
        
        // Fetches the appropriate school for the data source layout.
        let school = schools[indexPath.row]
        
        cell.schoolNameLabel.text = school.schoolName
        cell.typeOfSchoolLabel.text = school.typeOfSchool.joinWithSeparator(", ")
        cell.foreignLanguagesTaughtLabel.text = school.foreignLanguagesTaught?.joinWithSeparator(", ")
        cell.pubOrPriLabel.text = school.pubOrPri
        cell.locationLabel.text = school.location
        cell.ratingLabel.text = String(school.rating)

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
            let school = schools[indexPath.row]
            // Delete the row from the data source
            schools.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            deleteSchoolAPIData(school)
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
        if segue.identifier == "ShowDetail" {
            let schoolDetailViewController = segue.destinationViewController as! SchoolViewController
            
            // Get the cell that generated this segue.
            if let selectedSchoolCell = sender as? SchoolTableViewCell {
                let indexPath = schoolTableView.indexPathForCell(selectedSchoolCell)!
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
            if let selectedIndexPath = schoolTableView.indexPathForSelectedRow {
                // Update an existing school.
                schools[selectedIndexPath.row] = school
                schoolTableView.reloadRowsAtIndexPaths([selectedIndexPath], withRowAnimation: .None)
                editSchoolAPIData(school)
            }
            else {
                addSchoolAPIData(school)
            }
        }
    }
}
