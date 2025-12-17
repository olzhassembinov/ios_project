//
//  EditProfileViewController.swift
//  StartHub
//
//  Created by Олжас Сембинов on 18.12.2025.
//
//
//  EditProfileViewController.swift
//  StartHub
//
//  Created by Person 1
//

import UIKit

class EditProfileViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    var currentUser: User?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        populateFields()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "Edit Profile"
        
        // Make email read-only
        emailTextField.isUserInteractionEnabled = false
        emailTextField.textColor = .gray
        
        // Style save button
        saveButton.layer.cornerRadius = 8
        saveButton.clipsToBounds = true
    }
    
    private func populateFields() {
        guard let user = currentUser else { return }
        
        nameTextField.text = user.name
        surnameTextField.text = user.surname
        emailTextField.text = user.email
    }
    
    // MARK: - IBActions
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        view.endEditing(true)
        
        guard let name = nameTextField.text, !name.isEmpty else {
            showAlert(message: "Name cannot be empty")
            return
        }
        
        guard let surname = surnameTextField.text, !surname.isEmpty else {
            showAlert(message: "Surname cannot be empty")
            return
        }
        
        // Show loading
        activityIndicator.startAnimating()
        saveButton.isEnabled = false
        
        // Update profile
        ProfileService.shared.updateProfile(
            name: name,
            surname: surname,
            email: nil  // Don't update email
        ) { [weak self] result in
            guard let self = self else { return }
            
            self.activityIndicator.stopAnimating()
            self.saveButton.isEnabled = true
            
            switch result {
            case .success(let updatedUser):
                print("✅ Profile updated successfully!")
                self.showSuccessAndGoBack()
                
            case .failure(let error):
                print("❌ Update failed: \(error.localizedDescription)")
                self.showAlert(message: error.localizedDescription)
            }
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Helper Methods
    private func showSuccessAndGoBack() {
        let alert = UIAlertController(
            title: "Success",
            message: "Profile updated successfully!",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        
        present(alert, animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
