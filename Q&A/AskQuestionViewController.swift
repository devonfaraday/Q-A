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
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var buttonStack: UIStackView!
    @IBOutlet weak var bottomStackBottomConstraint: NSLayoutConstraint!
    var topic: Topic?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.questionTextView.becomeFirstResponder()
        buttonLayout()
        questionTextView.layer.cornerRadius = 6
        questionLabel.font = UIFont(name: "cochin", size: 27.0)
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            bottomStackBottomConstraint.constant = bottomStackBottomConstraint.constant + keyboardSize.height
            let questionLabelTopConstraint = NSLayoutConstraint(item: questionLabel, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 32)
            view.addConstraints([questionLabelTopConstraint])
            
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y += keyboardSize.height
            }
        }
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
