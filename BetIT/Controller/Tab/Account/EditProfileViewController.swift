//
//  EditProfileViewController.swift
//  BetIT
//
//  Created by OSX on 7/31/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import UIKit
import CoreServices
import IQKeyboardManagerSwift

class EditProfileViewController: BaseViewController {
    private var imagePicker: UIImagePickerController!
    private var nextTextFieldMap: [UITextField: UITextField]!
    var viewModel: EditProfileViewModel!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var profilePhotoButton: UIButton!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var phoneNumberField: UITextField!
    @IBOutlet weak var zipCodeField: UITextField!
    @IBOutlet weak var venmoPayPalField: UITextField!
    @IBOutlet weak var venmoButton: UIButton!
    @IBOutlet weak var paypalButton: UIButton!
    @IBOutlet weak var currentPaymentHandleButton: UIButton!
    @IBOutlet weak var currentPaymentHandleImageView: UIImageView!
    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var venmoPayPalContainerView: UIView!
    @IBOutlet weak var initialNameLabel: UILabel!
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setup()
        bind()
        loadUser()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - Helpers
    
    private func bind() {
        viewModel.didSetPaymentHandle = { [weak self] in
            guard let strongSelf = self else { return }
            if strongSelf.viewModel.payment == .venmo {
                strongSelf.venmoPayPalContainerView.isHidden = true
                strongSelf.venmoPayPalField.text = strongSelf.viewModel.venmoUserName
                strongSelf.currentPaymentHandleButton.setTitle("Venmo", for: .normal)
            } else {
                strongSelf.venmoPayPalContainerView.isHidden = true
                strongSelf.venmoPayPalField.text = strongSelf.viewModel.paypalUserName
                strongSelf.currentPaymentHandleButton.setTitle("Paypal", for: .normal)
            }
        }
        
        viewModel.showError =  { [weak self] errorStr in
            self?.showAlert(errorStr)
        }
        
        viewModel.didUpdateData = { [weak self] in
            DispatchQueue.main.async {
                self?.showSavedAnimation()
            }
        }
    }

    private func setup() {
        // Profile pic
        profilePicImageView.layer.cornerRadius = min(profilePicImageView.frame.width, profilePicImageView.frame.height) / CGFloat(2.0)
        profilePicImageView.clipsToBounds = true
        
        // Venmo / paypal
        venmoPayPalContainerView.layer.cornerRadius = CGFloat(5.0)
        venmoPayPalContainerView.isHidden = true
        venmoPayPalContainerView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        venmoPayPalContainerView.layer.shadowColor = UIColor.black.cgColor
        venmoPayPalContainerView.layer.shadowOpacity = 0.7
        venmoPayPalContainerView.layer.shadowRadius = 4.0
        
        // Image picker
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = [kUTTypeImage as String]
        
        // Text field delegate
        nameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        phoneNumberField.delegate = self
        zipCodeField.delegate = self
        venmoPayPalField.delegate = self
        
        phoneNumberField.addTarget(self,
                                   action: #selector(textFieldDidChange(_:)),
                                   for: .editingChanged)
        
       nextTextFieldMap = [
           nameField: emailField,
           emailField: passwordField,
           phoneNumberField: zipCodeField,
           zipCodeField: venmoPayPalField
       ]
    }
    
    private func loadUser() {
        if let thumbnail = viewModel.thumbnailImage {
            profilePicImageView?.sd_setImage(with: thumbnail)
            initialNameLabel.isHidden = true
        } else {
            initialNameLabel.isHidden = false
            initialNameLabel.text = viewModel.firstNameInitial
        }
        
        nameField.text = viewModel.fullName
        emailField.text = viewModel.email
        phoneNumberField.text = viewModel.phoneNumber
        zipCodeField.text = viewModel.zipCode
        
        if viewModel.payment == .venmo {
            currentPaymentHandleButton.setTitle("Venmo", for: .normal)
            venmoPayPalField.text = viewModel.venmoUserName
        } else if viewModel.payment == .paypal {
            currentPaymentHandleButton.setTitle("Paypal", for: .normal)
            venmoPayPalField.text = viewModel.paypalUserName
        }
    }

    private func showImagePicker() {
        self.imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
     
    private func showSavedAnimation() {
         let origin = CGPoint(x: (self.view.frame.width - CustomSaveView.defaultSize.width) / 2.0, y: 120)
         let savedViewFrame = CGRect(origin: origin, size: CustomSaveView.defaultSize)
         
         let savedView = CustomSaveView(frame: savedViewFrame)
         savedView.center = self.view.center
         savedView.delegate = self
         self.view.addSubview(savedView)
         savedView.startAnimation()
     }

    // MARK: - IBActions
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField == phoneNumberField {
            guard let phoneNumber = phoneNumberField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
            textField.text = phoneNumber.formattedNumber()
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        viewModel.updateUserData(fullName: nameField.text,
                                 email: emailField.text,
                                 zipCode: zipCodeField.text,
                                 phoneNumber: phoneNumberField.text,
                                 paymentHandleUsername: venmoPayPalField.text)
    }
    
    @IBAction func profilePhotoButtonPressed(_ sender: Any) {
        showImagePicker()
    }
    
    @IBAction func changePasswordButtonPressed(_ sender: Any) {
        self.resignFirstResponder()
    }
    
    @IBAction func venmoButtonPressed(_ sender: Any) {
        viewModel.setPaymentHandle(.venmo)
    }
    
    @IBAction func paypalButtonPressed(_ sender: Any) {
        viewModel.setPaymentHandle(.paypal)
    }
    
    @IBAction func currentPaymentHandleButtonPressed(_ sender: Any) {
        venmoPayPalContainerView.isHidden = false
    }
}

// MARK: - UIImagePickerControllerDelegate

extension EditProfileViewController: UIImagePickerControllerDelegate  {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = (info[UIImagePickerController.InfoKey.editedImage] ??
                     info[UIImagePickerController.InfoKey.originalImage])
        if let image = image as? UIImage {
            // Resize and cache image
            let resizedImage = image.resizeImage(size: CGSize(width: 200, height: 200))
            self.viewModel.imageData = resizedImage?.jpegData(compressionQuality: 1.0)
            profilePicImageView.image = resizedImage
            initialNameLabel.isHidden = true
        }
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITextFieldDelegate

extension EditProfileViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == passwordField {
            textField.resignFirstResponder()
            performSegue(withIdentifier: "sid_change_password", sender: nil)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = nextTextFieldMap[textField] {
            nextField.becomeFirstResponder()
        }
        return false
    }
}

// MARK: - CustomSaveViewDelegate

extension EditProfileViewController: CustomSaveViewDelegate {
    func customSaveViewAnimationDidStop(_ customSaveView: CustomSaveView) {
        self.performSegue(withIdentifier: "unwindIdentifier", sender: nil)
    }
}
