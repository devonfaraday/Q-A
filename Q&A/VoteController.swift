//
//  VoteController.swift
//  Q&A
//
//  Created by Christian McMullin on 4/21/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import Foundation
import CloudKit

class VoteController {
    
    static let shared = VoteController()
    private let cloudKitManager = CloudKitManager()
    
    func voteOnQuestion(_ question: Question, completion: @escaping(Vote?, Error?) -> Void) {
        guard let questionID = question.cloudKitRecordID,
            let userID = UserController.shared.loggedInUser?.recordID else { return }
        let questionRef = CKReference(recordID: questionID, action: .deleteSelf)
        let userRef = CKReference(recordID: userID, action: .deleteSelf)
        let vote = Vote(questionReference: questionRef, userReference: userRef)
        
        let voteRecord = CKRecord(vote: vote)
        
        cloudKitManager.publicDatabase.save(voteRecord) { (_, error) in
            if let error = error {
                NSLog("Error saving vote: \(error.localizedDescription)")
                completion(nil, error)
                return
            } else {
                completion(vote, nil)
            }
            
        }
    }
    
    func delete(vote: Vote, completion: @escaping() -> Void) {
        guard let voteID = vote.recordID else { return }
        cloudKitManager.deleteRecordWithID(voteID) { (_, error) in
            if let error = error {
                NSLog("Error deleting vote with reference to \(vote.questionReference):\n\(error.localizedDescription)")
                completion()
                return
            } else {
                completion()
            }
        }
    }
    
    func fetchVotesFor(question: Question, completion: @escaping([Vote]) -> Void) {
        guard let questionID = question.cloudKitRecordID else { return }
        let questionRef = CKReference(recordID: questionID, action: .none)
        let predicate = NSPredicate(format: "\(Vote.questionReferenceKey) == %@", questionRef)
        let query = CKQuery(recordType: Vote.voteRecordType, predicate: predicate)
        cloudKitManager.publicDatabase.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                NSLog("Error fetching votes for question: \(question.question)\n\(error.localizedDescription)")
                completion([])
                return
            } else {
                guard let records = records else { completion([]); return }
                let votes = records.flatMap { Vote(cloudKitRecord: $0) }
                completion(votes)
            }
        }
    }
}






