//
//  DBProvider.swift
//  uber rider
//
//  Created by kidnapper on 24/09/2017.
//  Copyright © 2017 kidnapper.com. All rights reserved.
//

import Foundation
import FirebaseDatabase

class DBProvider {
    private static let _instance = DBProvider()
    
    static var Instance: DBProvider{
        return _instance
    }
    
    var dbRef: DatabaseReference{
        return Database.database().reference()
    }
    
    var riderRef: DatabaseReference{
        return dbRef.child(Constants.RIDERS)
    }
    var requestRef: DatabaseReference{
        return dbRef.child(Constants.UBER_REQUEST)
    }
    var requestAcceptRef: DatabaseReference{
        return dbRef.child(Constants.UBER_ACCEPTED)
    }
    
    func saveUser(withID: String, email: String, password: String){
        let data: Dictionary<String, Any> = [Constants.EMAIL: email, Constants.PASSWORD: password, Constants.ISRIDER: true]
        riderRef.child(withID).child(Constants.DATA).setValue(data)
    }
}










