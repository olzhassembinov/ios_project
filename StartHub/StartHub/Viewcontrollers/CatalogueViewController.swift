//
//  CatalogueViewController.swift
//  StartHub
//
//  Created by Adlet Trum on 16.12.2025.
//

import UIKit
import Kingfisher

class CatalogueViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var emptyStateLabel: UILabel!
    
    // MARK: - Properties
    private var projects: [Project] = []
    private var filteredProjects: [Project] = []
    private var isSearching: Bool = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        loadProjects()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "Projects"
        
        // Hide empty state initially
        emptyStateLabel.isHidden = true
        
        // Optional: Add refresh control
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshProjects), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        // Register custom cell
        let nib = UINib(nibName: "ProjectTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "ProjectCell")
        
        // Auto layout for cells
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
    }
    
    
    // MARK: - Load Projects
    private func loadProjects() {
        // Show loading
        activityIndicator.startAnimating()
        emptyStateLabel.isHidden = true
        
        ProjectService.shared.getAllProjects { [weak self] result in
            guard let self = self else { return }
            
            self.activityIndicator.stopAnimating()
            self.tableView.refreshControl?.endRefreshing()
            
            switch result {
            case .success(let response):
                self.projects = response.results
                self.filteredProjects = response.results
                
                if self.projects.isEmpty {
                    self.emptyStateLabel.isHidden = false
                    self.emptyStateLabel.text = "No projects available"
                } else {
                    self.tableView.reloadData()
                }
                
            case .failure(let error):
                print("❌ Failed to load projects: \(error.localizedDescription)")
                self.showErrorAlert(message: error.localizedDescription)
            }
        }
    }
    
    @objc private func refreshProjects() {
        loadProjects()
    }
    
    // MARK: - Helper Methods
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.loadProjects()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    private func getDisplayProjects() -> [Project] {
        return isSearching ? filteredProjects : projects
    }
}

// MARK: - UITableViewDataSource
extension CatalogueViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getDisplayProjects().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectCell", for: indexPath) as? ProjectTableViewCell else {
            return UITableViewCell()
        }
        
        let project = getDisplayProjects()[indexPath.row]
        cell.configure(with: project)
        
        return cell
    }
    }

    // MARK: - UITableViewDelegate
    extension CatalogueViewController: UITableViewDelegate {
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            
            let project = getDisplayProjects()[indexPath.row]
            navigateToProjectDetail(project: project)
        }
        
        private func navigateToProjectDetail(project: Project) {
            let storyboard = UIStoryboard(name: "Catalogue", bundle: nil)
            guard let detailVC = storyboard.instantiateViewController(withIdentifier: "ProjectDetailViewController") as? ProjectDetailViewController else {
                print("❌ Could not instantiate ProjectDetailViewController")
                return
            }
            
            detailVC.projectId = project.id
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
