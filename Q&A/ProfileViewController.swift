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
    }
    
    //==============================================================
    // MARK: - Properties
    //==============================================================
    var isEditingProfile = false
    var currentUser: User?
    
    //==============================================================
    // MARK: - IBOutlets
    //==============================================================
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var addProfileImage: UIButton!
    
    //==============================================================
    // MARK: - IBActions
    //==============================================================
    @IBAction func addProfileImageButtonTapped(_ sender: Any) {
        firstNameTextField.resignFirstResponder()
        lastNameTextField.resignFirstResponder()
        addPhotoActionSheet()
    }
    
    @IBAction func editButtonTapped(_ sender: Any) {
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func updateView() {
        if isEditingProfile {
            firstNameTextField.borderStyle = .roundedRect
            firstNameTextField.isEnabled = true
            lastNameTextField.borderStyle = .roundedRect
            lastNameTextField.isEnabled = true
            addProfileImage.isHidden = false
            addProfileImage.setTitle("", for: .normal)
        } else {
            guard let currentUser = currentUser else { return }
            firstNameTextField.text = currentUser.firstName
            lastNameTextField.text = currentUser.lastName
            profileImage.image = currentUser.profileImage
            self.firstNameTextField.borderStyle = .none
            self.firstNameTextField.backgroundColor = UIColor.clear
            self.firstNameTextField.isEnabled = false
            self.firstNameTextField.textColor = UIColor.white
            self.lastNameTextField.borderStyle = .none
            self.lastNameTextField.backgroundColor = UIColor.clear
            self.lastNameTextField.textColor = UIColor.white
            self.lastNameTextField.isEnabled = false
            self.addProfileImage.isHidden = true
        }
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
    
    func pictureFrameCircular() {
        profileImage.layer.cornerRadius = profileImage.frame.size.height / 2
        profileImage.layer.borderWidth = 1
        profileImage.layer.borderColor = UIColor.clear.cgColor
        profileImage.clipsToBounds = true
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
