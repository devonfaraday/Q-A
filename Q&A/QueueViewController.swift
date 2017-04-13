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
    
    var topic: Topic?
    let cloudKitManager = CloudKitManager()
    
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
                DispatchQueue.main.async {
                    self.topicNameTextField.borderStyle = .none
                    self.topicNameTextField.isEnabled = false
                    self.codeLabel.text = "\(TopicController.shared.tempGeneratedNumber)"
                }
                self.topic = topic
 
            }
            self.topicNameTextField.resignFirstResponder()
        }
        return true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if let topic = topic {
            cloudKitManager.subscripeToStudentReadyCheck(topic: topic)
        }
        readyCheckConstraint()
        viewTypeSetup()
        showTopicNumber()
        questionTableView.reloadData()
        if let topic = topic {
            TopicController.shared.fetchUsersForTopic(topic: topic, completion: { 
            })
        }
        
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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationViewController = segue.destination as? AskQuestionViewController, let indexPath = questionTableView.indexPathForSelectedRow else {return}
        let topic = TopicController.shared.userTopics[indexPath.row]
        destinationViewController.topic = topic
    }
    // MARK: - View Control Functions
    
    func showTopicNumber() {
        if let topic = topic {
            codeLabel.text = "\(topic.codeGenerator)"
        }
    }
    
    
    func viewTypeSetup() {
        guard let topic = topic, let currentUser = TopicController.shared.currentUser else {return}
            topicNameTextField.text = topic.name
            topicNameTextField.borderStyle = .none
            topicNameTextField.isEnabled = false

        if topic.topicOwner.recordID == currentUser.recordID {
            askQuestionButton.isHidden = true
        } else {
            blockButton.isHidden = true
            readyCheckButton.isHidden = true
            clearButton.isHidden = true
        }
    }
    
    func readyCheckConstraint() {
        readyButton.translatesAutoresizingMaskIntoConstraints = false
        let readyButtonTopConstraint = NSLayoutConstraint(item: readyButton, attribute: .top, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        let readyButtonHeightConstraint = NSLayoutConstraint(item: readyButton, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 1000)
        view.addConstraint(readyButtonHeightConstraint)
        view.addConstraint(readyButtonTopConstraint)
        
        
    }
    
    // MARK: - IBActions
    
    @IBAction func backButtonTapped(_ sender: Any) {
        let _ = navigationController?.popViewController(animated: true)
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
        UserController.shared.toggleReadyCheck {
            guard let currentUser = TopicController.shared.currentUser else {return}
            DispatchQueue.main.async {
            if currentUser.readyCheck {
            self.readyButton.setTitle("Ready", for: .normal)
            self.readyButton.backgroundColor = UIColor.green
            } else {
            self.readyButton.setTitle("Not Ready", for: .normal)
            self.readyButton.backgroundColor = UIColor.red
            }
            }
        }
    
}
}
