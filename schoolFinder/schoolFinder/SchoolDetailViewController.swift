//
//  SchoolDetailViewController.swift
//  schoolFinder
//
//  Created by Kristen Dhuse on 8/10/16.
//  Copyright © 2016 OSU. All rights reserved.
//

import UIKit

class SchoolDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate {
    
    //MARK: - Properties
    @IBOutlet weak var schoolDetailTableView: UITableView!
    //
    var school_id: String?
    var schools = [School]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // connect data
        self.schoolDetailTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        schoolDetailTableView.delegate = self
        schoolDetailTableView.dataSource = self
        
        // Do any additional setup after loading the view.
        getSchoolIdAPIData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: API Data
    func getSchoolIdAPIData() {
        let _id = school_id
        
        let data = "\(globalUsername):\(globalPassword)".dataUsingEncoding(NSUTF8StringEncoding)
        let base64 = data!.base64EncodedStringWithOptions([])
        
        // check that URL is valid and setup URL request
        let schoolsEndpoint: String = "http://ec2-52-10-238-162.us-west-2.compute.amazonaws.com:5600/schools/" + _id!
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
                print("error calling GET on /schools/id")
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
                guard let schoolsJSON = try NSJSONSerialization.JSONObjectWithData(responseData, options: []) as? [String: AnyObject] else {
                    print("error trying to convert data to JSON 1")
                    return
                }
                // the schoolsJSON object is a dictionary
                guard let _id = schoolsJSON["_id"] as? String else {
                    print("Could not get _id from JSON")
                    return
                }
                guard let schoolName = schoolsJSON["schoolName"] as? String else {
                    print("Could not get schoolName from JSON")
                    return
                }
                guard let schoolType = schoolsJSON["typeOfSchool"] as? [String] else {
                    print("Could not get typeOfSchool from JSON")
                    return
                }
                guard let schoolPubOrPri = schoolsJSON["pubOrPri"] as? String else {
                    print("Could not get pubOrPri from JSON")
                    return
                }
                guard let schoolLocation = schoolsJSON["location"] as? String else {
                    print("Could not get location from JSON")
                    return
                }
                guard let schoolLanguages = schoolsJSON["foreignLanguagesTaught"] as? [String] else {
                    print("Could not get foreignLanguagesTaught from JSON")
                    return
                }
                guard let schoolRating = schoolsJSON["rating"] as? Int else {
                    print("Could not get rating from JSON")
                    return
                }
                let schoolData = School(_id: _id, schoolName: schoolName, typeOfSchool: schoolType, pubOrPri: schoolPubOrPri, location: schoolLocation, foreignLanguagesTaught: schoolLanguages, rating: schoolRating)
                self.schools.append(schoolData!)
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.schoolDetailTableView.reloadData()
                }
            } catch {
                print("error trying to convert data to JSON 2")
                return
            }
        })
        task.resume()
    }
    
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schools.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "SchoolDetailTableViewCell"
        let cell: SchoolDetailTableViewCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! SchoolDetailTableViewCell
        
        // Fetches the appropriate school for the data source layout.
        let school = schools[indexPath.row]
        
        cell.detailSchoolNameLabel.text = school.schoolName
        cell.detailTypeOfSchoolLabel.text = school.typeOfSchool.joinWithSeparator(", ")
        cell.detailPublicOrPrivateSchoolLabel.text = school.pubOrPri + " School"
        cell.detailLocationLabel.text = school.location
        cell.detailForeignLanguagesTaughtLabel.text = school.foreignLanguagesTaught?.joinWithSeparator(", ")
        cell.detailRatingLabel.text = String(school.rating)
        
        return cell
    }
    
    // Support conditional editing of the table view.
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
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
    @IBAction func done(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "EditSchoolDetail" {
            let nav = segue.destinationViewController as! UINavigationController
            let schoolDetailViewController = nav.topViewController as! SchoolViewController
            schoolDetailViewController.school = schools[0]
        }
    }

}
