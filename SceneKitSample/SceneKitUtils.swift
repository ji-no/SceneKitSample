//
//  SceneKitUtils.swift
//  ARSample
//  
//  Created by ji-no on R 4/02/06
//  
//

import SceneKit

func + (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}

func += (left: inout SCNVector3, right: SCNVector3) {
    left = left + right
}

func - (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x - right.x, left.y - right.y, left.z - right.z)
}

func * (vector: SCNVector3, scalar: Float) -> SCNVector3 {
    return SCNVector3Make(vector.x * scalar, vector.y * scalar, vector.z * scalar)
}

func / (left: SCNVector3, right: Float) -> SCNVector3 {
    return SCNVector3Make(left.x / right, left.y / right, left.z / right)
}

func /= (left: inout SCNVector3, right: Float) {
    left = left / right
}

func distance(_ a: SCNVector3, _ b: SCNVector3) -> Float {
    return sqrt(pow(a.x - b.x, 2) + pow(a.y - b.y, 2) + pow(a.z - b.z, 2))
}
