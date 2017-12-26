//
//  FavoriatesViewController.swift
//  Whatsthat
//
//  Created by Jinfeng on 12/1/17.
//  Copyright © 2017 jinfeng. All rights reserved.
//

import UIKit

class FavoriatesViewController: UITableViewController {
    
    var dataSource:[FavoriateModel]?
    var selectedFavorite: FavoriateModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.title = "Favoriates"
        
        // get datasource from userdefaults
        let manager = PersistanceManager()
        dataSource = manager.fetchFavoriates()
        self.tableView.tableFooterView = UIView()
    }

    @IBAction func mapButtonEvent(_ sender: Any) {
        performSegue(withIdentifier: "mapViewSegue", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?.count ?? 0
    }
    
    // set cell, image and title, image comes from local dictory document
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriateCell") as! FavoriatesTableViewCell
        let favoriate = dataSource?[indexPath.row]
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let filename = path.appendingPathComponent((favoriate?.path)!)
        cell.descImageView.image = UIImage(contentsOfFile: filename.path)
        cell.titleLabel.text = favoriate?.title
        return cell
    }
    
    // push to wiki when use tap cell
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let favoriate = dataSource?[indexPath.row]
        self.selectedFavorite = favoriate
        self.performSegue(withIdentifier: "FavoritesPushSumSegue", sender: self)
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    // Override to support editing the table view. Delete favoriate when swipe left
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let favoriate = dataSource?[indexPath.row]
            let manager = PersistanceManager()
            manager.removeFavoriate(favoriate!.title)
            dataSource?.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FavoritesPushSumSegue" {
            // push to wiki and prepare image and title as parameters
            let summaryVC = segue.destination as! SummaryViewController
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let filename = path.appendingPathComponent(self.selectedFavorite!.path)
            summaryVC.image = UIImage(contentsOfFile: filename.path)
            summaryVC.keyword = self.selectedFavorite?.title
        }else if segue.identifier == "mapViewSegue" {
            // push to map and pass the datasource showing in the mapview
            let mapVC = segue.destination as! MapViewController
            mapVC.favoriates = self.dataSource
        }
    }
}
