//
//  QueueViewController.swift
//  Q&A
//
//  Created by Sterling Mortensen on 4/10/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import UIKit
import CloudKit

class QueueViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, VoteQueueTableViewCellDelegate {
    
    //==============================================================
    // MARK: - Properties
    //==============================================================
    var topic: Topic?
    let cloudKitManager = CloudKitManager()
    
    //==============================================================
    // MARK: - IBOutlets
    //==============================================================
    @IBOutlet weak var topicNameTextField: UITextField!
    @IBOutlet weak var questionTableView: UITableView!
    @IBOutlet weak var readyCheckButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var askQuestionButton: UIButton!
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var readyButton: UIButton!
    @IBOutlet weak var backButtonTapped: UIButton!
    
    //==============================================================
    // MARK: - Life Cycle
    //==============================================================
    override func viewDidLoad() {
        super.viewDidLoad()
        changeViewsOnLoad()
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.white
        refreshControl.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
        refreshControl.addTarget(self, action: #selector(refreshQuestionData), for: UIControlEvents.valueChanged)
        questionTableView.refreshControl = refreshControl
        
        
        readyButton.isHidden = true
        //        readyCheckConstraint()
        viewTypeSetup()
        showTopicNumber()
        questionTableView.estimatedRowHeight = 80
        
        questionTableView.reloadData()
        if let topic = topic {
            TopicController.shared.currentTopic = topic
            cloudKitManager.subscripeToStudentReadyCheck(topic: topic)
            cloudKitManager.subscribeToStudentQuestion(topic: topic)
            cloudKitManager.subscripeToQuestionVotesIn(topic: topic)
            cloudKitManager.subscribeToTopicBool(topic: topic)
            TopicController.shared.fetchUsersForTopic(topic: topic, completion: {
            })
            QuestionController.shared.fetchQuestionsWithTopicRef(topic: topic, completion: { (questions) in
                
            })
        }
        NotificationCenter.default.addObserver(self, selector: #selector(refreshQuestionData), name: QuestionController.shared.NewQuestionAdded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTableView), name: QuestionController.shared.questionDataRefreshed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(checkTopicsReadyCheckBool), name: TopicController.shared.topicBoolNotificationName, object: nil)
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshTableView()
        
    }
    
    //==============================================================
    // MARK: - Text Field Delegate Function
    //==============================================================
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let topicName = topicNameTextField.text {
            TopicController.shared.createTopic(name: topicName) { (topic) in
                DispatchQueue.main.async {
                    self.topicNameTextField.borderStyle = .none
                    self.topicNameTextField.textColor = UIColor.white
                    self.topicNameTextField.isEnabled = false
                    self.codeLabel.text = "\(TopicController.shared.tempGeneratedNumber)"
                }
                self.topic = topic
            }
            self.topicNameTextField.resignFirstResponder()
        }
        return true
    }
    
    //==============================================================
    // MARK: - Data Source functions
    //==============================================================
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return QuestionController.shared.questions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = questionTableView.dequeueReusableCell(withIdentifier: "questionCell", for: indexPath) as? QueueTableViewCell else {return UITableViewCell()}
        cell.layer.cornerRadius = 5
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 1
        let question = QuestionController.shared.questions[indexPath.row]
        cell.question = question
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let question = QuestionController.shared.questions[indexPath.row]
            guard let recordID = question.cloudKitRecordID else { return }
            QuestionController.shared.delete(withRecordID: recordID, completion: {
            })
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationViewController = segue.destination as? AskQuestionViewController, let topic = topic else {return}
        destinationViewController.topic = topic
    }
    
    //==============================================================
    // MARK: - View Control Functions
    //==============================================================
    func completeVoteChanged(sender: QueueTableViewCell, vote: Bool) {
        guard let topic = self.topic else { return }
        guard let indexPath = self.questionTableView.indexPath(for: sender) else { return }
        let task = QuestionController.shared.questions[indexPath.row]
        if vote {
            QuestionController.shared.upvote(question: task, completion: {
                QuestionController.shared.fetchQuestionsWithTopicRef(topic: topic, completion: { (_) in
                    DispatchQueue.main.async {
                        self.questionTableView.reloadData()
                    }
                })
            })
        } else {
            QuestionController.shared.downvote(question: task, completion: {
                QuestionController.shared.fetchQuestionsWithTopicRef(topic: topic, completion: { (_) in
                    DispatchQueue.main.async {
                        self.questionTableView.reloadData()
                    }
                })
            })
        }
    }
    
    func showReadyButton() {
        
            guard let topic = TopicController.shared.currentTopic else { return }
            TopicController.shared.fetchTopic(topic: topic, completion: { 
                print("fetched topic")
                DispatchQueue.main.async {
                    self.readyButton.isHidden = false
                }
            })
        }
    
    func checkTopicsReadyCheckBool() {
        guard let topic = topic else { return }
        TopicController.shared.fetchTopic(topic: topic) {
            guard let currentTopic = TopicController.shared.currentTopic else { return }
            if currentTopic.readyCheck && currentTopic.topicOwner.recordID != UserController.shared.loggedInUser?.recordID {
                DispatchQueue.main.async {
                    self.readyButton.isHidden = false
                    self.readyButton.backgroundColor = UIColor.red
                }
            } else {
                DispatchQueue.main.async {
                    self.readyButton.isHidden = true
                }
            }
        }
    }
    
    
    func refreshTableView() {
        DispatchQueue.main.async {
            self.questionTableView.reloadData()
        }
    }
    
    func refreshQuestionData() {
        if let topic = topic {
            QuestionController.shared.fetchQuestionsWithTopicRef(topic: topic, completion: { (_) in
                self.questionTableView.refreshControl?.endRefreshing()
            })
        }
    }
    
    func showTopicNumber() {
        if let topic = topic {
            codeLabel.text = "\(topic.codeGenerator)"
        }
    }
    
    func viewTypeSetup() {
        self.topicNameTextField.becomeFirstResponder()
        askQuestionButton.isHidden = true
        guard let topic = topic, let currentUser = TopicController.shared.currentUser else {return}
        topicNameTextField.text = topic.name
        topicNameTextField.borderStyle = .none
        topicNameTextField.isEnabled = false
        topicNameTextField.textColor = UIColor.white
        if topic.topicOwner.recordID == currentUser.recordID {
            askQuestionButton.isHidden = true
        } else {
            askQuestionButton.isHidden = false
            readyCheckButton.isHidden = true
            clearButton.isHidden = true
        }
    }
    
    func changeViewsOnLoad() {
        self.backButtonTapped.layer.cornerRadius = 5
        self.backButtonTapped.layer.borderWidth = 1
        self.backButtonTapped.layer.borderColor = UIColor(white: 1.0, alpha: 0.3).cgColor
        
        self.askQuestionButton.layer.cornerRadius = 5
        self.askQuestionButton.layer.borderWidth = 1
        self.askQuestionButton.layer.borderColor = UIColor(white: 1.0, alpha: 0.3).cgColor
        
        self.readyCheckButton.layer.cornerRadius = 5
        self.readyCheckButton.layer.borderWidth = 1
        self.readyCheckButton.layer.borderColor = UIColor(white: 1.0, alpha: 0.3).cgColor
        
        self.clearButton.layer.cornerRadius = 5
        self.clearButton.layer.borderWidth = 1
        self.clearButton.layer.borderColor = UIColor(white: 1.0, alpha: 0.3).cgColor
    }

    
    
    //==============================================================
    // MARK: - IBActions
    //==============================================================
    @IBAction func backButtonTapped(_ sender: Any) {
        let _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func blockButtonTapped(_ sender: Any) {
    }
    
    @IBAction func readyCheckButtonTapped(_ sender: Any) {
        guard let topic = topic else { return }
        TopicController.shared.toggleIsReadyCheck(topic: topic, withReadyCheck: true) {
            
        }
    }
    
    @IBAction func clearButtonTapped(_ sender: Any) {
        QuestionController.shared.clearAllQuestions {
            DispatchQueue.main.async {
                self.questionTableView.reloadData()
            }
        }
    }
    
    @IBAction func askQuestionButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction func readyButtonTapped(_ sender: Any) {
        UserController.shared.toggleReadyCheck() {
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
