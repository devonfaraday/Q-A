//
//  Question.swift
//  Q&A
//
//  Created by Sterling Mortensen on 4/10/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import Foundation
import CloudKit

class Question {
    
    
    let question: String
    var topicRef: CKReference?
    var vote: Int
    let questionOwner: String
    
    init(question: String, vote: Int = 0, questionOwner: String) {
        self.question = question
        self.vote = vote
        self.questionOwner = questionOwner
    }
    
   
    
}
