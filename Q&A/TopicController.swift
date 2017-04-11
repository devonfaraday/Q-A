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
    
    func createTopic(name: String,  questions: [Question], recordID: CKRecordID, completion: @escaping (Error?) -> Void) {
        let randomNum = randomNum()
        let topics = Topic(name: name, codeGenerator: randomNum, questions: questions, recordID: recordID)
        
        let record = CKRecord(topic: topics)
        cloudKitManager.publicDatabase.save(record) { (_, error) in
            
            if let error = error {
                print("There was an error saving to CloudKit. TopicController: createTopic()")
                completion(error)
            } else {
                print("Record successfully saved to CloudKit")
                self.topics.append(topics)
                completion(nil)
            }
        }
    }
    
    func fetchTopicFromCloudKit(completion: @escaping ([Topic]) -> Void) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Topic", predicate: predicate)
        
        cloudKitManager.publicDatabase.perform(query, inZoneWith: nil) { (records, error) in
            guard let records = records
                else { return }
            let topics = records.flatMap({ Topic(record: $0)})
            completion(topics)
        }
    }
    
    func randomNum() -> Int {
        var arrayOfNumbers = []
    }
}
