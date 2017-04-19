//
//  ProfileViewController.swift
//  Q&A
//
//  Created by Sterling Mortensen on 4/10/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    //==============================================================
    // MARK: - IBOutlets
    //==============================================================
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var editButtonTapped: UIButton!
    @IBOutlet weak var addButtonTapped: UIButton!
    
    //==============================================================
    // MARK: - Properties
    //==============================================================
    var currentUser: User? {
        didSet {
            if !isViewLoaded {
                loadViewIfNeeded()
            }
            DispatchQueue.main.async {
                self.updateView()
            }
        }
    }
    
    var cloudKitManager = CloudKitManager()
    var isEditingProfile = false
    //==============================================================
    // MARK: - View Life Cycle
    //==============================================================
    override func viewDidLoad() {
        super.viewDidLoad()
        changeViewsOnLoad()
        pictureFrameCircular()
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
            guard let topicRecordID = topic.recordID else { return }
            TopicController.shared.delete(withRecordID: topicRecordID, completion: {
            })
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        if indexPath.section == 1 {
            let topic = TopicController.shared.userTopics[indexPath.row]
            guard let topicRecordID = topic.recordID else { return }
            TopicController.shared.delete(withRecordID: topicRecordID, completion: {
            })
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    //==============================================================
    // MARK: - IBActions
    //==============================================================
    @IBAction func editButtonTapped(_ sender: Any) {
        isEditingProfile = true
        updateView()
    }
    
    @IBAction func addTopicButtonTapped(_ sender: Any) {
        QuestionController.shared.questions = []
    }
    
    @IBAction func addPhotoButtonTapped(_ sender: Any) {
        firstNameTextField.resignFirstResponder()
        lastNameTextField.resignFirstResponder()
        addPhotoActionSheet()
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        if isEditingProfile  {
            guard let currentUser = currentUser, let firstName = firstNameTextField.text, let lastName = lastNameTextField.text, let profileImage = profileImageView.image  else { return }
            if let imageData = UIImageJPEGRepresentation(profileImage, 1.0) {
                currentUser.firstName = firstName
                currentUser.lastName = lastName
                currentUser.profileImageData = imageData
                isEditingProfile = false
                updateView()
                UserController.shared.modifyUser(user: currentUser, completion: {
                })
                //            DispatchQueue.main.async {
                //                self.updateView()
                //            }
            }
        } else if currentUser != nil {
            guard let codeString = codeTextField.text else { return }
            guard let code = Int(codeString) else { return }
            TopicController.shared.addUserToTopic(withCode: code, completion: {
                DispatchQueue.main.async {
                    self.codeTextField.text = ""
                    self.codeTextField.resignFirstResponder()
                    self.tableView.reloadData()
                }
            })
        } else {
            guard let firstName = firstNameTextField.text,
                let lastName = lastNameTextField.text,
                let profileImage = profileImageView.image  else { return }
            if let imageData = UIImageJPEGRepresentation(profileImage, 1.0) {
                UserController.shared.saveUser(firstName: firstName, lastName: lastName, imageData: imageData, completion: { (user) in
                    DispatchQueue.main.async {
                        self.currentUser = user
                        TopicController.shared.currentUser = user
                        self.codeTextField.isHidden = false
                        self.updateView()
                        //                    self.constraintsAfterSave()
                    }
                })
            }
        }
    }
    
    //==============================================================
    // MARK: - Image Picker Delegate Functions
    //==============================================================
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        profileImageView.image = selectedImage
        addPhotoButton.setTitle("", for: .normal)
        dismiss(animated: true, completion: nil)
    }
    
    //==============================================================
    // MARK: - Text Field Delegate
    //==============================================================
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
    // MARK: - Action Sheet
    //==============================================================
    func addPhotoActionSheet() {
        let actionController = UIAlertController(title: "Upload Photo", message: nil, preferredStyle: .actionSheet)
        let uploadAction = UIAlertAction(title: "Photo Library", style: .default) { (_) in
            self.uploadButton()
        }
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (_) in
            self.cameraButton()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary)  &&  UIImagePickerController.isSourceTypeAvailable(.camera){
            actionController.addAction(uploadAction)
            actionController.addAction(cameraAction)
        } else if UIImagePickerController.isSourceTypeAvailable(.camera) {
            actionController.addAction(cameraAction)
        } else if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            actionController.addAction(uploadAction)
        }
        actionController.addAction(cancelAction)
        present(actionController, animated: true, completion: nil)
    }
    
    //==============================================================
    // MARK: - Helper Function
    //==============================================================
    func updateView() {
        if isEditingProfile {
            firstNameTextField.borderStyle = .roundedRect
            firstNameTextField.isEnabled = true
            lastNameTextField.borderStyle = .roundedRect
            lastNameTextField.isEnabled = true
            addPhotoButton.isHidden = false
            addPhotoButton.setTitle("", for: .normal)
        } else {
            guard let currentUser = currentUser else { return }
            firstNameTextField.text = currentUser.firstName
            lastNameTextField.text = currentUser.lastName
            profileImageView.image = currentUser.profileImage
                self.firstNameTextField.borderStyle = .none
                self.firstNameTextField.backgroundColor = UIColor.clear
                self.firstNameTextField.isEnabled = false
                self.firstNameTextField.textColor = UIColor.white
                self.lastNameTextField.borderStyle = .none
                self.lastNameTextField.backgroundColor = UIColor.clear
                self.lastNameTextField.textColor = UIColor.white
                self.lastNameTextField.isEnabled = false
                self.addPhotoButton.isHidden = true
        }
    }
    
    func changeViewsOnLoad() {
        self.submitButton.layer.cornerRadius = 5
        self.submitButton.layer.borderWidth = 1
        self.submitButton.layer.borderColor = UIColor(white: 1.0, alpha: 0.3).cgColor
        self.editButtonTapped.layer.cornerRadius = 5
        self.editButtonTapped.layer.borderWidth = 1
        self.editButtonTapped.layer.borderColor = UIColor(white: 1.0, alpha: 0.3).cgColor
    }
    
    //==============================================================
    // MARK: - Functions for uploading image or camera
    //==============================================================
    func uploadButton() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func cameraButton() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .camera
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func addPhotoAlert() {
        let alertController = UIAlertController(title: "WARNING!", message: "Must add photo", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .cancel) { (_) in
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func pictureFrameCircular() {
        profileImageView.layer.cornerRadius = profileImageView.frame.size.height / 2
        profileImageView.layer.borderWidth = 1
        profileImageView.layer.borderColor = UIColor.clear.cgColor
        profileImageView.clipsToBounds = true
    }
}
