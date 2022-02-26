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

}
