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
    
    static let shared = UserController()
    
    var appleUserRecordID: CKRecordID?
    var cloudKitManager = CloudKitManager()
    var loggedInUser: User?
    var usersTopics = [Topic]()
    
    func saveUser(firstName: String, lastName: String, imageData: Data, completion: @escaping() -> Void) {
        guard let appleUserRecordID = appleUserRecordID else { completion(); return }
        let userRef = CKReference(recordID: appleUserRecordID, action: .deleteSelf)
        let user = User(firstName: firstName, lastName: lastName, profileImageData: imageData, appleUserRef: userRef)
        let record = CKRecord(user: user)
        cloudKitManager.saveRecord(record) { (savedUserRecord, error) in
            if let error = error {
                print("Error with saving User to cloudkit: \(error.localizedDescription)")
                completion()
                return
            }
            guard let savedUserRecord = savedUserRecord else { completion(); return }
            self.loggedInUser = User(record: savedUserRecord)
            completion()
        }
    }
    
    func toggleReadyCheck(completion: @escaping() -> Void) {
        guard let user = loggedInUser else { return }
        user.readyCheck = !user.readyCheck
        let record = CKRecord(user: user)
        cloudKitManager.publicDatabase.save(record) { (record, error) in
            if let error = error {
                NSLog(error.localizedDescription)
                return
            }
        }
        
    }
    
    func setAllUsersReadyCheckToFalse() {
        
    }
    
    func modifyUser() {
        
    }
    
}
