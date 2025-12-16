//
//  StartupCardCell.swift
//  StartHub
//
//  Created by Adlet Trum on 16.12.2025.
//

import UIKit
import Kingfisher

final class StartupCardCell: UICollectionViewCell {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var infoContainerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true

        photoImageView.contentMode = .scaleAspectFill
        photoImageView.clipsToBounds = true

        infoContainerView.backgroundColor = .systemBackground

    }

    func configure(with viewModel: CatalogCardViewModel) {
        titleLabel.text = viewModel.title
        authorLabel.text = viewModel.authorName
        descriptionLabel.text = viewModel.description

        if let url = viewModel.imageURL {
            photoImageView.kf.setImage(
                with: url,
                placeholder: UIImage(systemName: "photo")
            )
        } else {
            photoImageView.image = UIImage(systemName: "photo")
        }
    }
}
