//
//  Constants.swift
//  Whatsthat
//
//  Created by Jinfeng on 11/24/17.
//  Copyright © 2017 jinfeng. All rights reserved.
//

import Foundation
import UIKit
import MBProgressHUD
import SystemConfiguration

// keys from google and twitter development center
let GoogleVisionAPIKey = "AIzaSyAi5BWFVh50ivqVJXf44sOEQd9Z6fT1lwc"
let TwitterAPIKey = "KHokwETUh01WBMq3JCPLlRzE9"
let TwitterAPISecret = "Si1K0b769axWYOJLld3UJFCAaq0vjstEN7OiSM0q1i67yYiWMT"

// process uiimage as search parameter
func base64EncodeImage(_ image: UIImage) -> String {
    var imagedata = UIImagePNGRepresentation(image)
    
    // Resize the image if it exceeds the 2MB API limit
    if (imagedata!.count > 2097152) {
        let oldSize: CGSize = image.size
        let newSize: CGSize = CGSize(width: 800, height: oldSize.height / oldSize.width * 800)
        imagedata = resizeImage(newSize, image: image)
    }
    
    return imagedata!.base64EncodedString(options: .endLineWithCarriageReturn)
}

func resizeImage(_ imageSize: CGSize, image: UIImage) -> Data {
    UIGraphicsBeginImageContext(imageSize)
    image.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    let resizedImage = UIImagePNGRepresentation(newImage!)
    UIGraphicsEndImageContext()
    return resizedImage!
}

// check network connecton. comes from stackoverflow
func isConnectedToNetwork() -> Bool {
    var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
    zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
    zeroAddress.sin_family = sa_family_t(AF_INET)
    
    let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
            SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
        }
    }
    
    var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
    if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
        return false
    }

    // Working for Cellular and WIFI
    let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
    let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
    let ret = (isReachable && !needsConnection)
    
    return ret
}

// alert view with any title
func showMBWithText(title:String, view: UIView ) {
    let hud = MBProgressHUD.showAdded(to: view, animated: true)
    hud.mode = MBProgressHUDMode.text;
    hud.label.text = title;
    hud.hide(animated: true, afterDelay: 2)
}

// get seconds of current time. In order to rename every image that user take. Every image name will be unique.
extension Date {
    var ticks: UInt64 {
        return UInt64((self.timeIntervalSince1970 + 62_135_596_800) * 10_000_000)
    }
}
