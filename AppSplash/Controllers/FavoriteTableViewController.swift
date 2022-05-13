//
//  FavoriteTableViewController.swift
//  AppSplash
//
//  Created by s b on 29.04.2022.
//

import UIKit
import CoreData

class FavoriteTableViewController: UITableViewController, AlertDisplayer {
    
    var favPhotos: [FavoritePhotos] = []
    
    var fetchResultController: NSFetchedResultsController<FavoritePhotos>!
    
    lazy var dataSource = configureDataSource()
    
    // MARK: - Controller life cycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.dataSource = dataSource
        tableView.separatorStyle = .none
        
        fetchFavoritePhotos()
    }
    
    // MARK: - Table view data source
    func configureDataSource() -> UITableViewDiffableDataSource<Section, FavoritePhotos> {
        
        let cellIdentifier = "defaultcell"
        
        let dataSource = FavoritePhotosDiffableDataSource(
            tableView: tableView,
            cellProvider: {  tableView, indexPath, favPhotos in
          
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! PhotoTableViewCell
                
                cell.textLabel?.text = favPhotos.name
                cell.imageView?.image = UIImage(data: favPhotos.image)
                cell.photoId = favPhotos.id
                
                return cell
            }
        )
        return dataSource
    }
    
    func fetchFavoritePhotos() {
        let fetchRequest: NSFetchRequest<FavoritePhotos> = FavoritePhotos.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
      
            let context = appDelegate.persistentContainer.viewContext
            
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultController.delegate = self
            
            do {
                try fetchResultController.performFetch()
               
                updateSnapshot()
            
            } catch {
                self.displayAlert(message: error.localizedDescription)
            }
        }
    }
    
    func updateSnapshot() {
        
        if let fetchedObjects = fetchResultController.fetchedObjects {
            
            favPhotos = fetchedObjects
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, FavoritePhotos>()
        
        snapshot.appendSections([.all])
        snapshot.appendItems(favPhotos, toSection: .all)
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    // MARK: - Delete action
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        guard let CurrentPhoto = self.dataSource.itemIdentifier(for: indexPath) else {
            self.displayAlert(message: "Cannot retreive data")
            return UISwipeActionsConfiguration()
        }
    
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, sourceView, completionHandler) in
            
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            
                let context = appDelegate.persistentContainer.viewContext
                
                context.delete(CurrentPhoto)
                appDelegate.saveContext()
                
                self.updateSnapshot()
            }
            
            completionHandler(true)
        }
        
        deleteAction.backgroundColor = UIColor.systemRed
        deleteAction.image = UIImage(systemName: "trash")

        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction])
            
        return swipeConfiguration
    }
    
    // MARK: - Navigation
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "favortiveToDetailed", sender: indexPath.row)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let indexPath = tableView.indexPathForSelectedRow {
            guard let destVC = segue.destination as? DetailedViewController else { self.displayAlert(message: "Cannot create segue."); return }
            destVC.photoId = favPhotos[indexPath.row].id
        }
    }
}
// MARK: - Extentions
extension FavoriteTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateSnapshot()
    }
}
