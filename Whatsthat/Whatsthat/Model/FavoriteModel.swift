//
//  FavoriteModel.swift
//  Whatsthat
//
//  Created by Jinfeng on 12/1/17.
//  Copyright © 2017 jinfeng. All rights reserved.
//

import Foundation
// favoriate model. Title: the words from google. Path: image path in local dictory doc. Lat, Long: user's locaiton
class FavoriateModel: NSObject {
    let title: String
    let path: String // image path in local
    let latitude: NSString
    let longitude: NSString
    
    let titleKey = "title"
    let pathKey = "path"
    let latitudeKey = "latitude"
    let longitudeKey = "longitude"
    
    init(title: String, path: String, latitude: NSString, longitude: NSString) {
        self.title = title
        self.path = path
        self.latitude = latitude
        self.longitude = longitude
    }
    
    required init?(coder aDecoder: NSCoder) {
        title = aDecoder.decodeObject(forKey: titleKey) as! String
        path = aDecoder.decodeObject(forKey: pathKey) as! String
        latitude = aDecoder.decodeObject(forKey: latitudeKey) as! NSString
        longitude = aDecoder.decodeObject(forKey: longitudeKey) as! NSString
    }
}

extension FavoriateModel: NSCoding {
    func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: titleKey)
        aCoder.encode(path, forKey: pathKey)
        aCoder.encode(latitude, forKey: latitudeKey)
        aCoder.encode(longitude, forKey: longitudeKey)
    }
}
