//
//  Vote.swift
//  Q&A
//
//  Created by Christian McMullin on 4/21/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import Foundation
import CloudKit

class Vote: Equatable {
    
    static let voteRecordType = "Vote"
    static let questionReferenceKey = "QuestionReference"
    static let userRefKey = "UserRef"
    
    
    let questionReference: CKReference
    let userReference: CKReference
    var recordID: CKRecordID?
    
    init(questionReference: CKReference, userReference: CKReference) {
        self.questionReference = questionReference
        self.userReference = userReference
    }
    
    init?(cloudKitRecord: CKRecord) {
        guard let reference  = cloudKitRecord[Vote.questionReferenceKey] as? CKReference,
            let userRef = cloudKitRecord[Vote.userRefKey] as? CKReference else { return nil }
        self.questionReference = reference
        self.userReference = userRef
        self.recordID = cloudKitRecord.recordID
    }
    
}

extension CKRecord {
    
    convenience init(vote: Vote) {
        let recordID = vote.recordID ?? CKRecordID(recordName: UUID().uuidString)
        self.init(recordType: Vote.voteRecordType, recordID: recordID)
        self.setValue(vote.questionReference, forKey: Vote.questionReferenceKey)
        self.setValue(vote.userReference, forKey: Vote.userRefKey)
        vote.recordID = recordID
    }
}

func ==(lhs: Vote, rhs: Vote) -> Bool {
    return lhs === rhs
}
