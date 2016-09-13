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
    
    private let persistenceManager: PersistencyManager
    private let httpClient: HTTPClient
    private let isOnline: Bool
    
    
    override init() {
        persistenceManager = PersistencyManager()
        httpClient = HTTPClient()
        isOnline = false
        
        super.init()
    }
    
    func getAlbums() -> [Album] {
        return persistenceManager.getAlbums()
    }
    
    func addAlbum(album: Album, index: Int) {
        persistenceManager.addAlbum(album, index: index)
        if isOnline {
            httpClient.postRequest("/api/deleteAlbum", body: "\(index)")
        }
    }
    
    func deleteAlbum(index: Int) {
        persistenceManager.deleteAlbumAtIndex(index)
        if isOnline {
            httpClient.postRequest("/api/deleteAlbum", body: "\(index)")
        }
    }
    
}
