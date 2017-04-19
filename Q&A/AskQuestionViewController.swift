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

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    var topic: Topic?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.questionTextView.becomeFirstResponder()
        buttonLayout()
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
        addButton.isEnabled = false
        QuestionController.shared.saveQuestion(question: question, topic: topic) {
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    func buttonLayout() {
        self.addButton.layer.cornerRadius = 5
        self.addButton.layer.borderWidth = 1
        self.addButton.layer.borderColor = UIColor(white: 1.0, alpha: 0.3).cgColor
   
        self.cancelButton.layer.cornerRadius = 5
        self.cancelButton.layer.borderWidth = 1
        self.cancelButton.layer.borderColor = UIColor(white: 1.0, alpha: 0.3).cgColor
    }
    
    
  
}
