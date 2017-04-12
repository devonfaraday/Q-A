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
    
    static let typeKey = "Q&A"
    static let nameKey = "name"
    static let codeGeneratorKey = "codeGenerator"
    static let questionsKey = "questions"
    static let blockedUsersKey = "blockedUsers"
    
    let name: String
    let codeGenerator: Int
    let questions: [Question]
    var blockedUsers: [CKReference]
    let recordID: CKRecordID?
    
    init(name: String, codeGenerator: Int, questions: [Question] = [], recordID: CKRecordID) {
        self.name = name
        self.codeGenerator = codeGenerator
        self.questions = questions
        self.recordID = recordID
        self.blockedUsers = []
    }
    
    init?(record: CKRecord) {
        guard let name = record[Topic.nameKey] as? String,
            let codeGenerator = record[Topic.codeGeneratorKey] as? Int,
            let questions = record[Topic.questionsKey] as? [Question],
            let blockedUsers = record[Topic.blockedUsersKey] as? [CKReference]
            else { return nil }
        self.name = name
        self.codeGenerator = codeGenerator
        self.questions = questions
        self.blockedUsers = blockedUsers
        self.recordID = record.recordID
    }
}

extension CKRecord {
    convenience init(topic: Topic) {
        let recordID = topic.recordID ?? CKRecordID(recordName: UUID().uuidString)
        self.init(recordType: "Q&A", recordID: recordID)
        self.setValue(topic.name, forKey: Topic.nameKey)
        self.setValue(topic.codeGenerator, forKey: Topic.codeGeneratorKey)
        self.setValue(topic.questions, forKey: Topic.questionsKey)
        self.setValue(topic.blockedUsers, forKey: Topic.blockedUsersKey)
    }
}

func ==(lhs: Topic, rhs: Topic) -> Bool {
    return lhs === rhs
}
