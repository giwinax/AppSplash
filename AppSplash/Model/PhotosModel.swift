//
//  PhotosModel.swift
//  AppSplash
//
//  Created by s b on 30.04.2022.
//

import Foundation
import UIKit

struct Photos: Hashable {
    
    var id: String = ""
    var name: String = ""
    var image: UIImage = UIImage()
}

class PhotosDiffableDataSource: UITableViewDiffableDataSource<Section, Photos> {

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}
