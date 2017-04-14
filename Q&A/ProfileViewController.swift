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
        if let currentUser = UserController.shared.loggedInUser {
            self.currentUser = currentUser
        } else {
//            constraintsWithoutUser()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        TopicController.shared.fetchTopicsForUser(completion: { (topics) in
            if topics.count == 0 {
                print("No topics was fetched for this user")
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }
    
    //==============================================================
    // MARK: - Data Source Function
    //==============================================================
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TopicController.shared.userTopics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "topicCell", for: indexPath)
        let topic = TopicController.shared.userTopics[indexPath.row]
        cell.textLabel?.text = topic.name
        return cell
    }
 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "toShowTopic" {
            guard let destinationViewController = segue.destination as? QueueViewController,
                let indexPath = tableView.indexPathForSelectedRow else {return}
            let topic = TopicController.shared.userTopics[indexPath.row]
            destinationViewController.topic = topic
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
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
        
        firstNameTextField.borderStyle = .bezel
        firstNameTextField.isEnabled = true
        lastNameTextField.borderStyle = .bezel
        lastNameTextField.isEnabled = true
        addPhotoButton.isHidden = false
        isEditingProfile = true
    }
    
    @IBAction func addTopicButtonTapped(_ sender: Any) {
        
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
            UserController.shared.modifyUser(user: currentUser, completion: {
            })
            DispatchQueue.main.async {
                self.updateView()
            }
            isEditingProfile = false
            }
        } else if currentUser != nil {
            guard let codeString = codeTextField.text else { return }
            guard let code = Int(codeString) else { return }
            TopicController.shared.addUserToTopic(withCode: code, completion: {
                DispatchQueue.main.async {
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
        guard let currentUser = currentUser else { return }
        firstNameTextField.text = currentUser.firstName
        lastNameTextField.text = currentUser.lastName
        profileImageView.image = currentUser.profileImage
        firstNameTextField.borderStyle = .none
        firstNameTextField.isEnabled = false
        lastNameTextField.borderStyle = .none
        lastNameTextField.isEnabled = false
        addPhotoButton.isHidden = true
        
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
}
