//
//  DataFetcher.swift
//  Whatsthat
//  Network request class
//  Created by Jinfeng on 11/24/17.
//  Copyright © 2017 jinfeng. All rights reserved.
//

import Foundation
import UIKit

protocol DataFetcherDelegate {
    func descListFound(desc: [ImageDescModel])
    func descListNotFound()
    
    func summaryFound(summary: SummaryModel)
    func summaryNotFound()
}

class DataFetcher{
    var delegate: DataFetcherDelegate?
    
    func fetchImageFromGoogleVision(with image: UIImage){
        let googleURL = URL(string: "https://vision.googleapis.com/v1/images:annotate?key=\(GoogleVisionAPIKey)")!
        let binaryImageData = base64EncodeImage(image)
        var request = URLRequest(url: googleURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(Bundle.main.bundleIdentifier ?? "", forHTTPHeaderField: "X-Ios-Bundle-Identifier")
        
        // Build our API request
        let jsonRequest = [
            "requests": [
                "image": [
                    "content": binaryImageData
                ],
                "features": [
                    [
                        "type": "LABEL_DETECTION",
                        "maxResults": 10
                    ]
                ]
            ]
        ]
        do{
            let jsonObject = try JSONSerialization.data(withJSONObject: jsonRequest, options: JSONSerialization.WritingOptions.prettyPrinted)
            request.httpBody = jsonObject
        }catch{
            print(error.localizedDescription)
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            //check for valid response with 200 (success)
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                self.delegate?.descListNotFound()
                
                return
            }
            guard let data = data else {
                self.delegate?.descListNotFound()
                
                return
            }
            
            // use codeable to parsing json data from google vison api
            let decoder = JSONDecoder()
            let decodedRoot = try? decoder.decode(Root.self, from: data)
            
            //ensure json structure matches our expections and contains a venues array
            guard let root = decodedRoot else {
                self.delegate?.descListNotFound()
                
                return
            }
            
            let labels = root.responses.first?.labelAnnotations
            
            guard let results = labels, results.count>0 else {
                self.delegate?.descListNotFound()
                
                return
            }
            
            // prepare return results list
            var descList = [ImageDescModel]()
            for item in results {
                let desc = ImageDescModel(description: item.description, score: item.score)
                descList.append(desc)
            }
            
            self.delegate?.descListFound(desc: descList)
        }
        task.resume()
    }
    
    // wiki network request
    func fetchSummaryFromWiki(with title: String){
        
        // set parameters
        var urlComponents = URLComponents(string: "https://en.wikipedia.org/w/api.php")!
        urlComponents.queryItems = [URLQueryItem(name: "format", value: "json"),
                                    URLQueryItem(name: "action", value: "query"),
                                    URLQueryItem(name: "prop", value: "extracts"),
                                    URLQueryItem(name: "titles", value: "\(title)"),]
        let url = urlComponents.url!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                self.delegate?.summaryNotFound()
                
                return
            }
            
            //ensure data is non-nil
            guard let data = data, let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] ?? [String:Any]() else {
                self.delegate?.summaryNotFound()
                
                return
            }
            
            //, let results = dictResponse[0] as? [[String:Any]]
            guard let dictResponse = jsonResponse["query"] as? [String: Any] else {
                self.delegate?.summaryNotFound()
                
                return
            }
            // parsing json
            guard let pagesAnnotations = dictResponse["pages"] as? [String:Any], pagesAnnotations.count>0  else {
                self.delegate?.summaryNotFound()
                
                return
            }
            var summaryDict = [String: Any]()
            for (_, value) in pagesAnnotations {
                guard let value = value as? [String:Any] else{
                    self.delegate?.summaryNotFound()
                    
                    return
                }
                summaryDict = value
                break
            }
            
            guard let extractAnnotations = summaryDict["extract"] as? String,let pageidAnnotations = summaryDict["pageid"] as? NSNumber else {
                self.delegate?.summaryNotFound()
                
                return
            }
            let summary = SummaryModel(content: extractAnnotations, pageid: pageidAnnotations)
            self.delegate?.summaryFound(summary: summary)
            
        }
        
        task.resume()
    }

}

// make delegate methods as optional implement
extension DataFetcherDelegate {
    func descListFound(desc: [ImageDescModel]){}
    func descListNotFound(){}
    
    func summaryFound(summary: SummaryModel){}
    func summaryNotFound(){}
}


