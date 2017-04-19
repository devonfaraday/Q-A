//
//  Question.swift
//  Q&A
//
//  Created by Sterling Mortensen on 4/10/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import Foundation
import CloudKit

class Question: Equatable {
    
    static let questionKey = "question"
    static let questionRecordType = "Question"
    static let voteKey = "vote"
    static let topicReferenceKey = "topicReference"
    static let ownerKey = "owner"
    static let upVoteKey = "upVote"
    static let downVoteKey = "downVote"
    
    let question: String
    var topicRef: CKReference
    var vote: Int
    let questionOwner: String
    var cloudKitRecordID: CKRecordID?
    var upVote: [String]
    var downVote: [String]
    
    init(question: String, vote: Int = 0, questionOwner: String, topicRef: CKReference, upVote: [String] = [], downVote: [String] = []) {
        self.question = question
        self.vote = vote
        self.questionOwner = questionOwner
        self.topicRef = topicRef
        self.upVote = upVote
        self.downVote = downVote
    }
    
    init?(cloudKitRecord: CKRecord) {
        guard let question = cloudKitRecord[Question.questionKey] as? String,
            let vote = cloudKitRecord[Question.voteKey] as? Int,
            let owner = cloudKitRecord[Question.ownerKey] as? String,
            let upVote = cloudKitRecord[Question.upVoteKey] as? [String],
            let downVote = cloudKitRecord[Question.downVoteKey] as? [String],
            let topicRef = cloudKitRecord[Question.topicReferenceKey] as? CKReference else { return nil }
        self.question = question
        self.vote = vote
        self.questionOwner = owner
        self.topicRef = topicRef
        self.upVote = upVote
        self.downVote = downVote
        self.cloudKitRecordID = cloudKitRecord.recordID
    }
}

extension CKRecord {
    convenience init(question: Question) {
        let recordID = question.cloudKitRecordID ?? CKRecordID(recordName: UUID().uuidString)
        self.init(recordType: "Question", recordID: recordID)
        self.setValue(question.question, forKey: Question.questionKey)
        self.setValue(question.topicRef, forKey: Question.topicReferenceKey)
        self.setValue(question.vote, forKey: Question.voteKey)
        self.setValue(question.upVote, forKey: Question.upVoteKey)
        self.setValue(question.downVote, forKey: Question.downVoteKey)
        self.setValue(question.questionOwner, forKey: Question.ownerKey)
        
        question.cloudKitRecordID = recordID
    }
}

func ==(lhs: Question, rhs: Question) -> Bool {
    return lhs === rhs
}
