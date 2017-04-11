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
    var currentUser: User?
    var currentTopic: Topic?
    
    func saveQuestion(question: String, completion: @escaping() -> Void) {
        
        guard let owner = currentUser?.firstName else { completion(); return }
        guard let topicID = currentTopic?.recordID else { completion(); return }
        let topicRef = CKReference(recordID: topicID, action: .deleteSelf)
        let question = Question(question: question, questionOwner: owner, topicRef: topicRef)
    }
    
    
}
