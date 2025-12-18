//
//  ProfileViewController.swift
//  StartHub
//
//  Created by Олжас Сембинов on 18.12.2025.
//
//
//  ProfileViewController.swift
//  StartHub
//
//  Created by Person 1
//

import UIKit

class ProfileViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var roleLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    private var currentUser: User?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadUserProfile()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Reload profile when coming back from edit
        loadUserProfile()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "Profile"
        
        // Style profile image
        profileImageView.layer.cornerRadius = 50
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.backgroundColor = .systemGray5
    }
    
    // MARK: - Load Profile
    private func loadUserProfile() {
        activityIndicator.startAnimating()
        
        ProfileService.shared.getCurrentUserProfile { [weak self] result in
            guard let self = self else { return }
            
            self.activityIndicator.stopAnimating()
            
            switch result {
            case .success(let user):
                self.currentUser = user
                self.updateUI(with: user)
                
            case .failure(let error):
                print("❌ Failed to load profile: \(error.localizedDescription)")
                self.showErrorAlert(message: "Failed to load profile. Please try again.")
            }
        }
    }
    
    private func updateUI(with user: User) {
        // Update labels
        nameLabel.text = "\(user.name ?? "") \(user.surname ?? "")".trimmingCharacters(in: .whitespaces)
        
        if nameLabel.text?.isEmpty == true {
            nameLabel.text = user.firstName ?? "User"
        }
        
        emailLabel.text = user.email
        
        // Update role
        if let roles = user.roles, !roles.isEmpty {
            let roleNames = roles.map { $0.name }.joined(separator: ", ")
            roleLabel.text = "Role: \(roleNames)"
        } else {
            roleLabel.text = "Role: Member"
        }
        
        // Load profile picture if available
        if let pictureURLString = user.picture, let url = URL(string: pictureURLString) {
            loadProfileImage(from: url)
        }
    }
    
    private func loadProfileImage(from url: URL) {
        // Simple image loading (you can use Kingfisher library for better performance)
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else {
                return
            }
            
            DispatchQueue.main.async {
                self?.profileImageView.image = image
            }
        }.resume()
    }
    
    // MARK: - IBActions
    @IBAction func editProfileTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        guard let editVC = storyboard.instantiateViewController(withIdentifier: "EditProfileViewController") as? EditProfileViewController else {
            return
        }
        
        editVC.currentUser = currentUser
        navigationController?.pushViewController(editVC, animated: true)
    }
    
    @IBAction func myProjectsTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        guard let projectsVC = storyboard.instantiateViewController(withIdentifier: "MyProjectsViewController") as? MyProjectsViewController else {
            return
        }
        
        navigationController?.pushViewController(projectsVC, animated: true)
    }
    
    @IBAction func logoutTapped(_ sender: UIButton) {
        let alert = UIAlertController(
            title: "Logout",
            message: "Are you sure you want to logout?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive) { [weak self] _ in
            self?.performLogout()
        })
        
        present(alert, animated: true)
    }
    
    private func performLogout() {
        activityIndicator.startAnimating()
        
        AuthManager.shared.logout { [weak self] result in
            guard let self = self else { return }
            
            self.activityIndicator.stopAnimating()
            
            // Navigate to login regardless of server response
            // (tokens are already cleared)
            self.navigateToLogin()
        }
    }
    
    private func navigateToLogin() {
        let authStoryboard = UIStoryboard(name: "Auth", bundle: nil)
        guard let loginVC = authStoryboard.instantiateInitialViewController() else {
            return
        }
        
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.window?.rootViewController = loginVC
            sceneDelegate.window?.makeKeyAndVisible()
            
            UIView.transition(with: sceneDelegate.window!, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
        }
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
