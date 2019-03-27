//
//  ModelManager.swift
//  Lab - Plane detection
//
//  Created by Arkadiy Grigoryanc on 27/03/2019.
//  Copyright © 2019 Arkadiy Grigoryanc. All rights reserved.
//

import ARKit

private protocol FethModelProtocol { }
private protocol UpdateModelProtocol { }
private protocol AddModelProtocol { }

struct ModelManager {
    
    // MARK: - Initialization
    private init() {}
    static var manager: ModelManager { return ModelManager.init() }
    
    // MARK: - Properties
    enum NodeModel: String, CaseIterable, CustomStringConvertible {
        
        case cube = "cube"
        case ship = "shipMesh"
        
        var description: String {
            
            switch self {
                
            case .cube: return "Cube"
            case .ship: return "Ship"
                
            }
            
        }
        
        fileprivate var sceneName: String {
            
            switch self {
            
            case .ship: return "art.scnassets/Ship/ship.scn"
            case .cube: return "art.scnassets/Cube/cube.scn"
                
            }
            
        }
        
    }
    
    var allModels: [NodeModel] { return NodeModel.allCases }
    
    // MARK - Errors
    enum NodeManagerError: Error {
        case fetchError(error: String)
    }
    
    // MARK: Private methods
    private func nodeFrom(_ sceneFile: String?) throws -> SCNNode {
        
        guard
            let sceneFile = sceneFile,
            let sceneNode = SCNScene(named: sceneFile)?.rootNode else {
                
            throw NodeManagerError.fetchError(error: "Not fined node for this name")
                
        }
        
        return sceneNode
    }
    
    private func calculateScaleNode(_ scalebleNode: SCNNode, to plane: SCNPlane, by scale: Float = 1) -> Float {
        
        let minSizePlane = Float(min(plane.width, plane.height))
        let maxSizeShip = max((scalebleNode.boundingBox.max.x - scalebleNode.boundingBox.min.x), (scalebleNode.boundingBox.max.y - scalebleNode.boundingBox.min.y))
        let resultScale = (minSizePlane / maxSizeShip) * scale
        
        #if DEBUG
        print("Plane size", minSizePlane)
        print("Size ship", maxSizeShip)
        print("Scale", resultScale)
        #endif
        
        return resultScale
    }
    
    func size(_ node: SCNNode) -> SCNVector3 {
        
        return SCNVector3(
            node.boundingBox.max.x - node.boundingBox.min.x,
            node.boundingBox.max.y - node.boundingBox.min.y,
            node.boundingBox.max.z - node.boundingBox.min.z)
        
    }
    
}

extension ModelManager: FethModelProtocol {
    
    // Немного Swift 5.0
    func fetch(_ model: NodeModel, completion: @escaping (Result<SCNNode, NodeManagerError>) -> ()) {
        
        do {
            
            let sceneNode = try nodeFrom(model.sceneName)
            
            guard let node = sceneNode.childNode(withName: model.rawValue, recursively: true) else {
                
                completion(.failure(.fetchError(error: "Not fined node for this name")))
                return
                
            }
            
            completion(.success(node))
            
        } catch (let error) {
            
            completion(.failure(.fetchError(error: error.localizedDescription)))
            
        }
        
    }
    
    func fetch(_ model: NodeModel) throws -> SCNNode {
        
        do {
            
            let sceneNode = try nodeFrom(model.sceneName)
            
            guard let node = sceneNode.childNode(withName: model.rawValue, recursively: true) else {
                
                throw NodeManagerError.fetchError(error: "Not fined node for this name")
                
            }
            
            return node
            
        } catch (let error) {
            
            throw NodeManagerError.fetchError(error: error.localizedDescription)
            
        }
        
    }
    
}

extension ModelManager: AddModelProtocol {
    
    func addFloor(withSize size: CGSize, to node: SCNNode, completion: (_ floorNode: SCNNode) -> ()) {
        
        let floorNode = SCNNode(geometry: SCNPlane(width: size.width, height: size.height))
        floorNode.geometry?.firstMaterial?.diffuse.contents = #colorLiteral(red: 0.060786888, green: 0.223592639, blue: 0.8447286487, alpha: 0.5)
        floorNode.eulerAngles.x = Float(-90.radians)
        
        node.addChildNode(floorNode)
        
        completion(floorNode)
        
    }
    
    func add(_ model: NodeModel, to parent: SCNNode, completion: @escaping (_ node: SCNNode) -> ()) {
        
        fetch(model, completion: { result in
            
            switch result {
                
            case .success(let node):
                
                let node = node.clone()
                
                parent.addChildNode(node)
                
                completion(node)
                
            case .failure: break    // ERROR
                
            }
            
        })
        
    }
    
}

extension ModelManager: UpdateModelProtocol {
    
    func updateFloor(_ node: inout SCNNode, with anchor: ARPlaneAnchor, completion: ((_ finished: Bool) -> ())? = nil) {
        
        guard let floor = node.geometry as? SCNPlane else {
            completion?(false)
            return
            
        }
        
        // update position
        node.position = SCNVector3(simd3: anchor.center)
        
        // update size
        floor.width = CGFloat(anchor.extent.x)
        floor.height = CGFloat(anchor.extent.z)
        
        completion?(true)
    }
    
    func updateFloor(_ node: SCNNode, with anchor: ARPlaneAnchor, completion: (_ floorNode: SCNNode) -> ()) {
        
        guard let floor = node.geometry as? SCNPlane else { return }
        
        // update position
        node.position = SCNVector3(simd3: anchor.center)
        
        // update size
        floor.width = CGFloat(anchor.extent.x)
        floor.height = CGFloat(anchor.extent.z)
        
        completion(node)
        
    }
    
    func update(_ node: SCNNode, by scale: Float = 1) {
        
        guard let plane = node.parent?.geometry as? SCNPlane else { return }
        
        // update scale
        let scale = calculateScaleNode(node, to: plane, by: scale)
        node.scale = SCNVector3(x: scale, y: scale, z: scale)
        
    }
    
    func rotate(_ node: SCNNode, to eulerAngles: SCNVector3) {
        node.eulerAngles.x += eulerAngles.x
        node.eulerAngles.y += eulerAngles.y
        node.eulerAngles.z += eulerAngles.z
    }
    
    func scale(_ node: SCNNode, by index: Float) {
        
        node.scale.x *= index
        node.scale.y *= index
        node.scale.z *= index
        
    }
    
    func move(_ node: SCNNode, to position: SCNVector3) {
        node.position = position
//        node.position.x += vector.x
//        node.position.y += vector.y
//        node.position.x += vector.z

    }
    
}
