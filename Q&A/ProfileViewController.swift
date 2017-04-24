//
//  ProfileViewController.swift
//  Q&A
//
//  Created by Sterling Mortensen on 4/21/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        if let currentUser = UserController.shared.loggedInUser {
            self.currentUser = currentUser
        }
    }
    
    //==============================================================
    // MARK: - Properties
    //==============================================================
    var isEditingProfile = false
    var currentUser: User? {
        didSet {
            updateView()
        }
    }
    
    //==============================================================
    // MARK: - IBOutlets
    //==============================================================
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var addProfileImage: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var updateButton: UIButton!

    //==============================================================
    // MARK: - IBActions
    //==============================================================
    @IBAction func addProfileImageButtonTapped(_ sender: Any) {
        firstNameTextField.resignFirstResponder()
        lastNameTextField.resignFirstResponder()
        addPhotoActionSheet()
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func updateButtonTapped(_ sender: Any) {
        firstNameTextField.resignFirstResponder()
        lastNameTextField.resignFirstResponder()
        guard let user = currentUser, let firstname = self.firstNameTextField.text, let lastname = lastNameTextField.text, let image = profileImage.image else { return }
        user.firstName = firstname
        user.lastName = lastname
        guard let imageData = UIImageJPEGRepresentation(image, 1.0) else { return }
        user.profileImageData = imageData
        UserController.shared.modifyUser(user: user) {
           self.dismiss(animated: true, completion: nil)
        }
    }

    //==============================================================
    // MARK: - View Functions
    //==============================================================
    func updateView() {
        guard let currentUser = currentUser else { return }
        firstNameTextField.text = currentUser.firstName
        lastNameTextField.text = currentUser.lastName
        profileImage.image = currentUser.profileImage
        profileImage.layer.cornerRadius = profileImage.frame.size.height / 2
        profileImage.layer.borderWidth = 1
        profileImage.layer.borderColor = UIColor.clear.cgColor
        profileImage.clipsToBounds = true
        self.doneButton.layer.cornerRadius = 5
        self.doneButton.layer.borderWidth = 1
        self.doneButton.layer.borderColor = UIColor(white: 1.0, alpha: 0.3).cgColor
        self.updateButton.layer.cornerRadius = 5
        self.updateButton.layer.borderWidth = 1
        self.updateButton.layer.borderColor = UIColor(white: 1.0, alpha: 0.3).cgColor
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if firstNameTextField.isFirstResponder {
            lastNameTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    //==============================================================
    // MARK: - Upload Image Functions
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
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        profileImage.image = selectedImage
        addProfileImage.setTitle("", for: .normal)
        dismiss(animated: true, completion: nil)
    }
}
