//
//  LoginViewController.swift
//  StartHub
//
//  Created by Олжас Сембинов on 17.12.2025.
//
//
//  LoginViewController.swift
//  StartHub
//
//  Created by Person 1
//

import UIKit

class LoginViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
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
        // Hide navigation bar
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Style login button
        loginButton.layer.cornerRadius = 8
        loginButton.clipsToBounds = true
        
        // Hide error label initially
        errorLabel.isHidden = true
        
        // Style text fields (optional)
        emailTextField.layer.cornerRadius = 8
        emailTextField.layer.borderWidth = 1
        emailTextField.layer.borderColor = UIColor.lightGray.cgColor
        emailTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        emailTextField.leftViewMode = .always
        
        passwordTextField.layer.cornerRadius = 8
        passwordTextField.layer.borderWidth = 1
        passwordTextField.layer.borderColor = UIColor.lightGray.cgColor
        passwordTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        passwordTextField.leftViewMode = .always
    }
    
    private func setupTextFieldDelegates() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    // MARK: - IBActions
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        // Dismiss keyboard
        view.endEditing(true)
        
        // Validate inputs
        guard let email = emailTextField.text, !email.isEmpty else {
            showError("Please enter your email")
            return
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            showError("Please enter your password")
            return
        }
        
        // Validate email format
        if !isValidEmail(email) {
            showError("Please enter a valid email address")
            return
        }
        
        // Show loading state
        setLoadingState(true)
        
        // Call login API
        AuthManager.shared.login(email: email, password: password) { [weak self] result in
            guard let self = self else { return }
            
            self.setLoadingState(false)
            
            switch result {
            case .success(let response):
                print("✅ Login successful! Token: \(response.accessToken)")
                self.navigateToMainApp()
                
            case .failure(let error):
                print("❌ Login failed: \(error.localizedDescription)")
                self.showError(error.localizedDescription)
            }
        }
    }
    
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        // Navigate to Registration screen
        let storyboard = UIStoryboard(name: "Auth", bundle: nil)
        let registerVC = storyboard.instantiateViewController(withIdentifier: "RegistrationViewController")
        navigationController?.pushViewController(registerVC, animated: true)
    }
    
    // MARK: - Helper Methods
    private func setLoadingState(_ loading: Bool) {
        if loading {
            activityIndicator.startAnimating()
            loginButton.isEnabled = false
            registerButton.isEnabled = false
            loginButton.alpha = 0.6
            errorLabel.isHidden = true
        } else {
            activityIndicator.stopAnimating()
            loginButton.isEnabled = true
            registerButton.isEnabled = true
            loginButton.alpha = 1.0
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
    
    private func navigateToMainApp() {
        // Navigate to main TabBar controller
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        guard let tabBarVC = mainStoryboard.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController else {
            print("❌ Error: Could not instantiate MainTabBarController")
            return
        }
        
        // Set as root view controller
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.window?.rootViewController = tabBarVC
            sceneDelegate.window?.makeKeyAndVisible()
            
            // Optional: Add transition animation
            UIView.transition(with: sceneDelegate.window!, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
        }
    }
}

// MARK: - UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            // Move to password field
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            // Trigger login
            textField.resignFirstResponder()
            loginButtonTapped(loginButton)
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Hide error when user starts typing
        errorLabel.isHidden = true
    }
}
