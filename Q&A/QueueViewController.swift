//
//  QueueViewController.swift
//  Q&A
//
//  Created by Sterling Mortensen on 4/10/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import UIKit
import CloudKit

class QueueViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var topic: Topic? {
        didSet {
            updateView()
        }
    }
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var topicNameTextField: UITextField!
    @IBOutlet weak var questionTableView: UITableView!
    @IBOutlet weak var blockButton: UIButton!
    @IBOutlet weak var readyCheckButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var askQuestionButton: UIButton!
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var readyButton: UIButton!
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let topicName = topicNameTextField.text {
        TopicController.shared.createTopic(name: topicName) { (topic) in
            self.topicNameTextField.borderStyle = .none
            self.topicNameTextField.isEnabled = false
            self.topic = topic
            
        }
         self.topicNameTextField.resignFirstResponder()
    }
        return true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        viewTypeSetup()
        showTopicNumber()
        questionTableView.reloadData()
    }
    
    func updateView() {
      
    }
    // MARK: - Data Source Functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return QuestionController.shared.questions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = questionTableView.dequeueReusableCell(withIdentifier: "questionCell", for: indexPath) as? QueueTableViewCell else {return UITableViewCell()}
        let question = QuestionController.shared.questions[indexPath.row]
        cell.question = question
        return cell
        
        
    }
    
    // MARK: - View Control Functions
    
    func showTopicNumber() {
        if let topic = topic {
            codeLabel.text = "\(topic.codeGenerator)"
        }
    }
    
    
    func viewTypeSetup() {
        guard let topic = topic, let currentUser = TopicController.shared.currentUser else {return}
        if topic.topicOwner.recordID == currentUser.recordID {
            readyButton.isHidden = true
            askQuestionButton.isHidden = true
        } else {
            blockButton.isHidden = true
            readyCheckButton.isHidden = true
            clearButton.isHidden = true
        }
    }
    
    
    // MARK: - IBActions
    
    @IBAction func backButtonTapped(_ sender: Any) {
    }
    @IBAction func blockButtonTapped(_ sender: Any) {
    }
    @IBAction func readyCheckButtonTapped(_ sender: Any) {
    }
    @IBAction func clearButtonTapped(_ sender: Any) {
    }
    @IBAction func askQuestionButtonTapped(_ sender: Any) {
    }
    @IBAction func readyButtonTapped(_ sender: Any) {
    }
    
    
}
