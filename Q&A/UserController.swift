//
//  UserController.swift
//  Q&A
//
//  Created by Sterling Mortensen on 4/10/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import Foundation
import CloudKit

class UserController {
    
    var appleUserRecordID: CKRecordID?
    var cloudKitManager = CloudKitManager()
    
    init() {
        CKContainer.default().fetchUserRecordID { (recordID, error) in
            if let error = error {
                print("Error with fetching recordID. \(error.localizedDescription)")
                return
            }
            guard let recordID = recordID else { return }
            self.appleUserRecordID = recordID
        }
    }
    
    func saveUser(firstName: String, lastName: String, imageData: Data, completion: @escaping() -> Void) {
        guard let appleUserRecordID = appleUserRecordID else { completion(); return }
        let userRef = CKReference(recordID: appleUserRecordID, action: .deleteSelf)
        let user = User(firstName: firstName, lastName: lastName, recordID: appleUserRecordID, appleUserRef: userRef)
        let record = CKRecord(user: user)
        cloudKitManager.saveRecord(record) { (_, error) in
            if let error = error {
                print("Error with saving User to cloudkit: \(error.localizedDescription)")
                return
            }
            
        }
        
    }
    
    
    
    
    
}
