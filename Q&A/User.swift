//
//  User.swift
//  Q&A
//
//  Created by Sterling Mortensen on 4/10/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import CloudKit
import UIKit

class User {
    
    static let firstNameKey = "firstName"
    static let lastNameKey = "lastName"
    static let profileImageDataKey = "profileImageData"
    static let recordIDKey = "recordID"
    static let readyCheckKey = "readyCheck"
    static let topicKey = "topic"
    
    let firstName: String
    let lastName: String
    let profileImageData: Data?
    let recordID: CKRecordID?
    let readyCheck: Bool
    let topic: [CKReference]
    
    fileprivate var temporaryPhotoURL: URL {
        let tempDir = NSTemporaryDirectory()
        let tempURL = URL(fileURLWithPath: tempDir)
        let fileURL = tempURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("png")
        try? profileImageData?.write(to: fileURL, options: [.atomic])
        return fileURL
    }
    
    var profileImage: UIImage {
        guard let imageData = profileImageData,
            let image = UIImage(data: imageData) else { return UIImage() }
        return image
    }
    
    init(firstName: String, lastName: String, profileImageData: Data? = nil, recordID: CKRecordID?, readyCheck: Bool = false, topic: [CKReference] = []) {
        
        self.firstName = firstName
        self.lastName = lastName
        self.profileImageData = profileImageData
        self.recordID = recordID
        self.readyCheck = readyCheck
        self.topic = topic
    }
    
    init?(record: CKRecord) {
        guard let firstName = record[User.firstNameKey] as? String,
            let lastName = record[User.lastNameKey] as? String,
            let readyCheck = record[User.readyCheckKey] as? Bool,
            let photoAsset = record[User.profileImageDataKey] as? CKAsset,
            let topic = record[User.topicKey] as? [CKReference] else { return nil }
        
        self.firstName = firstName
        self.lastName = lastName
        self.recordID = record.recordID
        self.readyCheck = readyCheck
        self.topic = topic
        let imageData = try? Data(contentsOf: photoAsset.fileURL)
        self.profileImageData = imageData
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
        self.setValue(user.recordID, forKey: User.recordIDKey)
        self.setValue(user.readyCheck, forKey: User.readyCheckKey)
        self.setValue(user.topic, forKey: User.topicKey)
    }
}























