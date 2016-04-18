//
//  ViewController.swift
//  ESP8266Light
//
//  Created by Luka Gabric on 02/04/16.
//  Copyright © 2016 Luka Gabric. All rights reserved.
//

import UIKit

class LightViewController: UIViewController {
    
    //MARK: - Vars
    
    @IBOutlet weak var lightImageView: UIImageView!
    @IBOutlet weak var activityView: UIView!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var configureInfoView: UIView!
    
    var lightOn: Bool?
    var error: NSError?

    var fetchStatusInProgress = false
    var toggleLightInProgress = false
    
    var baseUrl: NSURL? {
        guard let baseUrlString = NSUserDefaults.standardUserDefaults().stringForKey("baseUrl") else { return nil }
        return NSURL(string: baseUrlString)
    }

    var notificationCenter: NSNotificationCenter {
        return NSNotificationCenter.defaultCenter()
    }
    
    //MARK: - Init/Deinit
    
    init() {
        super.init(nibName: "LightView", bundle: NSBundle.mainBundle())
        
        self.notificationCenter.addObserver(self, selector: #selector(LightViewController.applicationWillEnterForeground), name: UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        self.notificationCenter.removeObserver(self)
    }
    
    //MARK: - Notification Center
    
    func applicationWillEnterForeground() {
        if self.fetchStatusInProgress || self.toggleLightInProgress { return }
        
        self.fetchStatus()
    }
    
    //MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateOverlayViews()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.updateOverlayViews()

        if self.lightOn != nil || self.fetchStatusInProgress || self.toggleLightInProgress { return }
        
        self.fetchStatus()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    //MARK: - Update
    
    func updateOverlayViews() {
        self.configureInfoView.hidden = true
        self.lightImageView.hidden = true
        self.activityView.hidden = true
        self.errorView.hidden = true
        self.spinner.stopAnimating()
        
        if self.baseUrl == nil {
            self.configureInfoView.hidden = false
        }
        else if self.error != nil {
            self.errorView.hidden = false
        }
        else if self.fetchStatusInProgress {
            self.activityView.hidden = false
        }
        else if self.lightOn != nil {
            if self.toggleLightInProgress {
                self.spinner.startAnimating()
            }
            self.lightImageView.hidden = false
        }
    }

    func updateLightImageView() {
        guard let lightOn = self.lightOn else { return }
        
        let imageName = lightOn ? "light_on" : "light_off"
        let image = UIImage(named: imageName)
        self.lightImageView.image = image
    }
    
    //MARK: - Actions
    
    @IBAction func configureAction(sender: AnyObject) {
        self.navigationController?.pushViewController(SettingsViewController(), animated: true)
    }
    
    @IBAction func lightImageViewTapAction(sender: AnyObject) {
        self.toggleLightState()
    }
    
    @IBAction func errorViewTapAction(sender: AnyObject) {
        self.fetchStatus()
    }
    
    func toggleLightState() {
        guard let
            lightOn = self.lightOn,
            request = self.createRequest(path: "light/\(lightOn ? "off" : "on")")
            else { return }
        
        let dataTask = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            dispatch_async(dispatch_get_main_queue(), {
                self.toggleLightInProgress = false
                self.error = error
                self.updateOverlayViews()
                self.lightImageView.userInteractionEnabled = true
            })
        }
        
        dataTask.resume()
        
        self.lightOn = !lightOn
        self.updateLightImageView()
        
        self.toggleLightInProgress = true
        self.error = nil
        self.updateOverlayViews()
        
        self.lightImageView.userInteractionEnabled = false
    }
    
    func fetchStatus() {
        guard let request = self.createRequest(path: "light/status") else { return }
        
        let dataTask = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            dispatch_async(dispatch_get_main_queue(), {
                self.fetchStatusInProgress = false
                
                if let
                    responseData = data,
                    jsonDict = (try? NSJSONSerialization.JSONObjectWithData(responseData, options: NSJSONReadingOptions(rawValue: 0))) as? NSDictionary,
                    lightOn = jsonDict["lightOn"] as? Bool
                    where error == nil {
                    self.lightOn = lightOn
                }
                else {
                    self.error = error ?? NSError(domain: "Unknown error", code: 0, userInfo: nil)
                }
                
                self.updateLightImageView()
                self.updateOverlayViews()
            })
        }
        
        dataTask.resume()
        
        self.error = nil
        self.fetchStatusInProgress = true
        self.updateOverlayViews()
    }
    
    //MARK: - Convenience
    
    func createRequest(path path: String) -> NSURLRequest? {
        guard let url = self.baseUrl?.URLByAppendingPathComponent(path) else { return nil }
        
        return NSURLRequest(URL: url, cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 3)
    }
    
    //MARK: -

}
