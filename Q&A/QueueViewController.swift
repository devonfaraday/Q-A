//
//  QueueViewController.swift
//  Q&A
//
//  Created by Sterling Mortensen on 4/10/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import UIKit
import CloudKit

class QueueViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var topic: Topic?
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var topicNameTextField: UITextField!
    @IBOutlet weak var questionTableView: UITableView!
    @IBOutlet weak var blockButton: UIButton!
    @IBOutlet weak var readyCheckButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var askQuestionButton: UIButton!
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var readyButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        questionTableView.reloadData()
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
    
    func currentUserCheck() -> Bool {
        guard let topic = topic, let currentUser = TopicController.shared.currentUser else {return false}
        if topic.topicOwner == currentUser.recordID {
            print ("True")
            return true
        } else {
            print ("FUCK")
        return false
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
