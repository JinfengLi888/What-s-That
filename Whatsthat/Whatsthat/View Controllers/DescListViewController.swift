//
//  DescListViewController.swift
//  Whatsthat
//
//  Created by Jinfeng on 11/23/17.
//  Copyright © 2017 jinfeng. All rights reserved.
//

import UIKit
import MBProgressHUD

class DescListViewController: UIViewController {

    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var imageView: UIImageView!
    var passedImage:UIImage?
    var dataSource:[ImageDescModel]?
    
    var passedData: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
        
        // process search image, if not nil, we use it as parameter
        if let passedImage = self.passedImage{
            let imageDataFetch = DataFetcher()
            imageDataFetch.delegate = self
            imageDataFetch.fetchImageFromGoogleVision(with: passedImage)
        }
        
        // set search image and show progress bar when searching from google
        MBProgressHUD.showAdded(to: self.view, animated: true)
        self.myTableView.tableFooterView = UIView()
        let imageview = UIImageView.init(image: self.passedImage)
        imageview.contentMode = .scaleAspectFit
        imageview.frame = CGRect(x:0,y:0,width:UIScreen.main.bounds.width,height:200)
        self.myTableView.tableHeaderView = imageview
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // pass image and title of cell to wiki summary view controller
        if segue.identifier == "SummaryVCSegue"{
            let descVC = segue.destination as? SummaryViewController
            descVC?.keyword = passedData
            descVC?.image = self.passedImage
        }
    }
}

extension DescListViewController : UITableViewDelegate,UITableViewDataSource, DataFetcherDelegate{
   
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let dataSource = self.dataSource{
            return dataSource.count
        }
        return 0
    }
    
    // set table cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DescListCell") as! DescTableViewCell
        let descModel = dataSource?[indexPath.row]
        cell.titleLabel.text = descModel?.description
        let num = String(format: "%.0f", (descModel?.score ?? 0)*100) + "%"
        cell.ratioLabel.text = num
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let descModel = dataSource?[indexPath.row]
        passedData = descModel?.description
        performSegue(withIdentifier: "SummaryVCSegue", sender: self)
    }
    
    // MARK: - Image Data Fetch Delegate Method
    func descListFound(desc: [ImageDescModel]) {
        dataSource = desc
        DispatchQueue.main.async {
            self.myTableView.reloadData()
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    // show alert if no results
    func descListNotFound() {
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
            showMBWithText(title: "Results Not Found", view: self.view)
        }
    }
}
