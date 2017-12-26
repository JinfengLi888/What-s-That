//
//  SummaryViewController.swift
//  Whatsthat
//
//  Created by Jinfeng on 11/26/17.
//  Copyright © 2017 jinfeng. All rights reserved.
//

import UIKit
import MBProgressHUD
import SafariServices
import TwitterKit

class SummaryViewController: UIViewController {

    @IBOutlet weak var myTextView: UITextView!
    var keyword:String?
    var image:UIImage?
    var summary: SummaryModel?
    
    var isSaved: Bool = false
    
    let locationFinder = LocationFinder()
    var latitude: Double = 0
    var longitude: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationItem.title = keyword
        
        // fetch data from wiki api
        let dataFetcher = DataFetcher()
        dataFetcher.fetchSummaryFromWiki(with: keyword!)
        dataFetcher.delegate = self
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        // get user's location
        locationFinder.delegate = self
        locationFinder.findLocation()
        
        // check the title if already saved in userdefault
        let manager = PersistanceManager()
        if manager.checkExists(keyword!) {
            self.navigationItem.rightBarButtonItem?.image = UIImage.init(named: "favoriated")
            self.isSaved = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // push into wiki web
    @IBAction func wikiButtonEvent(_ sender: Any) {
        let pageid = self.summary?.pageid.stringValue ?? ""
        if let url = URL(string: "https://en.wikipedia.org/?curid="+pageid) {
            let vc = SFSafariViewController.init(url: url)
            present(vc, animated: true)
        }
    }
    
    // push to tweets
    @IBAction func tweetButtonEvent(_ sender: Any) {
        let dataSource = TWTRSearchTimelineDataSource(searchQuery: "\(self.keyword ?? "")", apiClient: TWTRAPIClient())
        dataSource.resultType = "popular"
        let twitterVC = TWTRTimelineViewController(dataSource: dataSource)
        twitterVC.showTweetActions = true
        twitterVC.navigationItem.title = self.keyword
        self.navigationController?.pushViewController(twitterVC, animated: true)
    }
    
    // share content throught avivitiy vc
    @IBAction func shareButtonEvent(_ sender: Any) {
        let title = self.keyword ?? ""
        let pageid = self.summary?.pageid.stringValue ?? ""
        let urlToShare = URL(string: "https://en.wikipedia.org/?curid="+pageid)
        let activity = UIActivityViewController.init(activityItems: [title, urlToShare], applicationActivities: nil)
        present(activity, animated: true, completion: nil)
    }
    
    // favoriate button. If already favoriated, then unFavoriated it. If no favoriate, then favoriate it.
    @IBAction func favoriateEvent(_ sender: Any) {
        if self.isSaved {
            // unfavoriate
            let manager = PersistanceManager()
            manager.removeFavoriate(self.keyword!)
            self.navigationItem.rightBarButtonItem?.image = UIImage(named: "favoriate")
            showMBWithText(title: "Removed from Favoriates!", view: self.view)
            self.isSaved = false
        } else {
            // favoriate
            let imageData = UIImagePNGRepresentation(self.image!)
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let ticks = Date().ticks;
            let imagename = "\(ticks).png"
            let filename = path.appendingPathComponent(imagename)
            try? imageData?.write(to: filename)
            let favoriate = FavoriateModel(title: self.keyword!,
                                           path: imagename,
                                           latitude: NSString(format: "%lf", self.latitude),
                                           longitude: NSString(format: "%lf", self.longitude))
            let manager = PersistanceManager()
            manager.saveFavoriate(favoriate)
            self.navigationItem.rightBarButtonItem?.image = UIImage(named: "favoriated")
            self.isSaved = true
            showMBWithText(title: "Added to Favoriates!", view: self.view)
        }
    }
}

// get user's location in order to favoriate
extension SummaryViewController: LocationFinderDelegate {
    func locationFound(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
        MBProgressHUD.hide(for: self.view, animated: true)
    }
    
    func locationNotFound(reason: LocationFinder.FailureReason) {
        DispatchQueue.main.async {
            showMBWithText(title: reason.rawValue, view: self.view)
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
}

// show wiki results as html 
extension SummaryViewController: DataFetcherDelegate{
    // MARK: Data Fetcher Delegate methods
    func summaryFound(summary: SummaryModel) {
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
            let htmlString = "<html>" +
                "<head>" +
                "<style>" +
                "body {" +
                "background-color: rgb(230, 230, 230);" +
                "font-family: 'Arial';" +
                "text-decoration:none;" +
                "}" +
                "</style>" +
                "</head>" +
                "<body>" +
                summary.content +
            "</body></head></html>"
            
            let htmlData = NSString(string: htmlString).data(using: String.Encoding.unicode.rawValue)
            let options = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html]
            let attributedString = try! NSAttributedString(data: htmlData!, options: options, documentAttributes: nil)
            self.myTextView.attributedText = attributedString
            self.summary = summary
        }
    }
    
    func summaryNotFound() {
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
            showMBWithText(title: "Results Not Found", view: self.view)
        }
    }
}
