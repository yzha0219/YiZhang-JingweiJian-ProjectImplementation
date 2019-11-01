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


class PhotoViewController: UIViewController, PhotoDelegate {

    var filenames: [AWSS3Object] = []
    @IBOutlet weak var photoView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let backgroundImage = UIImage.init(named: "home_page")
        let backgroundImageView = UIImageView.init(frame: self.view.frame)

        backgroundImageView.image = backgroundImage
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.alpha = 0.3

        self.view.insertSubview(backgroundImageView, at: 0)
        
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: "AKIAJDQMAQHB456GQEPQ", secretKey: "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")

        let configuration = AWSServiceConfiguration(region:.APSoutheast2, credentialsProvider:credentialsProvider)
               
        AWSServiceManager.default().defaultServiceConfiguration = configuration
              
        AWSS3.register(with: configuration!, forKey: "USWest2S3")
        let s3 = AWSS3.s3(forKey: "USWest2S3")
               
        let listRequest: AWSS3ListObjectsRequest = AWSS3ListObjectsRequest()
        listRequest.bucket = "petsitter1"
               
        s3.listObjects(listRequest).continueWith { (task) -> AnyObject? in
            self.filenames = (task.result?.contents!)!
            return nil
        }
    }
    
    func updatePhoto(image: UIImage) {
        photoView.image = image
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
    

}
