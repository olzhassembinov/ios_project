//
//  MyProjectsViewController.swift
//  StartHub
//
//  Created by Олжас Сембинов on 18.12.2025.
//
//
//  MyProjectsViewController.swift
//  StartHub
//
//  Created by Person 1
//

import UIKit

class MyProjectsViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var emptyStateLabel: UILabel!
    
    // MARK: - Properties
    private var projects: [Project] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        loadProjects()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "My Projects"
        emptyStateLabel.isHidden = true
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        
        // Register cell (if using custom XIB)
        // let nib = UINib(nibName: "MyProjectCell", bundle: nil)
        // tableView.register(nib, forCellReuseIdentifier: "MyProjectCell")
    }
    
    // MARK: - Load Projects
    private func loadProjects() {
        activityIndicator.startAnimating()
        emptyStateLabel.isHidden = true
        
        ProfileService.shared.getMyProjects { [weak self] result in
            guard let self = self else { return }
            
            self.activityIndicator.stopAnimating()
            
            switch result {
            case .success(let response):
                self.projects = response.results
                
                if self.projects.isEmpty {
                    self.emptyStateLabel.isHidden = false
                    self.emptyStateLabel.text = "You haven't created any projects yet."
                } else {
                    self.tableView.reloadData()
                }
                
            case .failure(let error):
                print("❌ Failed to load projects: \(error.localizedDescription)")
                self.showAlert(message: "Failed to load projects. Please try again.")
            }
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension MyProjectsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Using basic cell for simplicity - you can create custom cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "ProjectCell")
        
        let project = projects[indexPath.row]
        cell.textLabel?.text = project.title
        cell.detailTextLabel?.text = project.description
        cell.detailTextLabel?.numberOfLines = 2
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension MyProjectsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let project = projects[indexPath.row]
        print("Selected project: \(project.title)")
        
        // TODO: Navigate to project detail (Person 2's screen)
        // You can coordinate with Person 2 to show project details
    }
}
