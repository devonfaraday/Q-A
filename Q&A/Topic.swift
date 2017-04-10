//
//  Topic.swift
//  Q&A
//
//  Created by Sterling Mortensen on 4/10/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import Foundation
import CloudKit

class Topic {
    
    static let typeKey = "Q&A"
    static let nameKey = "name"
    static let codeGeneratorKey = "codeGenerator"
    static let questionsKey = "questions"
    
    let name: String
    let codeGenerator: Int
    let questions: [Question]
    let recordID: CKRecordID?
    
    init(name: String, codeGenerator: Int, questions: [Question] = [], recordID: CKRecordID) {
        self.name = name
        self.codeGenerator = codeGenerator
        self.questions = questions
        self.recordID = recordID
    }
    
    // MARK: - CloudKit Syncable
    
    var recordType: String {
        return Topic.typeKey
    }
    
    convenience required init?(record: CKRecord) {
        guard let name = record[Topic.nameKey] as? String,
            let codeGenerator = record[Topic.codeGeneratorKey] as? Int,
            let questions = record[Topic.questionsKey] as? [Question]
            else { return nil }
        
        self.init(name: name, codeGenerator: codeGenerator, questions: questions, recordID: record.recordID)
        
    }
}

extension CKRecord {
    
    convenience init(topic: Topic) {
        
        let recordID = topic.recordID ?? CKRecordID(recordName: UUID().uuidString)
        self.init(recordType: "Q&A", recordID: recordID)
        self.setValue(topic.name, forKey: Topic.nameKey)
        self.setValue(topic.codeGenerator, forKey: Topic.codeGeneratorKey)
        self.setValue(topic.questions, forKey: Topic.questionsKey)
    }
}
