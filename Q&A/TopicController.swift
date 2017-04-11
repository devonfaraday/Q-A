//
//  TopicController.swift
//  Q&A
//
//  Created by Sterling Mortensen on 4/10/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import Foundation
import CloudKit

class TopicController {
    
    var topics: [Topic] = []
    static let shared = TopicController()
    let cloudKitManager = CloudKitManager()
    var currentTopic: Topic? {
        didSet {
            QuestionController.shared.currentTopic = self.currentTopic
        }
    }
    
    func createTopic(name: String,  questions: [Question], recordID: CKRecordID, completion: @escaping (Error?) -> Void) {
        let randomNum = randomNumGenerator()
        let topics = Topic(name: name, codeGenerator: randomNum, questions: questions, recordID: recordID)
        
        let record = CKRecord(topic: topics)
        cloudKitManager.publicDatabase.save(record) { (savedTopicRecord, error) in
            
            if let error = error {
                print("There was an error saving to CloudKit. TopicController: createTopic()")
                completion(error)
                return
            }
                print("Record successfully saved to CloudKit")
            guard let savedTopicRecord = savedTopicRecord else { completion(nil); return }
            guard let topic = Topic(record: savedTopicRecord) else { completion(nil); return }
            self.topics.append(topic)
            self.currentTopic = topic
            completion(nil)
        }
    }
    
    func fetchTopicFromCloudKit(completion: @escaping ([Topic]) -> Void) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Topic", predicate: predicate)
        
        cloudKitManager.publicDatabase.perform(query, inZoneWith: nil) { (records, error) in
            guard let records = records
                else { return }
            let topics = records.flatMap({ Topic(record: $0)})
            self.topics = topics
            completion(topics)
        }
    }
    
    func delete(withRecordID: CKRecordID, completion: @escaping (CKRecordID?, Error?) -> Void) {
        cloudKitManager.publicDatabase.delete(withRecordID: withRecordID) { (recordID, error) in
            if let error = error {
                print("Was not able to delete CKRecord from CloudKit. TopicController: delete()")
                completion(recordID, error)
            }
        }
    }
    
    func randomNumGenerator() -> Int {
        var randomInt = 0
        let codeGeneratorArray = topics.flatMap({ $0.codeGenerator})
        let randomNum =  Int(arc4random_uniform(UInt32(99999))) + 10000
        let contains = codeGeneratorArray.contains(Int(randomNum))
        if contains {
            let _ = randomNumGenerator()
        } else {
            randomInt = randomNum
        }
        return randomInt
    }
}
