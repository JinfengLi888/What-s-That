//
//  PersistanceManager.swift
//  Whatsthat
//
//  Created by Jinfeng on 12/1/17.
//  Copyright © 2017 jinfeng. All rights reserved.
//

import Foundation

class PersistanceManager{
    static let sharedInstance = PersistanceManager()
    
    let favoriateKey = "favoriateKey"
    
    // get user's all favoriates
    func fetchFavoriates() -> [FavoriateModel]{
        let userDefaults = UserDefaults.standard
        let data = userDefaults.object(forKey: favoriateKey) as? Data
        if let data = data {
            //data is not nil, so use it
            return NSKeyedUnarchiver.unarchiveObject(with: data) as? [FavoriateModel] ?? [FavoriateModel]()
        }
        else {
            //data is nil
            return [FavoriateModel]()
        }
    }
    
    // remove a favoriate according to the title
    func removeFavoriate(_ title: String){
        let userDefaults = UserDefaults.standard
        var favoriates = fetchFavoriates()
        for i in 0..<favoriates.count {
            if(favoriates[i] as FavoriateModel).title == title{
                // remove the corresponible image at dictory document
                let fileManager = FileManager.default
                let path = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let filename = path.appendingPathComponent(favoriates[i].path)
                if fileManager.fileExists(atPath: filename.path) {
                    do {
                        try fileManager.removeItem(at: filename)
                    }catch let error as NSError {
                        print(error.debugDescription)
                    }
                }
                favoriates.remove(at: i)
                
                break
            }
        }
        let data = NSKeyedArchiver.archivedData(withRootObject: favoriates)
        userDefaults.set(data, forKey: favoriateKey)
        userDefaults.synchronize()
    }
    
    // save one favoriate with model
    func saveFavoriate(_ favoriateModel: FavoriateModel){
        let userDefaults = UserDefaults.standard
        var favoriates = fetchFavoriates()
        favoriates.append(favoriateModel)
        let data = NSKeyedArchiver.archivedData(withRootObject: favoriates)
        userDefaults.set(data, forKey: favoriateKey)
        userDefaults.synchronize()
    }
    
    // check one title if already in user defaults.
    func checkExists(_ title: String) -> Bool {
        let favoriates = fetchFavoriates()
        for item in favoriates {
            if (item as FavoriateModel).title == title {
                return true
            }
        }
        return false
    }
    
}
