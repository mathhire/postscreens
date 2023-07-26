//
//  MapVC.swift
//  Posters
//
//  Created by Administrator on 2/27/23.
//

import UIKit
import GooglePlaces
import GoogleMaps
//import CoreLocation
import SVProgressHUD

class MapVC: UIViewController,GMSMapViewDelegate {
    @IBOutlet weak var mapView: GMSMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        if DataManager.shared.loggedInUser().lat != "" && Double(DataManager.shared.loggedInUser().lat) != 0.0{
            self.showMap(Double(DataManager.shared.loggedInUser().lat) ?? 0.0, Double(DataManager.shared.loggedInUser().lng) ?? 0.0)
        }
        else{
            self.showMap(40.7306, -73.9352)
        }
        // Do any additional setup after loading the view.
    }
    func showMap(_ lat:Double,_ long:Double){
        mapView.delegate = self
        mapView.clear()
        mapView.isMyLocationEnabled = true
        // Creates a marker in the center of the map.
        for index in 0 ..< universitiesArray.count{
            let oneUniversity = universitiesArray[index]
            if let univLat = Double(oneUniversity.ulat)
            {
                let univLng = Double(oneUniversity.ulng)
                
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D(latitude: univLat ,longitude: univLng ?? 0.0 )
                marker.title = oneUniversity.university_name
                marker.userData = oneUniversity.id
                
                marker.map = mapView
            }
        }
        
//        let bounds = GMSCoordinateBounds.init()
//        bounds.includingCoordinate(CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20))
        
        mapView.setMinZoom(1, maxZoom: 15)
        mapView.animate(to: GMSCameraPosition(latitude: lat, longitude: long, zoom: 11))
    }
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
        vc.isOpeningOtherUniversity = true
        vc.curUnivID = marker.userData as! String
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)

    }
}
