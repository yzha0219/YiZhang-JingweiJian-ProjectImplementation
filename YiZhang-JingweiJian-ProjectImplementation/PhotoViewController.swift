//
//  PhotoViewController.swift
//  YiZhang-JingweiJian-ProjectImplementation
//
//  Created by Yi Zhang on 30/10/19.
//  Copyright © 2019 Yi Zhang. All rights reserved.
//

import UIKit
import AWSCore
import AWSCognito
import AWSS3
import Firebase
import FirebaseDatabase

class PhotoViewController: UIViewController, PhotoDelegate, UIActionSheetDelegate {

    var filenames: [AWSS3Object] = []
    @IBOutlet weak var photoView: UIImageView!
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let backgroundImage = UIImage.init(named: "home_page")
        let backgroundImageView = UIImageView.init(frame: self.view.frame)

        backgroundImageView.image = backgroundImage
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.alpha = 0.3

        self.view.insertSubview(backgroundImageView, at: 0)
        
        readFilenames()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        ref = Database.database().reference(fromURL: "https://fit5140-ass2-963d6.firebaseio.com/").child("Detect")
        ref.observe(.childChanged){ snapshot in
            appDelegate!.handleEvent()
            self.readFilenames()
            let photo = snapshot.value as! NSDictionary
            let transferUtility = AWSS3TransferUtility.default()
            let expression = AWSS3TransferUtilityDownloadExpression()
            transferUtility.downloadData(fromBucket: "petsitter1", key: photo["filename"] as! String, expression: expression){(task, url, data, error) in
                if error != nil{
                    print(error!)
                    return
                }
                DispatchQueue.main.async(execute: {
                    self.photoView.image = UIImage(data: data!)!
                })
            }
        }
    }
    
    @IBAction func flashSwitch(_ sender: UISwitch) {
        ref = Database.database().reference(fromURL: "https://fit5140-ass2-963d6.firebaseio.com/").child("detect")
        if sender.isOn {
            self.ref.child("led").setValue(["status": "flashing"])
        } else {
            self.ref.child("led").setValue(["status": "flashclose"])
        }
    }
    
    func savePhoto(){
        UIImageWriteToSavedPhotosAlbum(photoView.image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @IBAction func takePhoto(_ sender: Any) {
        ref = Database.database().reference(fromURL: "https://fit5140-ass2-963d6.firebaseio.com/").child("detect")
        ref.child("photo").setValue(["status": "open"])
    }
    
    @IBAction func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began{
            let alert = UIAlertController()
            alert.addAction(UIAlertAction(title: "Save Photo", style: .default){(action: UIAlertAction!) in
                self.savePhoto()
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func getRandomNumber() -> Int{
        return Int.random(in: 0..<1000000000)
    }
    
    func getTodayString() -> String{

        let date = Date()
        let calender = Calendar.current
        let components = calender.dateComponents([.year,.month,.day,.hour,.minute,.second], from: date)

        let year = components.year
        let month = components.month
        let day = components.day
        let hour = components.hour
        let minute = components.minute
        let second = components.second

        let today_string = String(year!) + "-" + String(month!) + "-" + String(day!) + " " + String(hour!)  + ":" + String(minute!) + ":" +  String(second!)

        return today_string

    }
    
    func updatePhoto(image: UIImage) {
        photoView.image = image
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer){
        if let error = error {
            let ac = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
        } else {
            let ac = UIAlertController(title: "Photo has been saved!", message: error?.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    func readFilenames(){
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: "AKIAISLISPY3FEGC7PFQ", secretKey: "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")

        let configuration = AWSServiceConfiguration(region:.APSoutheast2, credentialsProvider:credentialsProvider)
               
        AWSServiceManager.default().defaultServiceConfiguration = configuration
              
        AWSS3.register(with: configuration!, forKey: "USWest2S3")
        let s3 = AWSS3.s3(forKey: "USWest2S3")
               
        let listRequest: AWSS3ListObjectsRequest = AWSS3ListObjectsRequest()
        listRequest.bucket = "petsitter1"
               
        s3.listObjects(listRequest).continueWith { (task) -> AnyObject? in
            //print(task.error)
            self.filenames = (task.result?.contents!)!
            return nil
        }
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "photoList" {
            let destination = segue.destination as! PhotoTableViewController
            destination.filenames = filenames
            destination.photoDelegate = self
        }
    }
    
    func displayMessage(_ title: String,_ message: String) {
        // Setup an alert to show user details about the Person
        // UIAlertController manages an alert instance
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    

}
