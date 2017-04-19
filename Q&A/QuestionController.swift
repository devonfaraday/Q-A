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
    let questionDataRefreshed = Notification.Name("newQuestionData")
    var currentUser: User?
    var questions: [Question] = [] {
        didSet {
            NotificationCenter.default.post(name: questionDataRefreshed, object: nil)
            NSLog("Notification posted \(questionDataRefreshed)")
        }
    }
    init() {
        currentUser = UserController.shared.loggedInUser
    }
    
    func saveQuestion(question: String, topic: Topic, completion: @escaping() -> Void) {
        guard let owner = currentUser?.firstName else { completion(); return }
        guard let topicID = topic.recordID else { completion(); return }
        let topicRef = CKReference(recordID: topicID, action: .deleteSelf)
        let question = Question(question: question, questionOwner: owner, topicRef: topicRef)
        let record = CKRecord(question: question)
        cloudKitManager.saveRecord(record) { (_, error) in
            if let error = error {
                print("Error with saveing question to cloudKit: \(error.localizedDescription)")
                completion()
                return
            } else {
                print("Saved Question to CloudKit")
               self.questions.append(question)
                completion()
            }
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
        self.questions = []
        cloudKitManager.deleteRecordsWithID(recordIDArray) { (_, _, error) in
            if let error = error {
                print("Error with clearing all questions for topic: \(error.localizedDescription)")
                completion()
                return
            }
            print("Successfully cleared Questions")
        }
    }
    
    func upvote(question: Question, completion: @escaping() -> Void) {
        if checkUserForDuplicatesVotes(question: question, bool: true) {
            guard let userID = currentUser?.recordID else { completion(); return }
            let userIDString = userID.recordName
            question.vote += 1
            if question.downVote.contains(userIDString) {
                guard let downVoteIndex = question.downVote.index(of: userIDString) else { return }
                question.downVote.remove(at: downVoteIndex)
            } else {
                question.upVote.append(userIDString)
            }
            modifyQuestion(question: question) {
                completion()
            }
        }
        completion()
    }
    
    func downvote(question: Question, completion: @escaping() -> Void) {
        if checkUserForDuplicatesVotes(question: question, bool: false) {
            guard let userID = currentUser?.recordID else { completion(); return }
            let userIDString = userID.recordName
            question.vote -= 1
            if question.upVote.contains(userIDString) {
                guard let upVoteIndex = question.upVote.index(of: userIDString) else { return }
                question.upVote.remove(at: upVoteIndex)
            } else {
                question.downVote.append(userIDString)
            }
            modifyQuestion(question: question) {
                completion()
            }
        }
        completion()
    }
    
    func checkUserForDuplicatesVotes(question: Question, bool: Bool) -> Bool {
        guard let userID = currentUser?.recordID else { return true }
        let userIDString = userID.recordName
        if bool {
            return !question.upVote.contains(userIDString)
        } else {
            return !question.downVote.contains(userIDString)
        }
    }
    
    func fetchQuestionsWithTopicRef(topic: Topic, completion: @escaping([Question]) -> Void) {
        guard let topicRecordID = topic.recordID else { completion([]); return }
        let topicRef = CKReference(recordID: topicRecordID, action: .none)
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
