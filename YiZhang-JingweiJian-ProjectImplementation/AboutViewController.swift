//
//  AboutViewController.swift
//  YiZhang-JingweiJian-ProjectImplementation
//
//  Created by Yi Zhang on 30/10/19.
//  Copyright © 2019 Yi Zhang. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class AboutViewController: UIViewController {

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
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        ref = Database.database().reference(fromURL: "https://fit5140-ass2-963d6.firebaseio.com/").child("Detect")
        ref.observe(.childChanged){ snapshot in
            appDelegate!.handleEvent()
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
