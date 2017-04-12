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
    var currentUser: User? = UserController.shared.loggedInUser
    var userTopics: [Topic] = []
    var TopicUsers: [User] = []
    
    func createTopic(name: String, completion: @escaping (Topic?) -> Void) {
        let randomNum = randomNumGenerator()
        guard let recordID = currentUser?.recordID else { completion(nil); return }
        let userRef = CKReference(recordID: recordID, action: .none)
        let topic = Topic(name: name, codeGenerator: randomNum, topicOwner: userRef)
        let record = CKRecord(topic: topic)
        cloudKitManager.publicDatabase.save(record) { (savedTopicRecord, error) in
            if let error = error {
                print("There was an error saving to CloudKit. TopicController: createTopic(): \(error.localizedDescription)")
                completion(nil)
                return
            }
            print("Record successfully saved to CloudKit")
            guard let savedTopicRecord = savedTopicRecord else { completion(nil); return }
            guard let topic = Topic(record: savedTopicRecord) else { completion(nil); return }
            self.topics.append(topic)
            let reference = CKReference(recordID: savedTopicRecord.recordID, action: .deleteSelf)
            self.currentUser?.topic?.append(reference)
            guard let user = self.currentUser else { completion(nil); return }
            let record = CKRecord(user: user)
            self.cloudKitManager.saveRecord(record, completion: { (_, error) in
                if let error = error {
                    print("Error with updating current User \(error)")
                }
                completion(nil)
            })
            completion(topic)
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
    
    func fetchTopicsForUser(completion: @escaping([Topic]) -> Void) {
        guard let user = currentUser else { completion([]); return }
        var topicIDs = [CKRecordID]()
        var topics = [Topic]()
        guard let topicRefs = user.topic else { completion([]); return }
        for topic in topicRefs {
            let topicID = topic.recordID
            topicIDs.append(topicID)
        }
        let group = DispatchGroup()
        for id in topicIDs {
            group.enter()
            cloudKitManager.publicDatabase.fetch(withRecordID: id, completionHandler: { (record, error) in
                guard let record = record else { completion([]); return }
                guard let topic = Topic(record: record) else { completion([]); return }
                topics.append(topic)
                group.leave()
            })
        }
        group.notify(queue: DispatchQueue.main) {
            self.userTopics = topics
            completion(topics)
        }
    }
    
    func fetchUsersForTopic(topic: Topic, completion: @escaping() -> Void) {
        guard let topicRecordID = topic.recordID else { completion(); return }
        let topicRef = CKReference(recordID: topicRecordID, action: .deleteSelf)
        let predicate = NSPredicate(format: "topicReferences CONTAINS %@", topicRef)
        cloudKitManager.fetchRecordsWithType("User", predicate: predicate, recordFetchedBlock: nil) { (records, error) in
            if let error = error {
                print("Error with fetching users for Topic: \(error.localizedDescription)")
                completion()
                return
            }
            guard let records = records else { completion(); return }
            let users = records.flatMap({ User(record: $0) })
            self.TopicUsers = users
            completion()
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
    
    func modifyTopic(topic: Topic, completion: @escaping () -> Void) {
        let record = CKRecord(topic: topic)
        let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        operation.completionBlock = {
            completion()
        }
        operation.savePolicy = .changedKeys
        self.cloudKitManager.publicDatabase.add(operation)
    }
    
    func blockUsers(user: User, topic: Topic) {
        guard let recordID = user.recordID else { return }
        let userRef = CKReference(recordID: recordID, action: .deleteSelf)
        topic.blockedUsers.append(userRef)
        modifyTopic(topic: topic) {
        }
    }
    
    func blockUserQuestion(user: User, topic: Topic) -> Bool {
        guard let userRecordID = user.recordID else { return false }
        let userRef = CKReference(recordID: userRecordID, action: .deleteSelf)
        let blocked = topic.blockedUsers.contains(userRef)
        if blocked {
            return true
        } else {
            return false
        }
    }
}
