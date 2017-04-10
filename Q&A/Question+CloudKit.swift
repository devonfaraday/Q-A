//
//  Question+CloudKit.swift
//  Q&A
//
//  Created by Christian McMullin on 4/10/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import Foundation
import CloudKit

extension Question {
    
    static let questionRecordType = "questionRecord"
    static let questionKey = "question"
    static let topicReferenceKey = "topicReference"
    static let voteKey = "vote"
    static let ownerKey = "owner"

    
    convenience init?(cloudKitRecord: CKRecord) {
        guard let question = cloudKitRecord[Question.questionKey] as? String,
            let vote = cloudKitRecord[Question.voteKey] as? Int,
            let owner = cloudKitRecord[Question.ownerKey] as? String else { return nil }
        
        self.init(question: question, vote: vote, questionOwner: owner)
            self.topicRef = cloudKitRecord[Question.topicReferenceKey] as? CKReference
        
    }
    
    var cloudKitRecord: CKRecord {
        let record = CKRecord(recordType: Question.questionRecordType)
        record[Question.questionKey] = question as CKRecordValue
        record[Question.topicReferenceKey] = topicRef as CKRecordValue?
        record[Question.voteKey] = vote as CKRecordValue
        record[Question.ownerKey] = questionOwner as CKRecordValue
        return record
    }
    
}
