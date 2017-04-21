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
    
    let questionReference: CKReference
    var recordID: CKRecordID?
    
    init(questionReference: CKReference) {
        self.questionReference = questionReference
    }
    
    init?(cloudKitRecord: CKRecord) {
        guard let reference  = questionReference as? CKReference else { return }
        self.questionReference = reference
        self.recordID = cloudKitRecord.recordID
    }
    
    var cloudKitRecord: CKRecord {
        let record = CKRecord(recordType: Vote.voteRecordType)
        record.setValue(questionReference, forKey: Vote.questionReferenceKey)
        return record
    }
}

extension CKRecord {
    
    convenience init(vote: Vote) {
        let recordID = vote.recordID ?? CKRecordID(recordName: UUID().uuidString)
        self.init(recordType: Vote.voteRecordType, recordID: recordID)
        self.setValue(vote.questionReference, forKey: Vote.questionReferenceKey)
        vote.recordID = recordID
    }
}

func ==(lhs: Vote, rhs: Vote) -> Bool {
    return lhs === rhs
}
