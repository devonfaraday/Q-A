//
//  Question.swift
//  Q&A
//
//  Created by Sterling Mortensen on 4/10/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import Foundation
import CloudKit

class Question {
    
    static let questionKey = "question"
    static let questionRecordType = "Question"
    static let voteKey = "vote"
    static let topicReferenceKey = "topicReference"
    static let ownerKey = "owner"
    
    let question: String
    var topicRef: CKReference
    var vote: Int
    let questionOwner: String
    var cloudKitRecordID: CKRecordID?
    
    init(question: String, vote: Int = 0, questionOwner: String, topicRef: CKReference) {
        self.question = question
        self.vote = vote
        self.questionOwner = questionOwner
        self.topicRef = topicRef
    }
    
    init?(cloudKitRecord: CKRecord) {
        guard let question = cloudKitRecord[Question.questionKey] as? String,
            let vote = cloudKitRecord[Question.voteKey] as? Int,
            let owner = cloudKitRecord[Question.ownerKey] as? String,
            let topicRef = cloudKitRecord[Question.topicReferenceKey] as? CKReference else { return nil }
        self.question = question
        self.vote = vote
        self.questionOwner = owner
        self.topicRef = topicRef
        self.cloudKitRecordID = cloudKitRecord.recordID
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

extension CKRecord {
    convenience init(question: Question) {
        let recordID = question.cloudKitRecordID ?? CKRecordID(recordName: UUID().uuidString)
        self.init(recordType: "Question", recordID: recordID)
        self.setValue(question.question, forKey: Question.questionKey)
        self.setValue(question.topicRef, forKey: Question.topicReferenceKey)
        self.setValue(question.vote, forKey: Question.voteKey)
        self.setValue(question.questionOwner, forKey: Question.ownerKey)
    }
}

