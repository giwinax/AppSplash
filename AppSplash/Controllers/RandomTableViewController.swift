//
//  RandomTableViewController.swift
//  AppSplash
//
//  Created by s b on 29.04.2022.
//

import UIKit

class RandomTableViewController: UITableViewController, UISearchBarDelegate, AlertDisplayer {
    
    var photos = [Photos]()
    
    let networkAgent = Networking()
    
    lazy var dataSource = configureDataSource()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - Controller life cycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.dataSource = dataSource
        
        fetchRandomPhoto()
        
        self.navigationItem.searchController = searchController
        
        searchController.searchResultsUpdater = self
        
        searchController.obscuresBackgroundDuringPresentation = false
        
        searchController.searchBar.delegate = self
        
        definesPresentationContext = true
        
    }
    // MARK: - Table view data source
    func configureDataSource() -> UITableViewDiffableDataSource<Section, Photos> {
        
        let cellIdentifier = "defaultcell"
        
        let dataSource = PhotosDiffableDataSource(
            tableView: tableView,
            cellProvider: {  tableView, indexPath, photos in
                
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! PhotoTableViewCell
                
                cell.textLabel?.text = photos.name
                cell.imageView?.image = photos.image
                cell.photoId = photos.id
                
                return cell
            }
        )
        return dataSource
    }
    
    func fetchRandomPhoto() {
        
        networkAgent.getRandom(completion: { (result) in
            
            switch result {
                
            case .success(let res):
                
                self.photos = res
                
                var snapshot = NSDiffableDataSourceSnapshot<Section, Photos>()
                
                snapshot.appendSections([.all])
                snapshot.appendItems(self.photos, toSection: .all)
                
                self.dataSource.apply(snapshot, animatingDifferences: false)
                
            case .failure(let errorMsg):
                
                self.displayAlert(message: errorMsg.localizedDescription)
            }
        })
    }
    func searchPhotos(searchText: String) {

        networkAgent.search(searchString: searchText) { (result) in
            
            switch result {
            
            case .success(let res):
            
                self.photos = res
                
                var snapshot = NSDiffableDataSourceSnapshot<Section, Photos>()
                
                snapshot.appendSections([.all])
                snapshot.appendItems(self.photos, toSection: .all)
                
                self.dataSource.apply(snapshot, animatingDifferences: false)
            
            case .failure(let errorMsg):
            
                self.displayAlert(message: errorMsg.localizedDescription)
            }
        }
    }
    // MARK: - Navigation
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "randomToDetailed", sender: indexPath.row)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let indexPath = tableView.indexPathForSelectedRow {
           
            guard let destVC = segue.destination as? DetailedViewController else { self.displayAlert(message: "Cannot create segue."); return }
            
            destVC.photoId = photos[indexPath.row].id
            destVC.thumbImage = photos[indexPath.row].image.pngData()!
        }
    }
}

// MARK: - Search bar extentions
extension RandomTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {

    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchPhotos(searchText: searchController.searchBar.text!)
    }
}


