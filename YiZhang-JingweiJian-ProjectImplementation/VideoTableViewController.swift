//
//  VideoTableViewController.swift
//  YiZhang-JingweiJian-ProjectImplementation
//
//  Created by Yi Zhang on 10/11/19.
//  Copyright © 2019 Yi Zhang. All rights reserved.
//

import UIKit
import AWSCore
import AWSCognito
import AWSS3
import Firebase
import FirebaseDatabase
import AVKit
import AVFoundation

class VideoTableViewController: UITableViewController,UISearchResultsUpdating {

    var ref: DatabaseReference!
    var videos: [AWSS3Object] = []
    var filterVideos: [AWSS3Object] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchController = UISearchController(searchResultsController: nil);
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "By Date&Time \"XXXX-XX-XX XX:XX:XX\""
        navigationItem.searchController = searchController
        filterVideos = videos
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return filterVideos.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let videoCell = tableView.dequeueReusableCell(withIdentifier: "videoCell", for: indexPath) as! VideoTableViewCell

        // Configure the cell...

        let video = filterVideos[indexPath.row].key!.split(separator: " ")
        print(video)
        let date = video[0]
        let time = video[1]
        videoCell.dateLabel.text = String(date)
        videoCell.timeLabel.text = time.replacingOccurrences(of: ".mp4", with: "")
        return videoCell
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, searchText.count > 0 {
            filterVideos = videos.filter({(video: AWSS3Object) -> Bool in
                return video.key!.contains(searchText)
            })
        }
        else {
            filterVideos = videos
        }
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let videoName = filterVideos[indexPath.row].key!
        let videoURL = URL(string: "https://petsitter2.s3-ap-southeast-2.amazonaws.com/\(decodePath(videoName: videoName))")
        let player = AVPlayer(url: videoURL!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
    
    //Convert special characters in the path
    func decodePath(videoName: String) -> String {
        let newPath1 = videoName.replacingOccurrences(of: " ", with: "+")
        let newPath2 = newPath1.replacingOccurrences(of: ":", with: "%3A")
        return newPath2
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
        if segue.identifier == "avSegue"{
            let destination = segue.destination as! aVPlayerViewController
            let videoName = filterVideos[tableView.indexPathForSelectedRow!.row].key!
            destination.videoName = videoName
        }
    }
    */
    

}
