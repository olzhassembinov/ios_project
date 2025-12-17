//
//  ProjectTableViewCell.swift
//  StartHub
//
//  Created by Adlet Trum on 16.12.2025.
//

import UIKit
import Kingfisher

class ProjectTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var projectImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        // Round corners on image
        projectImageView.layer.cornerRadius = 8
        projectImageView.clipsToBounds = true
        
    }
    
    // MARK: - Configure
    func configure(with project: Project) {
        // Set title
        titleLabel.text = project.title
        
        // Set author
        if let creatorName = project.creator?.name {
            authorLabel.text = "by \(creatorName)"
        } else {
            authorLabel.text = "by Unknown"
        }
        
        // Set description (snippet - first 100 chars)
        if let description = project.description {
            let snippet = String(description.prefix(100))
            descriptionLabel.text = snippet + (description.count > 100 ? "..." : "")
        } else {
            descriptionLabel.text = "No description available"
        }
        
        
        // Load project image
        if let images = project.images, let firstImage = images.first {
            loadImage(from: firstImage.filePath)
        } else {
            projectImageView.image = UIImage(systemName: "photo")
            projectImageView.tintColor = .gray
        }
    }
    
    private func loadImage(from urlString: String) {
        // Simple image loading
        guard let url = URL(string: urlString) else {
            projectImageView.image = UIImage(systemName: "photo")
            return
        }
        
        // Load image asynchronously
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    self?.projectImageView.image = UIImage(systemName: "photo")
                }
                return
            }
            
            DispatchQueue.main.async {
                self?.projectImageView.image = image
            }
        }.resume()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        projectImageView.image = nil
        titleLabel.text = nil
        authorLabel.text = nil
        descriptionLabel.text = nil
    }
}
