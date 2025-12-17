//
//  RegistrationViewController.swift
//  StartHub
//
//  Created by Олжас Сембинов on 18.12.2025.
//
//
//  RegistrationViewController.swift
//  StartHub
//
//  Created by Person 1
//

import UIKit

class RegistrationViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var errorLabel: UILabel!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTextFieldDelegates()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // Configure navigation bar
        title = "Register"
        
        // Style register button
        registerButton.layer.cornerRadius = 8
        registerButton.clipsToBounds = true
        
        // Hide error label
        errorLabel.isHidden = true
        
        // Style text fields
        let textFields = [nameTextField, emailTextField, passwordTextField, confirmPasswordTextField]
        textFields.forEach { textField in
            textField?.layer.cornerRadius = 8
            textField?.layer.borderWidth = 1
            textField?.layer.borderColor = UIColor.lightGray.cgColor
            textField?.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
            textField?.leftViewMode = .always
        }
    }
    
    private func setupTextFieldDelegates() {
        nameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
    }
    
    // MARK: - IBActions
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        view.endEditing(true)
        
        // Validate inputs
        guard let name = nameTextField.text, !name.isEmpty else {
            showError("Please enter your name")
            return
        }
        
        guard let email = emailTextField.text, !email.isEmpty else {
            showError("Please enter your email")
            return
        }
        
        guard isValidEmail(email) else {
            showError("Please enter a valid email address")
            return
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            showError("Please enter a password")
            return
        }
        
        guard password.count >= 8 else {
            showError("Password must be at least 8 characters")
            return
        }
        
        guard let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty else {
            showError("Please confirm your password")
            return
        }
        
        guard password == confirmPassword else {
            showError("Passwords do not match")
            return
        }
        
        // Show loading state
        setLoadingState(true)
        
        // Call register API
        AuthManager.shared.register(
            name: name,
            email: email,
            password: password,
            passwordConfirmation: confirmPassword
        ) { [weak self] result in
            guard let self = self else { return }
            
            self.setLoadingState(false)
            
            switch result {
            case .success(_):
                print("✅ Registration successful!")
                self.showSuccessAndNavigateToLogin()
                
            case .failure(let error):
                print("❌ Registration failed: \(error.localizedDescription)")
                self.showError(error.localizedDescription)
            }
        }
    }
    
    @IBAction func backToLoginTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Helper Methods
    private func setLoadingState(_ loading: Bool) {
        if loading {
            activityIndicator.startAnimating()
            registerButton.isEnabled = false
            registerButton.alpha = 0.6
            errorLabel.isHidden = true
        } else {
            activityIndicator.stopAnimating()
            registerButton.isEnabled = true
            registerButton.alpha = 1.0
        }
    }
    
    private func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
        
        // Shake animation
        let shake = CAKeyframeAnimation(keyPath: "transform.translation.x")
        shake.timingFunction = CAMediaTimingFunction(name: .linear)
        shake.duration = 0.6
        shake.values = [-20, 20, -20, 20, -10, 10, -5, 5, 0]
        errorLabel.layer.add(shake, forKey: "shake")
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func showSuccessAndNavigateToLogin() {
        let alert = UIAlertController(
            title: "Success! 🎉",
            message: "Your account has been created. Please login to continue.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension RegistrationViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case nameTextField:
            emailTextField.becomeFirstResponder()
        case emailTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            confirmPasswordTextField.becomeFirstResponder()
        case confirmPasswordTextField:
            textField.resignFirstResponder()
            registerButtonTapped(registerButton)
        default:
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        errorLabel.isHidden = true
    }
}
