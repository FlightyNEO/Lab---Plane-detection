//
//  MainTableViewController.swift
//  Lab - Plane detection
//
//  Created by Arkadiy Grigoryanc on 27/03/2019.
//  Copyright © 2019 Arkadiy Grigoryanc. All rights reserved.
//

import UIKit

class MainTableViewController: UITableViewController {
    
    // MARK: - Outlets
    
    // MARK: - Private properties
    private let modelCellIdentifier = "ModelCell"
    private let showARIdentifier = "ShowAR"
    
    private var models = ModelManager.manager.allModels
    
    // MARK: - Properties
    var selectedModel: ModelManager.NodeModel = .ship
    
    // MARK: - Life cicles
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: modelCellIdentifier, for: indexPath)
        cell.textLabel?.text = models[indexPath.row].description
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        selectedModel = models[indexPath.row]
        return indexPath
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == showARIdentifier {
            
            let augmentedRealityViewController = segue.destination as! AugmentedRealityViewController
            augmentedRealityViewController.currentModel = selectedModel
            
        }
        
    }
    
}
