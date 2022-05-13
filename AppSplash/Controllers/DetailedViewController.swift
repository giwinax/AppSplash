//
//  DetailedViewController.swift
//  AppSplash
//
//  Created by s b on 29.04.2022.
//

import UIKit

class DetailedViewController: UIViewController, AlertDisplayer {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var downloadedLabel: UILabel!
    @IBOutlet var photoView: UIImageView! = UIImageView()
    
    var photoId = ""
    var thumbImage = Data()
    
    var favoritePhoto: FavoritePhotos!
    
    let loadingIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLoadingIndicator()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(addToFavorite))
        
        fetchData()
    }
    
    func setupLoadingIndicator() {
        loadingIndicator.startAnimating()
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loadingIndicator.widthAnchor.constraint(equalToConstant: 40.0),
            loadingIndicator.heightAnchor.constraint(equalToConstant: 40.0)
        ])
    }
    
    func fetchData() {
        
        let NetworkAgent = Networking()
        
        NetworkAgent.fetchDetails(id: photoId) { (result) in
            
            switch result {
            
            case .success(let res):
            
                self.nameLabel.text = res.name
                self.dateLabel.text = "\(res.date)"
                self.locationLabel.text = res.location
                self.downloadedLabel.text = res.downloads
                self.photoView.image = res.largeImage
                self.loadingIndicator.removeFromSuperview()
            
            case .failure(let errorMsg):
            
                self.displayAlert(message: errorMsg.localizedDescription)
            }
        }
    }
    
    @objc func addToFavorite() {
        
        if self.loadingIndicator.superview == nil {
        
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            
                favoritePhoto = FavoritePhotos(context: appDelegate.persistentContainer.viewContext)
                
                favoritePhoto.name = self.nameLabel.text!
                favoritePhoto.date = self.dateLabel.text!
                favoritePhoto.location = self.locationLabel.text!
                favoritePhoto.downloads = self.downloadedLabel.text!
                favoritePhoto.id = self.photoId
                favoritePhoto.image = self.thumbImage
                
                appDelegate.saveContext()
            }
        }
    }    
}
