//
//  Topic.swift
//  Q&A
//
//  Created by Sterling Mortensen on 4/10/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import Foundation
import CloudKit

class Topic: Equatable {
    
    static let nameKey = "name"
    static let codeGeneratorKey = "codeGenerator"
    static let questionsKey = "questions"
    static let blockedUsersKey = "blockedUsers"
    static let readyCheckKey = "readyCheck"
    static let topicOwnerKey = "topicOwner"
    
    let name: String
    let codeGenerator: Int
    let questions: [Question]
    var blockedUsers: [CKReference]
    let recordID: CKRecordID?
    var readyCheck: Bool
    let topicOwner: CKReference
    
    init(name: String, codeGenerator: Int, questions: [Question] = [], recordID: CKRecordID, readyCheck: Bool = false, topicOwner: CKReference) {
        self.name = name
        self.codeGenerator = codeGenerator
        self.questions = questions
        self.recordID = recordID
        self.blockedUsers = []
        self.readyCheck = readyCheck
        self.topicOwner = topicOwner
    }
    
    init?(record: CKRecord) {
        guard let name = record[Topic.nameKey] as? String,
            let codeGenerator = record[Topic.codeGeneratorKey] as? Int,
            let questions = record[Topic.questionsKey] as? [Question],
            let blockedUsers = record[Topic.blockedUsersKey] as? [CKReference],
            let readyCheck = record[Topic.readyCheckKey] as? Bool,
            let topicOwner = record[Topic.topicOwnerKey] as? CKReference
            else { return nil }
        self.name = name
        self.codeGenerator = codeGenerator
        self.questions = questions
        self.blockedUsers = blockedUsers
        self.recordID = record.recordID
        self.readyCheck = readyCheck
        self.topicOwner = topicOwner
    }
}

extension CKRecord {
    convenience init(topic: Topic) {
        let recordID = topic.recordID ?? CKRecordID(recordName: UUID().uuidString)
        self.init(recordType: "Topic", recordID: recordID)
        self.setValue(topic.name, forKey: Topic.nameKey)
        self.setValue(topic.codeGenerator, forKey: Topic.codeGeneratorKey)
        self.setValue(topic.questions, forKey: Topic.questionsKey)
        self.setValue(topic.blockedUsers, forKey: Topic.blockedUsersKey)
        self.setValue(topic.readyCheck, forKey: Topic.readyCheckKey)
        self.setValue(topic.topicOwner, forKey: Topic.topicOwnerKey)
    }
}

func ==(lhs: Topic, rhs: Topic) -> Bool {
    return lhs === rhs
}
