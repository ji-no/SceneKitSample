//
//  USDZNode.swift
//
//
//  Created by ji-no on R 4/02/26
//
//

import SceneKit

class USDZNode: SCNNode {

    // https://developer.apple.com/jp/augmented-reality/quick-look/
    enum ObjectType: String {
        case ToyBiplane

        static var all: [ObjectType] = [
            .ToyBiplane
        ]
    }

    init(type: ObjectType = .ToyBiplane) {
        super.init()
        loadUsdz(name: type.rawValue)
        let scale = 0.1
        self.scale = SCNVector3(scale, scale, scale)
        self.name = type.rawValue
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension SCNNode {

    func loadUsdz(name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "usdz") else { fatalError() }
        let options: [SCNSceneSource.LoadingOption : Any] = [
            .createNormalsIfAbsent: true,
            .checkConsistency: true,
            .flattenScene: true,
            .strictConformance: true,
            .convertUnitsToMeters: 1,
            .convertToYUp: true,
            .preserveOriginalTopology: false
        ]
        let scene = try! SCNScene(url: url, options: options)
        for child in scene.rootNode.childNodes {
            child.geometry?.firstMaterial?.lightingModel = .physicallyBased
            addChildNode(child)
        }
    }
    
    func showBoundingBox() {
        let box = SCNBox(
            width: CGFloat((boundingBox.max.x - boundingBox.min.x) * scale.x),
            height: CGFloat((boundingBox.max.y - boundingBox.min.y) * scale.y),
            length: CGFloat((boundingBox.max.z - boundingBox.min.z) * scale.z),
            chamferRadius: 0
        )
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.init(red: 0, green: 1, blue: 0, alpha: 0.5)
        for i in 0...5 {
            box.insertMaterial(material, at: i)
        }
        let boxNode = SCNNode(geometry: box)
        boxNode.position = SCNVector3(
            x: (boundingBox.max.x + boundingBox.min.x) * 0.5 * scale.x,
            y: (boundingBox.max.y + boundingBox.min.y) * 0.5 * scale.y,
            z: (boundingBox.max.z + boundingBox.min.z) * 0.5 * scale.z
        )
        parent?.addChildNode(boxNode)
    }

}
