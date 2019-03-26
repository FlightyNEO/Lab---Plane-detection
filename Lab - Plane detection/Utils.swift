//
//  Utils.swift
//  Lab - Plane detection
//
//  Created by Arkadiy Grigoryanc on 26/03/2019.
//  Copyright © 2019 Arkadiy Grigoryanc. All rights reserved.
//

import Darwin
import ARKit

extension Float: DegreesToRadiansProtocol { }
extension Double: DegreesToRadiansProtocol { }

protocol DegreesToRadiansProtocol: FloatingPoint, ExpressibleByFloatLiteral { }

extension DegreesToRadiansProtocol {
    var radians: Self {
        return self * .pi / 180.0
    }
}


extension SCNVector3 {
    
    init(simd3: simd_float3) {
        self.init(x: Float(simd3.x), y: Float(simd3.y), z: Float(simd3.z))
    }
    
}
