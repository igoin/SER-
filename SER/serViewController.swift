//
//  serViewController.swift
//  SER
//
//  Created by Dongkyu Lee on 2017. 6. 12..
//  Copyright © 2017년 Dongkyu Lee. All rights reserved.
//

import UIKit

class SerViewController: UIViewController{
    
    @IBOutlet weak var emotionLabel: UILabel!
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var emotionImg: UIImageView!
    
    public static let shared2 = SerViewController()
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.homeButton.layer.cornerRadius = 10
        self.emotionLabel.layer.cornerRadius = 125
        if #available(iOS 11.0, *) {
            print(ViewController.shared.r)
        } else {
            // Fallback on earlier versions
        }
        if #available(iOS 11.0, *) {
            if (ViewController.shared.r == 0){
                emotionLabel.text = "You Are Happy"
                emotionImg.image = UIImage(named: "boy-happy-face")
            }
        } else {
            // Fallback on earlier versions
        }
        if #available(iOS 11.0, *) {
            if (ViewController.shared.r == 1){
                emotionLabel.text = "You Are Sad"
                emotionImg.image = UIImage(named: "boy-sad-face")
            }
        } else {
            // Fallback on earlier versions
        }
        if #available(iOS 11.0, *) {
            if (ViewController.shared.r == 2){
                emotionLabel.text = "You Are Angry"
                emotionImg.image = UIImage(named: "boy-angry-face")
            }
        } else {
            // Fallback on earlier versions
        }
        if #available(iOS 11.0, *) {
            if (ViewController.shared.r == 3){
                emotionLabel.text = "You Are Frustrated"
                emotionImg.image = UIImage(named: "boy-frustrated-face")
            }
        } else {
            // Fallback on earlier versions
        }
        if #available(iOS 11.0, *) {
            if (ViewController.shared.r == 4){
                emotionLabel.text = "You Are Excited"
                emotionImg.image = UIImage(named: "happy-boy-cartoon-face")
            }
        } else {
            // Fallback on earlier versions
        }
        if #available(iOS 11.0, *) {
            if (ViewController.shared.r == 5){
                emotionLabel.text = "You Are Neutral"
                emotionImg.image = UIImage(named: "boy-neutral-face")
            }
        } else {
            // Fallback on earlier versions
        }
        //emotionLabel.text = "You Are Happy"
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func close() {
        dismiss(animated: true, completion: nil)
    }
}
