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
    
    func saveUser(firstName: String, lastName: String, imageData: Data, completion: @escaping(User?) -> Void) {
        guard let appleUserRecordID = appleUserRecordID else { completion(nil); return }
        let userRef = CKReference(recordID: appleUserRecordID, action: .deleteSelf)
        let user = User(firstName: firstName, lastName: lastName, profileImageData: imageData, appleUserRef: userRef)
        let record = CKRecord(user: user)
        cloudKitManager.saveRecord(record) { (savedUserRecord, error) in
            if let error = error {
                print("Error with saving User to cloudkit: \(error.localizedDescription)")
                completion(nil)
                return
            }
            guard let savedUserRecord = savedUserRecord else { completion(nil); return }
            let user = User(record: savedUserRecord)
            self.loggedInUser = user
            completion(user)
        }
    }
    
    func toggleReadyCheck(completion: @escaping() -> Void) {
        guard let user = loggedInUser else { return }
        user.readyCheck = !user.readyCheck
        let record = CKRecord(user: user)
            let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        operation.completionBlock = {
            completion()
        }
            operation.savePolicy = .changedKeys
        self.cloudKitManager.publicDatabase.add(operation)
        }
    
    func setAllUsersReadyCheckToFalse(completion: @escaping () -> Void) {
        var userRecords = [CKRecord]()
        for user in TopicController.shared.TopicUsers {
            user.readyCheck = false
            let record = CKRecord(user: user)
            userRecords.append(record)
        }
        let operation = CKModifyRecordsOperation(recordsToSave: userRecords, recordIDsToDelete: nil)
        operation.completionBlock = {
            completion()
        }
        operation.savePolicy = .changedKeys
        self.cloudKitManager.publicDatabase.add(operation)
    }
    
    func modifyUser(user: User, completion: @escaping () -> Void) {
        let record = CKRecord(user: user)
        let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        operation.completionBlock = {
            completion()
        }
        operation.savePolicy = .changedKeys
        self.cloudKitManager.publicDatabase.add(operation)
    }
}
