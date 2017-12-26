//
//  MapViewController.swift
//  Whatsthat
//
//  Created by Jinfeng on 12/12/17.
//  Copyright © 2017 jinfeng. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    var favoriates: [FavoriateModel]?
    let locationFinder = LocationFinder()
    var selectedFavorite: FavoriateModel?
    let radius: CLLocationDistance = 700
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Favoriates"
        // Do any additional setup after loading the view.
        locationFinder.delegate = self
        locationFinder.findLocation()
        self.mapView.showsUserLocation = true
        
        // create pins and show them in mapview. Every favoriate model show as one pin.
        if let items = favoriates, items.count > 0 {
            for item in items {
                if item.latitude.doubleValue != 0 && item.longitude.doubleValue != 0{
                    let pin = MKPointAnnotation()
                    pin.coordinate = CLLocationCoordinate2D(latitude: (item.latitude.doubleValue), longitude: (item.longitude.doubleValue))
                    pin.title = item.title
                    mapView.addAnnotation(pin)
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        // push to wiki when user tap pin
        if segue.identifier == "mapPushtoWikiSegue" {
            let summaryVC = segue.destination as! SummaryViewController
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            if let favorate = self.selectedFavorite {
                let filename = path.appendingPathComponent(favorate.path)
                summaryVC.image = UIImage(contentsOfFile: filename.path)
                summaryVC.keyword = favorate.title
            }
        }
    }
}

extension MapViewController : MKMapViewDelegate {
    // find the pin which user tapped
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let pin = view.annotation
        for item in self.favoriates! {
            if item.title == (pin?.title)! {
                self.selectedFavorite = item
                break
            }
        }
        performSegue(withIdentifier: "mapPushtoWikiSegue", sender: self)
    }
}

// set region as user's current location. If not found, we use the pin's locaiton as region
extension MapViewController : LocationFinderDelegate {
    func locationFound(latitude: Double, longitude: Double) {
        let locaiton = CLLocation(latitude:latitude,longitude:longitude)
        let region = MKCoordinateRegionMakeWithDistance(locaiton.coordinate, radius, radius)
        self.mapView.setRegion(region, animated: true)
    }
    
    func locationNotFound(reason: LocationFinder.FailureReason) {
        let favoriate = self.favoriates!.first
        let locaiton = CLLocation(latitude:(favoriate?.latitude.doubleValue)!,
                                  longitude:(favoriate?.longitude.doubleValue)!)
        let region = MKCoordinateRegionMakeWithDistance(locaiton.coordinate, radius, radius)
        self.mapView.setRegion(region, animated: true)
    }
    
}
