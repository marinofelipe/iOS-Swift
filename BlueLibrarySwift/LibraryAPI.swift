//
//  LibraryAPI.swift
//  BlueLibrarySwift
//
//  Created by Felipe Lefevre Marino on 9/9/16.
//  Copyright © 2016 Raywenderlich. All rights reserved.
//

import UIKit

class LibraryAPI: NSObject {
    
    class var sharedInstance: LibraryAPI {
        
        struct Singleton {
            
            static let instance = LibraryAPI()
        }
        
        return Singleton.instance
    }
}
