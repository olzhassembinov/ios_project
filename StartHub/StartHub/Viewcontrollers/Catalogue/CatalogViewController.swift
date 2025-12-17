//
//  CatalogViewController.swift
//  StartHub
//
//  Created by Adlet Trum on 16.12.2025.
//

import UIKit

final class CatalogViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    private let service = CatalogService()
    private var items: [CatalogCardViewModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        loadProjects()
    }

    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
    }

    private func loadProjects() {
        service.fetchProjects { [weak self] result in
            guard let self = self else { return }

            DispatchQueue.main.async {
                switch result {
                case .success(let projects):
                    self.items = projects.map { project in

                        let authorName: String = {
                            if let name = project.creator?.name, !name.isEmpty {
                                return name
                            }

                            let firstName = project.creator?.firstName ?? ""
                            let lastName = project.creator?.lastName ?? ""
                            let combined = (firstName + " " + lastName)
                                .trimmingCharacters(in: .whitespacesAndNewlines)

                            return combined.isEmpty ? "Автор" : combined
                        }()

                        let imagePath = project.images?
                            .sorted(by: { ($0.order ?? 0) < ($1.order ?? 0) })
                            .first?
                            .filePath

                        let imageURL: URL?
                        if let path = imagePath {
                            if let fullURL = URL(string: path), fullURL.scheme != nil {
                                imageURL = fullURL
                            } else {
                                imageURL = URL(string: "http://46.149.69.209\(path)")
                            }
                        } else {
                            imageURL = nil
                        }

                        return CatalogCardViewModel(
                            id: project.id,
                            title: project.title,
                            description: project.description ?? "",
                            authorName: authorName,
                            imageURL: imageURL
                        )
                    }

                    self.collectionView.reloadData()

                case .failure(let error):
                    print("Catalog load error:", error.localizedDescription)
                }
            }
        }
    }
}

// MARK: - Collection View

extension CatalogViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "StartupCardCell",
            for: indexPath
        ) as! StartupCardCell

        cell.configure(with: items[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = collectionView.bounds.width - 32
        return CGSize(width: width, height: 260)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {

        return UIEdgeInsets(top: 8, left: 16, bottom: 16, right: 16)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Catalogue", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "FavoritesViewController")
        navigationController?.pushViewController(vc, animated: true)
    }
}
