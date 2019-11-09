//
//  PhotoTableViewController.swift
//  YiZhang-JingweiJian-ProjectImplementation
//
//  Created by Yi Zhang on 31/10/19.
//  Copyright © 2019 Yi Zhang. All rights reserved.
//

import UIKit
import AWSCore
import AWSCognito
import AWSS3
import Firebase
import FirebaseDatabase

class PhotoTableViewController: UITableViewController, UISearchResultsUpdating {
    
    var ref: DatabaseReference!
    var filenames: [AWSS3Object] = []
    var filterFilenames: [AWSS3Object] = []
    var photoDelegate: PhotoDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        let searchController = UISearchController(searchResultsController: nil);
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Photo"
        navigationItem.searchController = searchController
        
        definesPresentationContext = true
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        ref = Database.database().reference(fromURL: "https://fit5140-ass2-963d6.firebaseio.com/").child("Detect")
        ref.observe(.childChanged){ snapshot in
            appDelegate!.handleEvent()
            self.displayMessage("Detected","Pet has been detected, and the photo of it has been taken as well!")
            self.navigationController?.popViewController(animated: true)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return filenames.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let photoCell = tableView.dequeueReusableCell(withIdentifier: "photoCell", for: indexPath) as! PhotoTableViewCell

        // Configure the cell...
        let photo = filenames[indexPath.row]
        photoCell.timeLabel.text = photo.key!
        let transferUtility = AWSS3TransferUtility.default()
        let expression = AWSS3TransferUtilityDownloadExpression()
        transferUtility.downloadData(fromBucket: "petsitter1", key: photo.key!, expression: expression){(task, url, data, error) in
            if error != nil{
                print(error!)
                return
            }
            DispatchQueue.main.async(execute: {
                photoCell.photo.image = UIImage(data: data!)!
            })
        }
        return photoCell
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let filename = filenames[indexPath.row]
        let transferUtility = AWSS3TransferUtility.default()
        let expression = AWSS3TransferUtilityDownloadExpression()
        transferUtility.downloadData(fromBucket: "petsitter1", key: filename.key!, expression: expression){(task, url, data, error) in
            if error != nil{
                print(error!)
                return
            }
            DispatchQueue.main.async(execute: {
                self.photoDelegate!.updatePhoto(image: UIImage(data: data!)!)
            })
        }
        navigationController?.popViewController(animated: true)
        return
    }
    
    func displayMessage(_ title: String,_ message: String) {
        // Setup an alert to show user details about the Person
        // UIAlertController manages an alert instance
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
