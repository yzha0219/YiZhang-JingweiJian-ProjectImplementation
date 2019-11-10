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

class PhotoViewController: UIViewController, PhotoDelegate, UIActionSheetDelegate,UIPopoverPresentationControllerDelegate {

    var filenames: [AWSS3Object] = []
    var videos: [AWSS3Object] = []
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var progressBar: UIProgressView!
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
        readFilenames2()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        ref = Database.database().reference(fromURL: "https://fit5140-ass2-963d6.firebaseio.com/")
        ref.child("Detect").observe(.childChanged){ snapshot in
            appDelegate!.handleEvent()
            self.displayMessage("Detected","Pet has been detected, and the photo of it has been taken as well!")
        }
        ref.child("detect").child("video").observe(.childChanged){ snapshot in
            if snapshot.value as! String == "close"{
                self.displayMessage("Success!", "The video has been recorded!")
                self.readFilenames2()
            }
        }
        ref.child("detectPhoto").observe(.childChanged){ snapshot in
            self.readFilenames()
            let photo = snapshot.value
            let transferUtility = AWSS3TransferUtility.default()
            let expression = AWSS3TransferUtilityDownloadExpression()
            expression.progressBlock = {(task, progress) in DispatchQueue.main.async(execute: {
                self.progressBar.progress = Float(progress.fractionCompleted)
            })}
            transferUtility.downloadData(fromBucket: "petsitter1", key: photo! as! String, expression: expression){(task, url, data, error) in
                if error != nil{
                    print(error!)
                    return
                }
                DispatchQueue.main.async(execute: {
                    self.photoView.image = UIImage(data: data!)!
                    self.displayMessage("Success!","Loading Taken Photo Completed!")
                })
            }
        }
    }
    
    //The button for switching on or off the flashlight
    @IBAction func flashSwitch(_ sender: UISwitch) {
        ref = Database.database().reference(fromURL: "https://fit5140-ass2-963d6.firebaseio.com/").child("detect")
        if sender.isOn {
            self.ref.child("led").setValue(["status": "flashing"])
        } else {
            self.ref.child("led").setValue(["status": "flashclose"])
        }
    }
    
    //Save photo to the library
    func savePhoto(){
        UIImageWriteToSavedPhotosAlbum(photoView.image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    //The button for taking photo
    @IBAction func takePhoto(_ sender: Any) {
        ref = Database.database().reference(fromURL: "https://fit5140-ass2-963d6.firebaseio.com/").child("detect")
        ref.child("photo").setValue(["status": "open"])
    }
    
    //The button for taking video
    @IBAction func takeVideo(_ sender: Any) {
        ref = Database.database().reference(fromURL: "https://fit5140-ass2-963d6.firebaseio.com/").child("detect")
        ref.child("video").setValue(["status": "open"])
    }
    
    //Longpress gesture, ask user whether to save the photo to the library
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
//        let hour = components.hour
//        let minute = components.minute
//        let second = components.second

        let today_string = String(year!) + "-" + String(month!) + "-" + String(day!)
        return today_string

    }
    
    //update the imageView
    func updatePhoto(image: UIImage) {
        photoView.image = image
    }
    
    //Alert for asking user whether save the photo to the library
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
    
    //Read all photo name in the AWSS3
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
    
    //Read all video name in the AWSS3
    func readFilenames2(){
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: "AKIAISLISPY3FEGC7PFQ", secretKey: "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")

        let configuration = AWSServiceConfiguration(region:.APSoutheast2, credentialsProvider:credentialsProvider)
               
        AWSServiceManager.default().defaultServiceConfiguration = configuration
              
        AWSS3.register(with: configuration!, forKey: "USWest2S3")
        let s3 = AWSS3.s3(forKey: "USWest2S3")
               
        let listRequest: AWSS3ListObjectsRequest = AWSS3ListObjectsRequest()
        listRequest.bucket = "petsitter2"
               
        s3.listObjects(listRequest).continueWith { (task) -> AnyObject? in
            //print(task.error)
            self.videos = (task.result?.contents!)!
            return nil
        }
    }
    
    //Display the navigation bar in the popover table view
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.fullScreen
    }

    //Display the navigation bar in the popover table view
    func presentationController(_ controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        return UINavigationController(rootViewController: controller.presentedViewController)
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
            let popPC = destination.popoverPresentationController
            popPC?.delegate = self
        } else if segue.identifier == "videoSegue"{
            let destination = segue.destination as! VideoTableViewController
            destination.videos = videos
            let popPC = destination.popoverPresentationController
            popPC?.delegate = self
        }
    }
    
    //Pop up customized message
    func displayMessage(_ title: String,_ message: String) {
        // Setup an alert to show user details about the Person
        // UIAlertController manages an alert instance
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    

}
