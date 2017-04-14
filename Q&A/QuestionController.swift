//
//  QuestionController.swift
//  Q&A
//
//  Created by Sterling Mortensen on 4/10/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import Foundation
import CloudKit

class QuestionController {
    
    var cloudKitManager = CloudKitManager()
    static var shared = QuestionController()
    let NewQuestionAdded = Notification.Name("NewQuestionAdded")
    var currentUser: User? = UserController.shared.loggedInUser
    var questions: [Question] = []
    
    func saveQuestion(question: String, topic: Topic, completion: @escaping() -> Void) {
        guard let owner = currentUser?.firstName else { completion(); return }
        guard let topicID = topic.recordID else { completion(); return }
        let topicRef = CKReference(recordID: topicID, action: .deleteSelf)
        let question = Question(question: question, questionOwner: owner, topicRef: topicRef)
        let record = question.cloudKitRecord
        cloudKitManager.saveRecord(record) { (_, error) in
            if let error = error {
                print("Error with saveing question to cloudKit: \(error.localizedDescription)")
                completion()
                return
            }
            print("Saved Question to CloudKit")
            self.questions.append(question)
            completion()
        }
    }
    
    func delete(withRecordID recordID: CKRecordID, completion: @escaping () -> Void) {
        guard let questionIndex = questions.index(where: {$0.cloudKitRecordID == recordID }) else { completion(); return }
        self.questions.remove(at: questionIndex)
        cloudKitManager.deleteRecordWithID(recordID) { (_, error) in
            if let error = error {
                print("Error with deleting question for topic: \(error.localizedDescription)")
                completion()
                return
            }
            print("Deleted Successfully")
        }
    }
    
    func modifyQuestion(question: Question, completion: @escaping () -> Void) {
        let record = CKRecord(question: question)
        let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        operation.completionBlock = {
            completion()
        }
        operation.savePolicy = .changedKeys
        self.cloudKitManager.publicDatabase.add(operation)
    }
    
    func deleteQuestion(withRecordID recordID: CKRecordID, completion: @escaping (CKRecordID?, Error?) -> Void) {
        cloudKitManager.publicDatabase.delete(withRecordID: recordID) { (recordID, error) in
            if let error = error {
                print("There was an error deleting from CloudKit: \(error.localizedDescription)")
                completion(recordID, error)
            }
        }
    }
    
    func clearAllQuestions(completion: @escaping () -> Void) {
        let recordIDArray = questions.flatMap({ $0.cloudKitRecordID })
        
        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: recordIDArray)
        operation.completionBlock = {
            completion()
        }
        operation.savePolicy = .changedKeys
        self.cloudKitManager.publicDatabase.add(operation)
    }
    
    func upvote(question: Question, completion: @escaping() -> Void) {
        question.vote += 1
        modifyQuestion(question: question) {
            completion()
        }
    }
    
    func downvote(question: Question, completion: @escaping() -> Void) {
        question.vote -= 1
        modifyQuestion(question: question) {
            completion()
        }
    }
    
    func fetchQuestionsWithTopicRef(topic: Topic, completion: @escaping([Question]) -> Void) {
        guard let topicRecordID = topic.recordID else { completion([]); return }
        let topicRef = CKReference(recordID: topicRecordID, action: .deleteSelf)
        let predicate = NSPredicate(format: "topicReference == %@", topicRef)
        let query = CKQuery(recordType: Question.questionRecordType, predicate: predicate)
        cloudKitManager.publicDatabase.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("Error with fetching questions for this topic: \(error.localizedDescription)")
                completion([])
                return
            }
            guard let records = records else { completion([]);  return }
            let questions = records.flatMap({ Question(cloudKitRecord: $0) })
            print("Successfully fetched questions")
            let sortedQuestions = questions.sorted(by: { $0.vote > $1.vote })
            self.questions = sortedQuestions
            completion(sortedQuestions)
        }
    }
}
