//
//  CPLocationVC.swift
//  Posters
//
//  Created by Administrator on 2/28/23.
//

import UIKit
import CoreLocation

class CPLocationVC: UIViewController {
    var latitude = 0.0
    var longitude = 0.0
    var locationManager : CLLocationManager?
    var permissionAquired = false
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func enableLocationBtnTapped(_ sender: Any) {
//        if CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse{
//            permissionAquired = true
//            enableLocationBtnTapped("")
//        }else{
//            permissionAquired = false
//        }
        if CLLocationManager.authorizationStatus() == .denied{
            openSetting()
            return
        }
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        //locationManager?.requestAlwaysAuthorization()
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.startUpdatingLocation()

        
    }
    func openSetting(){
        let alert = UIAlertController(title: nil, message: "To use your location you need to grant Posters access to your location in Settings", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Go to Settings", style: .default){_ in
            guard let settingUrl = URL(string: UIApplication.openSettingsURLString) else{return}
            UIApplication.shared.open(settingUrl)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    @IBAction func skipBtnTapped(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CPGradeVC") as! CPGradeVC
        self.navigationController?.pushViewController(vc, animated: true)

    }
    
}
extension CPLocationVC : CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse{
            permissionAquired = true
        }else{
            permissionAquired = false
            if status == .denied{
                openSetting()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else{
            return
        }
        currentLocation = location
        regLat = currentLocation?.coordinate.latitude ?? 0.0
        regLng = currentLocation?.coordinate.longitude ?? 0.0
        manager.stopUpdatingLocation()
        if(openingGradeScreen == false)
        {
            openingGradeScreen = true
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "CPGradeVC") as! CPGradeVC
            self.navigationController?.pushViewController(vc, animated: true)
        }

    }
}
