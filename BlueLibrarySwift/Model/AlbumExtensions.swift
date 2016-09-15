//
//  AlbumExtensions.swift
//  BlueLibrarySwift
//
//  Created by Felipe Lefevre Marino on 9/15/16.
//  Copyright © 2016 Raywenderlich. All rights reserved.
//


extension Album {
    
    //ae notation used to diff this extension method
    func ae_tableRepresentation() -> (titles:[String], values:[String]) {
        return (["Artist", "Album", "Genre", "Year"], [artist, title, genre, year])
    }
}
