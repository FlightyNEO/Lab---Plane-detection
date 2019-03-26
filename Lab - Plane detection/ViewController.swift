//
//  ViewController.swift
//  Lab - Plane detection
//
//  Created by Arkadiy Grigoryanc on 26/03/2019.
//  Copyright © 2019 Arkadiy Grigoryanc. All rights reserved.
//

import ARKit

class ViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var sceneView: ARSCNView!
    
    // MARK: - Private properties
    private enum SceneName: String {
        
//        enum Character: String, CaseIterable {
//
//            case human1 = "art.scnassets/Character/Cas-Sum_Man_RtStand_366.dae"
//            case human2 = "art.scnassets/Character2/7.scn"
//
//        }
        
        case ship = "art.scnassets/ship.scn"
        
    }
    
    private enum NodeName: String {
        case ship = "shipMesh"
    }
    
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
extension ViewController {
    
    // --- add floor
    private func addFloor(withSize size: CGSize, to node: SCNNode, completion: (_ floorNode: SCNNode) -> ()) {
        
        let floorNode = SCNNode(geometry: SCNPlane(width: size.width, height: size.height))
        floorNode.geometry?.firstMaterial?.diffuse.contents = #colorLiteral(red: 0.060786888, green: 0.223592639, blue: 0.8447286487, alpha: 0.5)
        floorNode.eulerAngles.x = Float(-90.radians)
        
        node.addChildNode(floorNode)
        
        completion(floorNode)
        
    }
    
    // --- add ship
    private func addShip(to node: SCNNode) {
        
        guard let plane = node.geometry as? SCNPlane else { return }
        guard let ship = nodeFrom(SceneName.ship.rawValue).childNode(withName: NodeName.ship.rawValue, recursively: true)?.clone() else { return }
        
        let scale = calculateScaleNode(ship, to: plane)
        ship.scale = SCNVector3(x: scale, y: scale, z: scale)
        
        ship.eulerAngles.x = Float(90.radians)
        node.addChildNode(ship)
    }
    
    private func updateFloor(_ node: inout SCNNode, with anchor: ARPlaneAnchor) {
        
        guard let floor = node.geometry as? SCNPlane else { return }
        
        // update position
        node.position = SCNVector3(simd3: anchor.center)
        
        // update size
        floor.width = CGFloat(anchor.extent.x)
        floor.height = CGFloat(anchor.extent.z)
        
    }
    
    private func updateFloor(_ node: SCNNode, with anchor: ARPlaneAnchor, completion: (_ floorNode: SCNNode) -> ()) {
        
        guard let floor = node.geometry as? SCNPlane else { return }
        
        // update position
        node.position = SCNVector3(simd3: anchor.center)
        
        // update size
        floor.width = CGFloat(anchor.extent.x)
        floor.height = CGFloat(anchor.extent.z)
        
        completion(node)
        
    }
    
    private func updateShip(parent node: inout SCNNode) {
        
        guard let plane = node.geometry as? SCNPlane else { return }
        guard let ship = node.childNodes.first else { return }
        
        let scale = calculateScaleNode(ship, to: plane)
        ship.scale = SCNVector3(x: scale, y: scale, z: scale)
        
    }
    
    private func nodeFrom(_ sceneFile: String) -> SCNNode {
        return SCNScene(named: sceneFile)!.rootNode
    }
    
    private func calculateScaleNode(_ scalebleNode: SCNNode, to plane: SCNPlane) -> Float {
        let minSizePlane = Float(min(plane.width, plane.height))
        let maxSizeShip = max(
            (scalebleNode.boundingBox.min.x > 0 ? scalebleNode.boundingBox.min.x : -scalebleNode.boundingBox.min.x) + (scalebleNode.boundingBox.max.x > 0 ? scalebleNode.boundingBox.max.x : -scalebleNode.boundingBox.max.x),
            (scalebleNode.boundingBox.min.y > 0 ? scalebleNode.boundingBox.min.y : -scalebleNode.boundingBox.min.y) + (scalebleNode.boundingBox.max.y > 0 ? scalebleNode.boundingBox.max.y : -scalebleNode.boundingBox.max.y))
        let scale = minSizePlane / maxSizeShip
        
        #if DEBUG
        print("Plane size", minSizePlane)
        print("Size ship", maxSizeShip)
        print("Scale", scale)
        #endif
        
        return scale
    }
    
}

// MARK: - ARSCNViewDelegate
extension ViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        guard let anchor = anchor as? ARPlaneAnchor else { return }
        let extent = anchor.extent
        
        // create and add floor node to the scene
        addFloor(withSize: CGSize(width: CGFloat(extent.x), height: CGFloat(extent.z)), to: node) { node in
            
            addShip(to: node)
            
        }
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        guard let anchor = anchor as? ARPlaneAnchor else { return }
        guard var floorNode = node.childNodes.first else { return }
        
        updateFloor(&floorNode, with: anchor)
        updateShip(parent: &floorNode)
        
    }
    
}
