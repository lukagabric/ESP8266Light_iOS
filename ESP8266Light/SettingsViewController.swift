//
//  SettingsViewController.swift
//  ESP8266Light
//
//  Created by Luka Gabric on 06/04/16.
//  Copyright © 2016 Luka Gabric. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    //MARK: - Vars
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var httpLabel: UILabel!
    @IBOutlet weak var urlTextField: UITextField!
    
    var httpLabelText: String {
        return self.segmentedControl.selectedSegmentIndex == 0 ? "http://" : "https://"
    }
    
    //MARK: - Init/Deinit
    
    init() {
        super.init(nibName: "SettingsView", bundle: NSBundle.mainBundle())
        self.title = "Settings"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.edgesForExtendedLayout = .None
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        self.updateSegmentedControl()
        self.updateHttpLabel()
        self.updateUrlTextField()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .Default
    }

    //MARK: - Update
    
    func updateHttpLabel() {
        self.httpLabel.text = self.httpLabelText
    }
    
    func updateUrlTextField() {
        self.urlTextField.text = NSUserDefaults.standardUserDefaults().objectForKey("urlText") as? String
    }
    
    func updateSegmentedControl() {
        let useSSL = NSUserDefaults.standardUserDefaults().boolForKey("useSSL")
        self.segmentedControl.selectedSegmentIndex = useSSL ? 1 : 0
    }
    
    //MARK: - Actions
    
    @IBAction func segmentedControlValueChanged(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().setBool(self.segmentedControl.selectedSegmentIndex == 1, forKey: "useSSL")
        self.updateHttpLabel()
        self.configureBaseUrl()
    }
    
    @IBAction func urlTextFieldEditingChanged(sender: AnyObject) {
        if let url = self.urlTextField.text where !url.isEmpty {
            NSUserDefaults.standardUserDefaults().setObject(url, forKey: "urlText")
        }
        else {
            NSUserDefaults.standardUserDefaults().removeObjectForKey("urlText")
        }
        
        self.configureBaseUrl()
    }
    
    func configureBaseUrl() {
        if let urlText = (NSUserDefaults.standardUserDefaults().objectForKey("urlText") as? String) where !urlText.isEmpty {
            NSUserDefaults.standardUserDefaults().setObject("\(self.httpLabelText)\(urlText)", forKey: "baseUrl")
        }
        else {
            NSUserDefaults.standardUserDefaults().removeObjectForKey("baseUrl")
        }
    }
    
    //MARK: -
    
}
