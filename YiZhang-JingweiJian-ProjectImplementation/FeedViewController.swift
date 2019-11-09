//
//  FeedViewController.swift
//  YiZhang-JingweiJian-ProjectImplementation
//
//  Created by Yi Zhang on 30/10/19.
//  Copyright © 2019 Yi Zhang. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
class FeedViewController: UIViewController {

    @IBOutlet weak var waterLabel: UILabel!
    var ref: DatabaseReference!
    let shapeLayer = CAShapeLayer()
    
    let percentageLabel: UILabel = {
        let label = UILabel()
        label.text = "Refresh"
        label.textColor = UIColor.black
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 24)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let backgroundImage = UIImage.init(named: "home_page")
        let backgroundImageView = UIImageView.init(frame: self.view.frame)

        backgroundImageView.image = backgroundImage
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.alpha = 0.3

        self.view.insertSubview(backgroundImageView, at: 0)
        ref = Database.database().reference(fromURL: "https://fit5140-ass2-963d6.firebaseio.com/").child("waterLevel")
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let current_date = formatter.string(from: date)
        view.addSubview(percentageLabel)
        percentageLabel.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        percentageLabel.center = view.center
        
        let trackLayer = CAShapeLayer()
        
        let circularPath = UIBezierPath(arcCenter: .zero, radius: 100, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        trackLayer.path = circularPath.cgPath
        
        trackLayer.strokeColor = UIColor.lightGray.cgColor
        trackLayer.lineWidth = 10
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineCap = CAShapeLayerLineCap.round
        trackLayer.position = view.center
        view.layer.addSublayer(trackLayer)
        
        shapeLayer.path = circularPath.cgPath
        
//        shapeLayer.strokeColor = UIColor.init(red: 66/255, green: 135/255, blue: 245/255, alpha: 1).cgColor
        shapeLayer.strokeColor = UIColor.init(red: 66/255, green: 135/255, blue: 245/255, alpha: 1).cgColor
        shapeLayer.lineWidth = 10
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineCap = CAShapeLayerLineCap.round
        shapeLayer.position = view.center
        
        shapeLayer.transform = CATransform3DMakeRotation(-CGFloat.pi / 2, 0, 0, 1)
        
        shapeLayer.strokeEnd = 0
        view.layer.addSublayer(shapeLayer)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        ref.child("\(current_date)").observeSingleEvent(of: .value, with: { (snapshot) in
            //print(snapshot)
            if let dict = snapshot.value as? Array<Any> {
                print(dict)
                let lastDict = dict.last as! [String:AnyObject]
                let percent = lastDict["percent"] as! Double
                self.refreshPercentage(percent: percent)
                //self.highLabel.text = String(highest)
                if(percent < 20){
                    self.waterLabel.text = "Water left: Almost finished"
                }else if(percent == 0){
                    self.waterLabel.text = "Water left: Finished"
                }else{
                    self.waterLabel.text = "Water left: Yes"
                }
            }else{
                self.refreshPercentage(percent: 200)
            }
            
        
            
        }) { (error) in
            print(error.localizedDescription)
        }
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        ref = Database.database().reference(fromURL: "https://fit5140-ass2-963d6.firebaseio.com/").child("Detect")
        ref.observe(.childChanged){ snapshot in
            appDelegate!.handleEvent()
            self.displayMessage("Detected","Pet has been detected, and the photo of it has been taken as well!")
        }
                
    }
    
    private func refreshPercentage(percent:Double) {
        let percentage = percent
        if percentage == 200{
            self.waterLabel.text = "Not working"
            self.percentageLabel.text = "0"
        }else{
            DispatchQueue.main.async {
                self.percentageLabel.text = "\(Int(percentage))%"
                self.shapeLayer.strokeEnd = CGFloat(percentage)
            }
        }
    }

    
    @objc private func handleTap() {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let current_date = formatter.string(from: date)
        ref = Database.database().reference(fromURL: "https://fit5140-ass2-963d6.firebaseio.com/").child("waterLevel")
        ref.child("\(current_date)").observeSingleEvent(of: .value, with: { (snapshot) in
            //print(snapshot)
            if let dict = snapshot.value as? Array<Any> {
                print(dict)
                let lastDict = dict.last as! [String:AnyObject]
                let percent = lastDict["percent"] as! Double
                self.refreshPercentage(percent: percent)
                //self.highLabel.text = String(highest)
                if(percent < 20){
                    self.waterLabel.text = "Water left: Almost finished"
                }else if(percent == 0){
                    self.waterLabel.text = "Water left: Finished"
                }else{
                    self.waterLabel.text = "Water left: Yes"
                }
            }else{
                self.refreshPercentage(percent: 200)
            }
            
        
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }

    @IBAction func addWater(_ sender: Any) {
        ref = Database.database().reference(fromURL: "https://fit5140-ass2-963d6.firebaseio.com/").child("detect")
        ref.child("addWater").setValue(["status": "open"])
    }
    
    func displayMessage(_ title: String,_ message: String) {
        // Setup an alert to show user details about the Person
        // UIAlertController manages an alert instance
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
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
