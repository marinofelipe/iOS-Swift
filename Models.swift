//
//  Models.swift
//  hoBshare
//
//  Created by Felipe Lefevre Marino on 16/07/16.
//  Copyright © 2016 Felipe Lefevre Marino. All rights reserved.
//

import Foundation
import MapKit

class User: SFLBaseModel {
    var username: String?
    var latitude: CLLocationDegrees?
    var longitude: CLLocationDegrees?
    
    init(username: String!) {
        super.init()
        self.username = username
    }
}

class ListOfUsers: SFLBaseModel {

}

class Hobby: SFLBaseModel {
    
    var hobbyName:String?
    
    init(hobbyName: String!) {
        super.init()
        self.hobbyName = hobbyName
    }
}


