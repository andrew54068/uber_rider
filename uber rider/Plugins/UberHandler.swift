//
//  UberHandler.swift
//  uber rider
//
//  Created by kidnapper on 24/09/2017.
//  Copyright © 2017 kidnapper.com. All rights reserved.
//

import Foundation
import FirebaseDatabase

protocol UberController: class {
    func canCallUber(delegateCalled: Bool)
    func driverAcceptedRequest(requestAccepted: Bool, driverName: String)
    func updateDriverLocation(lat: Double, long: Double)
}

class UberHandler{
    private static let _instance = UberHandler()
    
    weak var delegate: UberController?
    
    var rider = ""
    var driver = ""
    var rider_id = ""
    
    
    static var Instance: UberHandler{
        return _instance
    }
    
    func observeMessageForRider(){
        DBProvider.Instance.requestRef.observe(DataEventType.childAdded) { (snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary{
                if let name = data[Constants.NAME] as? String{
                    if name == self.rider{
                        self.rider_id = snapshot.key
                        self.delegate?.canCallUber(delegateCalled: true)
                    }
                }
            }
        }//rider canceled uber
        DBProvider.Instance.requestRef.observe(DataEventType.childRemoved) { (snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary{
                if let name = data[Constants.NAME] as? String{
                    if name == self.rider{
                        self.delegate?.canCallUber(delegateCalled: false)
                    }
                }
            }
        }
        DBProvider.Instance.requestAcceptRef.observe(DataEventType.childAdded) { (snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary{
                if let name = data[Constants.NAME] as? String{
                    if self.driver == "" {
                        self.driver = name
                        self.delegate?.driverAcceptedRequest(requestAccepted: true, driverName: self.driver)
                    }
                }
            }
        }
        DBProvider.Instance.requestAcceptRef.observe(DataEventType.childRemoved) { (snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary{
                if let name = data[Constants.NAME] as? String{
                    if self.driver == name {
                        self.driver = ""
                        self.delegate?.driverAcceptedRequest(requestAccepted: false, driverName: name)
                    }
                }
            }
        }
        DBProvider.Instance.requestAcceptRef.observe(DataEventType.childChanged) { (snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary{
                if let name = data[Constants.NAME] as? String{
                    if name == self.driver{
                        if let lat = data[Constants.LATITUDE] as? Double{
                            if let long = data[Constants.LONGTITUDE] as? Double{
                                self.delegate?.updateDriverLocation(lat: lat, long: long)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func requestUber(latitude: Double, longitude: Double){
        let data: Dictionary<String, Any> = [Constants.NAME: rider, Constants.LATITUDE: latitude, Constants.LONGTITUDE: longitude]
        
        DBProvider.Instance.requestRef.childByAutoId().setValue(data)
    }
    
    func cancelUber(){
        DBProvider.Instance.requestRef.child(rider_id).removeValue()
    }
    func updateRiderLocation(lat: Double, long: Double){
        DBProvider.Instance.requestRef.child(rider_id).updateChildValues([Constants.LATITUDE: lat, Constants.LONGTITUDE: long])
    }
}














