//
//  MeViewController.swift
//  hoBshare
//
//  Created by Felipe Lefevre Marino on 12/07/16.
//  Copyright © 2016 Felipe Lefevre Marino. All rights reserved.
//

import UIKit
import MapKit

class MeViewController: HoBshareViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    
    @IBAction func saveButtonPressed(sender: AnyObject) {
        if validate() == true {
            submit()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextField.delegate = self
    }
    
    override func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        super.locationManager(manager, didUpdateLocations: locations)
        
        latitudeLabel.text = "Latitude: " + "\(currentLocation!.coordinate.latitude)"
        longitudeLabel.text = "Longitude: " + "\(currentLocation!.coordinate.longitude)"
    }
    
    func validate() -> Bool {
        var valid = false
        if usernameTextField.text != nil && usernameTextField.text?.characters.count > 0 {
            valid = true
        }
        return valid
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if validate() == true {
            submit()
        }
        else {
            self.showError("Did you enter a username?")
        }
        return true
    }
    
    func submit() {
        usernameTextField.resignFirstResponder()
        let requestUser = User(username: usernameTextField.text!)
        requestUser.latitude = currentLocation?.coordinate.latitude
        requestUser.longitude = currentLocation?.coordinate.longitude
        
        UserDP().getAccountForUser(requestUser) { (returnedUser) in {
            if returnedUser.status.code == 0 {
                self.myHobbies = returnedUser.hobbies
                NSUserDefaults.standardUserDefaults().setValue(returnedUser.userId, forKey: "CurrentUserId")
                NSUserDefaults().synchronize()
            }
            else {
                self.showError(returnedUser.status.statusDescription!)
            }
        }
    }
}
