//
//  ViewController.swift
//  ESP8266Light
//
//  Created by Luka Gabric on 02/04/16.
//  Copyright © 2016 Luka Gabric. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var bulbImageView: UIImageView!
    var bulbOn = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.updateBulbImageView()
    }

    func updateBulbImageView() {
        let imageName = self.bulbOn ? "bulb_on" : "bulb_off"
        let image = UIImage(named: imageName)
        self.bulbImageView.image = image
    }
    
    @IBAction func imageViewTapAction(sender: AnyObject) {
        self.toggleBulbState()
    }
    
    func toggleBulbState() {
        self.bulbImageView.userInteractionEnabled = false
        
        let endpointUrl = "http://192.168.0.12:8081/light/\(self.bulbOn ? "off" : "on")"
        let url = NSURL(string: endpointUrl)!
        let request = NSURLRequest(URL: url, cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 3)
        let dataTask = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            dispatch_async(dispatch_get_main_queue(), { 
                if error == nil {
                    self.bulbOn = !self.bulbOn
                    self.updateBulbImageView()
                }
                else {
                    print(error)
                }
                
                self.bulbImageView.userInteractionEnabled = true
            })
        }
        
        dataTask.resume()
    }

}

