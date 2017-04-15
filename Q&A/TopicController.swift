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
    let topicBoolNotificationName = Notification.Name("topicBoolChanged")
    var userTopics: [Topic] = []
    var TopicUsers: [User] = []
    var tempGeneratedNumber: Int = 0
    var currentTopic: Topic?
    
    func createTopic(name: String, completion: @escaping (Topic?) -> Void) {
        let randomNum = randomNumGenerator()
        self.tempGeneratedNumber = randomNum
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
            guard let record = savedTopicRecord else { completion(nil); return }
            let newTopic = Topic(record: record)
            guard let topic = newTopic else { return }
            guard let topicID = topic.recordID else { completion(nil); return }
            self.topics.append(topic)
            let reference = CKReference(recordID: topicID, action: .deleteSelf)
            self.currentUser?.topic?.append(reference)
            guard let user = self.currentUser else { completion(nil); return }
            let userRecord = CKRecord(user: user)
            let operation = CKModifyRecordsOperation(recordsToSave: [userRecord], recordIDsToDelete: nil)
            operation.completionBlock = {
                completion(topic)
            }
            operation.savePolicy = .changedKeys
            self.cloudKitManager.publicDatabase.add(operation)
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
            
            self.userTopics = topics.sorted(by: {$0.name.lowercased() < $1.name.lowercased()})
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
    
    func delete(withRecordID recordID: CKRecordID, completion: @escaping () -> Void) {
        guard let topicIndex = userTopics.index(where: {$0.recordID == recordID }) else { completion(); return }
        self.userTopics.remove(at: topicIndex)
        cloudKitManager.deleteRecordWithID(recordID) { (_, error) in
            if let error = error {
                print("Error with deleting topic for user: \(error.localizedDescription)")
                completion()
                return
            }
            print("Deleted Successfully")
        }
    }
    
    func randomNumGenerator() -> Int {
        var randomInt = 0
        let codeGeneratorArray = topics.flatMap({ $0.codeGenerator})
        let randomNum =  Int(arc4random_uniform(UInt32(89999))) + 10000
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
    
    func addUserToTopic(withCode code: Int, completion: @escaping() -> Void) {
        let predicate = NSPredicate(format: "codeGenerator == \(code)")
        cloudKitManager.fetchRecordsWithType("Topic", predicate: predicate, recordFetchedBlock: nil) { (records, error) in
            if let error = error {
                print("Error with adding user to topic with code: \(error.localizedDescription)")
                completion()
                return
            }
            guard let records = records else { completion(); return }
            let topics = records.flatMap({ Topic(record: $0) })
            guard let topic = topics.last else { completion(); return }
            self.userTopics.append(topic)
            guard let recordID = records.first?.recordID else { completion(); return }
            let topicRef = CKReference(recordID: recordID, action: .deleteSelf)
            self.currentUser?.topic?.append(topicRef)
            guard let user = self.currentUser else { completion(); return }
            let userRecord = CKRecord(user: user)
            let operation = CKModifyRecordsOperation(recordsToSave: [userRecord], recordIDsToDelete: nil)
            operation.completionBlock = {
                completion()
            }
            operation.savePolicy = .changedKeys
            self.cloudKitManager.publicDatabase.add(operation)
            completion()
        }
    }
    
    func toggleIsReadyCheck(topic: Topic, completion: @escaping () -> Void) {
        topic.readyCheck = !topic.readyCheck
        saveModifyTopicRecord(topic: topic) {
            completion()
        }
    }
    
    func saveModifyTopicRecord(topic: Topic, completion: @escaping () -> Void) {
        let topicRecord = CKRecord(topic: topic)
        let operation = CKModifyRecordsOperation(recordsToSave: [topicRecord], recordIDsToDelete: nil)
        operation.completionBlock = {
            completion()
        }
        operation.savePolicy = .changedKeys
        self.cloudKitManager.publicDatabase.add(operation)
        completion()
    }
    
}
