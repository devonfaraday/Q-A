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
    
    var userRecordID: CKRecordID?
    
    init() {
        CKContainer.default().fetchUserRecordID { (recordID, error) in
            if let error = error {
                print("Error with fetching recordID. \(error.localizedDescription)")
                return
            }
            guard let recordID = recordID else { return }
            self.userRecordID = recordID
        }
    }
    
    func saveUser(firstName: String, lastName: String, imageData: Data, completion: @escaping() -> Void) {
        
    }
    
    
    
    
    
}
