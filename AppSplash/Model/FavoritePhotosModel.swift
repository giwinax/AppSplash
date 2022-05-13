//
//  DetailedPhotosModel.swift
//  AppSplash
//
//  Created by s b on 01.05.2022.
//

import Foundation
import UIKit
import CoreData

public class FavoritePhotos: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoritePhotos> {
        return NSFetchRequest<FavoritePhotos>(entityName: "FavoritePhotos")
    }
    @NSManaged public var id: String
    @NSManaged public var name: String
    @NSManaged public var date: String
    @NSManaged public var location: String
    @NSManaged public var downloads: String
    @NSManaged public var image: Data
}

class FavoritePhotosDiffableDataSource: UITableViewDiffableDataSource<Section, FavoritePhotos> {

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}
