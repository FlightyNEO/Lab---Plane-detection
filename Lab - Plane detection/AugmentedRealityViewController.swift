//
//  AugmentedRealityViewController.swift
//  Lab - Plane detection
//
//  Created by Arkadiy Grigoryanc on 26/03/2019.
//  Copyright © 2019 Arkadiy Grigoryanc. All rights reserved.
//

import ARKit

class AugmentedRealityViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var sceneView: ARSCNView!
    
    var currentModel: ModelManager.NodeModel!
    
    // MARK: - Private properties
    private let modelManager = ModelManager.manager
    
    // MARK: - Life cicles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        #if DEBUG
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.debugOptions = [.showFeaturePoints, .showWorldOrigin]
        #endif
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    // MARK: - Life cicles
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
}

// MARK: - Private methods
extension AugmentedRealityViewController {
    
    private func update(_ model: SCNNode) {
        
        switch currentModel {
            
        case .some(.cube):
            
            let heightModel = modelManager.size(model).z
            
            modelManager.update(model, by: 0.5)
            modelManager.move(model, to: SCNVector3(0, 0, (heightModel / 4)))
            
        case .some(.ship):
            
            modelManager.update(model)
            
        case .none: break
            
        }
        
    }
    
}

// MARK: - ARSCNViewDelegate
extension AugmentedRealityViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        guard let anchor = anchor as? ARPlaneAnchor else { return }
        let extent = anchor.extent
        
        modelManager.addFloor(withSize: CGSize(width: CGFloat(extent.x), height: CGFloat(extent.z)), to: node) { node in
            
            modelManager.add(currentModel, to: node) { model in
                
                self.modelManager.rotate(model, to: SCNVector3(Float(90.radians), 0, 0))
                self.update(model)
                
            }
            
        }
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        guard let anchor = anchor as? ARPlaneAnchor else { return }
        guard var floorNode = node.childNodes.first else { return }
        guard let childNode = floorNode.childNode(withName: currentModel.rawValue, recursively: true) else { return }
        
        modelManager.updateFloor(&floorNode, with: anchor)
        update(childNode)
        
    }
    
}
