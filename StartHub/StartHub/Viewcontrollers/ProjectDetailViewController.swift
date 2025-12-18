//
//  ProjectDetailViewController.swift
//  StartHub
//
//  Created by Adlet Trum on 16.12.2025.
//

import UIKit
import Kingfisher

class ProjectDetailViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var projectImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var deadlineLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var currentSumLabel: UILabel!
    @IBOutlet weak var teamMembersTableView: UITableView!
    @IBOutlet weak var socialLinksTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var teamTableHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var socialTableHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Properties
    var projectId: Int!
    private var project: Project?
    private var teamMembers: [TeamMember] = []
    private var socialLinks: [SocialLink] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableViews()
        loadProjectDetails()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "Project Details"
        
        // Hide content initially
        scrollView.alpha = 0
        
        // Style description text view
        descriptionTextView.textContainer.lineFragmentPadding = 0
        descriptionTextView.textContainerInset = .zero
    }
    
    private func setupTableViews() {
        // Team members table
        teamMembersTableView.delegate = self
        teamMembersTableView.dataSource = self
        teamMembersTableView.register(UITableViewCell.self, forCellReuseIdentifier: "TeamMemberCell")
        teamMembersTableView.isScrollEnabled = false
        
        // Social links table
        socialLinksTableView.delegate = self
        socialLinksTableView.dataSource = self
        socialLinksTableView.register(UITableViewCell.self, forCellReuseIdentifier: "SocialLinkCell")
        socialLinksTableView.isScrollEnabled = false
    }
    
    // MARK: - Load Data
    private func loadProjectDetails() {
        activityIndicator.startAnimating()
        
        ProjectService.shared.getProjectById(projectId: projectId) { [weak self] result in
            guard let self = self else { return }
            
            self.activityIndicator.stopAnimating()
            
            switch result {
            case .success(let project):
                self.project = project
                self.updateUI(with: project)
                self.loadTeamMembers()
                self.loadSocialLinks()
                
                // Show content with animation
                UIView.animate(withDuration: 0.3) {
                    self.scrollView.alpha = 1
                }
                
            case .failure(let error):
                print("❌ Failed to load project: \(error.localizedDescription)")
                self.showErrorAlert(message: error.localizedDescription)
            }
        }
    }
    
    private func updateUI(with project: Project) {
        // Title and author
        titleLabel.text = project.title
        
        if let creatorName = project.creator?.name {
            authorLabel.text = "by \(creatorName)"
        } else {
            authorLabel.text = "by Unknown"
        }
        
        // Category
        if let category = project.category {
            categoryLabel.text = "📁 \(category.name)"
        } else {
            categoryLabel.text = "📁 Uncategorized"
        }
        
        // Deadline
        if let deadline = project.deadline {
            deadlineLabel.text = "📅 \(formatDate(deadline))"
        } else {
            deadlineLabel.text = "📅 No deadline"
        }
        
        // Description
        descriptionTextView.text = project.description ?? "No description available"
        
        // Financial info
        if let currentSum = project.currentSum {
            currentSumLabel.text = "Current:tCurrency(currentSum))"
        } else {
            currentSumLabel.text = "Current: $0"
        }
        
        // Load project image
        if let images = project.images, let firstImage = images.first {
            loadImage(from: firstImage.filePath)
        } else {
            projectImageView.image = UIImage(systemName: "photo.fill")
            projectImageView.tintColor = .gray
        }
    }
    
    private func loadTeamMembers() {
        TeamMemberService.shared.getTeamMembers(projectId: projectId) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let members):
                self.teamMembers = members
                self.teamMembersTableView.reloadData()
                self.updateTeamTableHeight()
                
            case .failure(let error):
                print("❌ Failed to load team members: \(error.localizedDescription)")
            }
        }
    }
    
    private func loadSocialLinks() {
        SocialLinksService.shared.getSocialLinks(projectId: projectId) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let links):
                self.socialLinks = links
                self.socialLinksTableView.reloadData()
                self.updateSocialTableHeight()
                
            case .failure(let error):
                print("❌ Failed to load social links: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Helper Methods
    private func updateTeamTableHeight() {
        teamMembersTableView.layoutIfNeeded()
        teamTableHeightConstraint.constant = teamMembersTableView.contentSize.height
    }
    
    private func updateSocialTableHeight() {
        socialLinksTableView.layoutIfNeeded()
        socialTableHeightConstraint.constant = socialLinksTableView.contentSize.height
    }
    
    private func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else {
            projectImageView.image = UIImage(systemName: "photo.fill")
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else {
                return
            }
            
            DispatchQueue.main.async {
                self?.projectImageView.image = image
            }
        }.resume()
    }
    
    private func formatDate(_ dateString: String) -> String {
        // Simple date formatting - adjust as needed
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        if let date = formatter.date(from: dateString) {
            formatter.dateFormat = "MMM dd, yyyy"
            return formatter.string(from: date)
        }
        
        return dateString
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension ProjectDetailViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == teamMembersTableView {
            return teamMembers.count
        } else if tableView == socialLinksTableView {
            return socialLinks.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == teamMembersTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TeamMemberCell", for: indexPath)
            let member = teamMembers[indexPath.row]
            
            cell.textLabel?.text = "\(member.name) \(member.surname ?? "")"
            cell.detailTextLabel?.text = member.role
            
            return cell
            
        } else if tableView == socialLinksTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SocialLinkCell", for: indexPath)
            let link = socialLinks[indexPath.row]
            
            cell.textLabel?.text = link.platform
            cell.detailTextLabel?.text = link.url
            cell.accessoryType = .disclosureIndicator
            
            return cell
        }
        
        return UITableViewCell()
    }
}

// MARK: - UITableViewDelegate
extension ProjectDetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if tableView == socialLinksTableView {
            let link = socialLinks[indexPath.row]
            
            // Open URL in Safari
            if let url = URL(string: link.url) {
                UIApplication.shared.open(url)
            }
        }
    }
}
