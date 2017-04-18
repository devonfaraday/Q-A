//
//  User.swift
//  Q&A
//
//  Created by Sterling Mortensen on 4/10/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import CloudKit
import UIKit

class User: Equatable {
    
    static let firstNameKey = "firstName"
    static let lastNameKey = "lastName"
    static let profileImageDataKey = "profileImageData"
    static let recordIDKey = "userRecordID"
    static let readyCheckKey = "readyCheck"
    static let topicKey = "topicReferences"
    static let appleUserRefKey = "appleUserRef"
    
    var firstName: String
    var lastName: String
    var profileImageData: Data
    var recordID: CKRecordID?
    var readyCheck: Bool
    var topic: [CKReference]?
    let appleUserRef: CKReference
    
    fileprivate var temporaryPhotoURL: URL {
        let tempDir = NSTemporaryDirectory()
        let tempURL = URL(fileURLWithPath: tempDir)
        let fileURL = tempURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("png")
        try? profileImageData.write(to: fileURL, options: [.atomic])
        return fileURL
    }
    
    var profileImage: UIImage {
        let imageData = profileImageData
        guard let image = UIImage(data: imageData) else { return UIImage() }
        return image
    }
    
    init(firstName: String, lastName: String, profileImageData: Data, readyCheck: Bool = false, appleUserRef: CKReference) {
        
        self.firstName = firstName
        self.lastName = lastName
        self.profileImageData = profileImageData
        self.readyCheck = readyCheck
        self.appleUserRef = appleUserRef
        
    }
    
    init?(record: CKRecord) {
        guard let firstName = record[User.firstNameKey] as? String,
            let lastName = record[User.lastNameKey] as? String,
            let readyCheck = record[User.readyCheckKey] as? Bool,
            let photoAsset = record[User.profileImageDataKey] as? CKAsset,
            let appleUserRef = record[User.appleUserRefKey] as? CKReference else { return nil }
        
        self.firstName = firstName
        self.lastName = lastName
        self.recordID = record.recordID
        self.readyCheck = readyCheck
        self.topic = record[User.topicKey] as? [CKReference]
        let imageDataOpt = try? Data(contentsOf: photoAsset.fileURL)
        guard let imageData = imageDataOpt else { return nil }
        self.profileImageData = imageData
        self.appleUserRef = appleUserRef
    }
}

extension CKRecord {
    convenience init(user: User) {
        let recordID = user.recordID ?? CKRecordID(recordName: UUID().uuidString)
        self.init(recordType: "User", recordID: recordID)
        self.setValue(user.firstName, forKey: User.firstNameKey)
        self.setValue(user.lastName, forKey: User.lastNameKey)
        let imageAsset = CKAsset(fileURL: user.temporaryPhotoURL)
        self.setValue(imageAsset, forKey: User.profileImageDataKey)
        self.setValue(user.readyCheck, forKey: User.readyCheckKey)
        self.setValue(user.topic, forKey: User.topicKey)
        self.setValue(user.appleUserRef, forKey: User.appleUserRefKey)
        
    }
}

func ==(lhs: User, rhs: User) -> Bool {
    return lhs === rhs
}





















