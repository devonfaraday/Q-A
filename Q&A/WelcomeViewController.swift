//
//  WelcomeViewController.swift
//  Q&A
//
//  Created by Hayden Hastings on 4/24/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var welcomeTextView: UITextView!
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var addProfileImage: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pictureFrameCircular()
        firstNameTextField.attributedPlaceholder = NSAttributedString(string: "First Name:", attributes: [NSForegroundColorAttributeName: UIColor.white])
        lastNameTextField.attributedPlaceholder = NSAttributedString(string: "Last Name:", attributes: [NSForegroundColorAttributeName: UIColor.white])
        firstNameBorderWhite()
        lastNameBoarderWhite()
        nextButtonBoarderWhite()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        UITextView.transition(with: welcomeTextView, duration: 1.1, options: .transitionCurlDown, animations: {
            self.welcomeTextView.textColor = .white
        }, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if firstNameTextField.resignFirstResponder() {
            lastNameTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    // MARK: - IBActions
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        firstNameTextField.resignFirstResponder()
        lastNameTextField.resignFirstResponder()
        guard let firstName = self.firstNameTextField.text,
            let lastName = self.lastNameTextField.text,
            let image = pictureImageView.image,
            !firstName.isEmpty,
            !lastName.isEmpty
            else { addPhotoAlert(); return }
        if let imageData = UIImageJPEGRepresentation(image, 1.0) {
            UserController.shared.saveUser(firstName: firstName, lastName: lastName, imageData: imageData, completion: { (_) in
                print("Done Saving")
            })
        }
    }
    @IBAction func addImageButtonTapped(_ sender: Any) {
        firstNameTextField.resignFirstResponder()
        lastNameTextField.resignFirstResponder()
        addPhotoActionSheet()
    }
    
    // MARK: - Upload Image functions
    
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
        let alertController = UIAlertController(title: "WARNING!", message: "Please fill out all sections.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .cancel) { (_) in
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func pictureFrameCircular() {
        pictureImageView.layer.cornerRadius = pictureImageView.frame.size.height / 2
        pictureImageView.layer.borderWidth = 1
        pictureImageView.layer.borderColor = UIColor.clear.cgColor
        pictureImageView.clipsToBounds = true
        self.pictureImageView.layer.borderColor = UIColor(white: 1.0, alpha: 0.3).cgColor
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
        pictureImageView.image = selectedImage
        addProfileImage.setTitle("", for: .normal)
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Boarder Colors
    
    func firstNameBorderWhite() {
        self.firstNameTextField.layer.cornerRadius = 5
        self.firstNameTextField.layer.borderWidth = 1
        self.firstNameTextField.layer.borderColor = UIColor(white: 1.0, alpha: 0.3).cgColor
    }
    
    func lastNameBoarderWhite() {
        self.lastNameTextField.layer.cornerRadius = 5
        self.lastNameTextField.layer.borderWidth = 1
        self.lastNameTextField.layer.borderColor = UIColor(white: 1.0, alpha: 0.3).cgColor
    }
    
    func nextButtonBoarderWhite() {
        self.nextButton.layer.cornerRadius = 5
        self.nextButton.layer.borderWidth = 1
        self.nextButton.layer.borderColor = UIColor(white: 1.0, alpha: 0.3).cgColor
    }
}
