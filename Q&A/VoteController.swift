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
    
    func voteOnQuestion(question: Question, completion: @escaping(Error?) -> Void) {
        guard let questionID = question.cloudKitRecordID else { return }
        let questionRef = CKReference(recordID: questionID, action: .deleteSelf)
        let vote = Vote(questionReference: questionRef)
        
        let voteRecord = CKRecord(vote: vote)
        
        cloudKitManager.publicDatabase.save(voteRecord) { (_, error) in
            if let error = error {
                NSLog("Error saving vote: \(error.localizedDescription)")
                completion(error)
                return
            }
        }
    }
    
    func delete(vote: Vote, completion: @escaping() -> Void) {
        
    }
    
    func fetchVotesFor(question: Question, completion: @escaping([Vote]) -> Void) {
        
    }
}
