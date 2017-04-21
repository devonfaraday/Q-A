//
//  TopicViewController.swift
//  Q&A
//
//  Created by Sterling Mortensen on 4/10/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import UIKit

class TopicViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UITextFieldDelegate {
    
    //==============================================================
    // MARK: - IBOutlets
    //==============================================================
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var addButtonTapped: UIButton!
    @IBOutlet var swipeGesture: UISwipeGestureRecognizer!
    
    //==============================================================
    // MARK: - Properties
    //==============================================================
    var currentUser: User?
    var cloudKitManager = CloudKitManager()
    
    //==============================================================
    // MARK: - View Life Cycle
    //==============================================================
    override func viewDidLoad() {
        super.viewDidLoad()
        
        changeViewsOnLoad()
        if let currentUser = UserController.shared.loggedInUser {
            self.currentUser = currentUser
        } else {
            codeTextField.isHidden = true
            //            constraintsWithoutUser()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        TopicController.shared.fetchTopicsForUser(completion: { (topics) in
            if topics.count == 0 {
                print("No topics were fetched for this user")
            }
            TopicController.shared.fetchTopicsForTopicOwner {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //==============================================================
    // MARK: - Data Source Function
    //==============================================================
    var sections = ["Owner", "Joined"]
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.backgroundColor = UIColor(red: 50.0/255.0, green: 50.0/255.0, blue: 50.0/255.0, alpha: 1)
        label.textColor = UIColor.white
        label.text = "O W N E R"
        label.textAlignment = .center
        
        let label2 = UILabel()
        label2.backgroundColor = UIColor(red: 50.0/255.0, green: 50.0/255.0, blue: 50.0/255.0, alpha: 1)
        label2.textColor = UIColor.white
        label2.text = "J O I N E D"
        label2.textAlignment = .center
        
        if section == 0 {
            return label
        } else {
            return label2
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "\(sections[0])"
        } else {
            return "\(sections[1])"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return TopicController.shared.userTopicsOwner.count
        } else {
            return TopicController.shared.userTopics.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "topicCell", for: indexPath)
        cell.layer.cornerRadius = 5
        cell.layer.borderColor = UIColor(red: 0.0/255.0, green: 81.0/255.0, blue: 116.0/255.0, alpha: 1.0).cgColor
        cell.layer.borderWidth = 1
        if indexPath.section == 0 {
            let topicOwner = TopicController.shared.userTopicsOwner[indexPath.row]
            cell.textLabel?.text = topicOwner.name
            cell.textLabel?.numberOfLines = 0
            
        } else {
            let topic = TopicController.shared.userTopics[indexPath.row]
            cell.textLabel?.text = topic.name
            cell.textLabel?.numberOfLines = 0
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "toShowTopic" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            if indexPath.section == 0 {
                guard let destinationViewController = segue.destination as? QueueViewController else {return}
                let topic = TopicController.shared.userTopicsOwner[indexPath.row]
                destinationViewController.topic = topic
            }
            if indexPath.section == 1 {
                guard let destinationViewController = segue.destination as? QueueViewController else {return}
                let topic = TopicController.shared.userTopics[indexPath.row]
                destinationViewController.topic = topic
            }
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let topic = TopicController.shared.userTopicsOwner[indexPath.row]
            guard let index = TopicController.shared.userTopicsOwner.index(of: topic) else { return }
            TopicController.shared.userTopicsOwner.remove(at: index)
            guard let topicRecordID = topic.recordID else { return }
            TopicController.shared.delete(topic: topic, withRecordID: topicRecordID, completion: {
            })
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        }
        if indexPath.section == 1 {
            let topic = TopicController.shared.userTopics[indexPath.row]
            guard let topicRecordID = topic.recordID else { return }
            TopicController.shared.delete(topic: topic, withRecordID: topicRecordID, completion: {
            })
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    //==============================================================
    // MARK: - IBActions
    //==============================================================
    @IBAction func profileImageButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction func addTopicButtonTapped(_ sender: Any) {
        QuestionController.shared.questions = []
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        guard let codeString = codeTextField.text else { return }
        guard let code = Int(codeString) else { return }
        TopicController.shared.addUserToTopic(withCode: code, completion: {
            DispatchQueue.main.async {
                self.codeTextField.text = ""
                self.codeTextField.resignFirstResponder()
                self.tableView.reloadData()
            }
        })
    }
    
    //==============================================================
    // MARK: - Constraints
    //==============================================================
    func constraintsWithoutUser() {
        codeTextField.isHidden = true
        let submitButtonHorizontalContraint = NSLayoutConstraint(item: submitButton, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0)
        view.addConstraint(submitButtonHorizontalContraint)
    }
    
    func constraintsAfterSave() {
        codeTextField.isHidden = false
    }

    //==============================================================
    // MARK: - Helper Function
    //==============================================================
    func changeViewsOnLoad() {
        self.submitButton.layer.cornerRadius = 5
        self.submitButton.layer.borderWidth = 1
        self.submitButton.layer.borderColor = UIColor(white: 1.0, alpha: 0.3).cgColor
    }
}
