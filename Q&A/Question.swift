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
    
    
    let question: String
    var topicRef: CKReference?
    var vote: Int
    let questionOwner: String
    
    init(question: String, vote: Int = 0, questionOwner: String) {
        self.question = question
        self.vote = vote
        self.questionOwner = questionOwner
    }
    
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
