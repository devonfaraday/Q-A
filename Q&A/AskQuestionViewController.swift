//
//  AskQuestionViewController.swift
//  Q&A
//
//  Created by Sterling Mortensen on 4/13/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import UIKit
import NotificationCenter

class AskQuestionViewController: UIViewController {

    var topic: Topic?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.questionTextView.becomeFirstResponder()
    }
    
    //==============================================================
    // MARK: - IBOutlets
    //==============================================================
    @IBOutlet weak var questionTextView: UITextView!
    
    //==============================================================
    // MARK: - IBActions
    //==============================================================
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        guard let question = questionTextView.text, !question.isEmpty, let topic = self.topic else { return }
        QuestionController.shared.saveQuestion(question: question, topic: topic) {
        
        }
        
        dismiss(animated: true, completion: nil)
    }
    
  
}
