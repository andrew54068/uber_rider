//
//  RiderVC.swift
//  uber rider
//
//  Created by kidnapper on 24/09/2017.
//  Copyright © 2017 kidnapper.com. All rights reserved.
//

import UIKit
import MapKit

class RiderVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UberController {

    
    @IBOutlet var callUberBtn: UIButton!
    @IBOutlet var myMap: MKMapView!
    
    private var locationManager = CLLocationManager()
    private var userLocation: CLLocationCoordinate2D?
    private var driverLocation: CLLocationCoordinate2D?
    
    private var canCallUber = true
    private var riderCanceledRequest = false
    
    private var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeLocationManager()
        UberHandler.Instance.delegate = self
        UberHandler.Instance.observeMessageForRider()

        // Do any additional setup after loading the view.
    }
    
    private func initializeLocationManager(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locationManager.location?.coordinate{
            userLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            
            let region = MKCoordinateRegion(center: userLocation!, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            myMap.setRegion(region, animated: true)
            
            myMap.removeAnnotations(myMap.annotations)
            if driverLocation != nil{
                if !canCallUber{
                    let driverAnnotation = MKPointAnnotation()
                    driverAnnotation.title = "Drivers Location"
                    driverAnnotation.coordinate = driverLocation!
                    myMap.addAnnotation(driverAnnotation)
                }
            }
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = userLocation!
            annotation.title = "Rider Location"
            myMap.addAnnotation(annotation)
        }
    }
    
    @objc func updateRiderLocation(){
        UberHandler.Instance.updateRiderLocation(lat: userLocation!.latitude, long: userLocation!.longitude)
    }
    
    func canCallUber(delegateCalled: Bool) {
        if delegateCalled{
            callUberBtn.setTitle("cancel uber", for: UIControlState.normal)
            canCallUber = false
        }else{
            callUberBtn.setTitle("call uber", for: UIControlState.normal)
            canCallUber = true
            timer.invalidate()
        }
    }
    func driverAcceptedRequest(requestAccepted: Bool, driverName: String) {
        if !riderCanceledRequest{
            if requestAccepted{
                self.alerTheUser(title: "Uber Accepted", message: "\(driverName) Accepted Your Uber Request")
            }else{
//                UberHandler.Instance.cancelUber()
                self.alerTheUser(title: "Uber Canceled", message: "\(driverName) Canceled Uber Request")
                self.driverLocation = nil
//                self.canCallUber = true
            }
        }
        riderCanceledRequest = false
    }
    
    
    @IBAction func callUber(_ sender: Any) {
        if userLocation != nil{
            if canCallUber{
                //can call but not call yet
                riderCanceledRequest = false
                UberHandler.Instance.requestUber(latitude:
                    Double((userLocation?.latitude)!), longitude: Double((userLocation?.longitude)!))
                timer = Timer.scheduledTimer(timeInterval: TimeInterval(10), target: self, selector: #selector(RiderVC.updateRiderLocation), userInfo: nil, repeats: true)
            }else{
                //already called
                riderCanceledRequest = true
                UberHandler.Instance.cancelUber()
                self.driverLocation = nil
            }
        }
    }
    
    @IBAction func logout(_ sender: Any) {
        if AuthProvider.Instance.logout(){
            
            if !canCallUber{
                UberHandler.Instance.cancelUber()
                timer.invalidate()
            }
            dismiss(animated: true, completion: nil)
        }else{
            self.alerTheUser(title: "Could Not Logout", message: "Please Try Again Later")
        }
    }
    private func alerTheUser(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        if self.presentedViewController == nil{
            present(alert, animated: true, completion: nil)
        }else{
            dismiss(animated: true, completion: nil)
            present(alert, animated: true, completion: nil)
//            if let alert = self.presentedViewController as? UIAlertController{
//                alert.present(alert, animated: true, completion: nil)
//            }
        }
    }
    func updateDriverLocation(lat: Double, long: Double) {
        driverLocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
    }



}
