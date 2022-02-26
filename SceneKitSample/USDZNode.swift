//
//  USDZNode.swift
//
//
//  Created by ji-no on R 4/02/26
//
//

import SceneKit

class USDZNode: SCNNode {
    var widthTextNodes: [SCNNode] = []
    var depthTextNodes: [SCNNode] = []
    var heightTextNodes: [SCNNode] = []

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
    
    func createSizeText() {
        createWidthText()
        createDepthText()
        createHeightText()
    }
    
    func updateSizeText(cameraPosition: SCNVector3) {
        widthTextNodes
            .map { ($0, distance($0.position, cameraPosition)) }
            .sorted { a, b in a.1 < b.1 }
            .enumerated()
            .forEach { it in
                it.element.0.isHidden = it.offset != 0
            }
        depthTextNodes
            .map { ($0, distance($0.position, cameraPosition)) }
            .sorted { a, b in a.1 < b.1 }
            .enumerated()
            .forEach { it in
                it.element.0.isHidden = it.offset != 0
            }
        heightTextNodes
            .map { ($0, distance($0.position, cameraPosition)) }
            .sorted { a, b in a.1 < b.1 }
            .enumerated()
            .forEach { it in
                it.element.0.isHidden = it.offset != 1
            }
    }
        

    private func createWidthText() {
        let positions = [
            SCNVector3(
                x: 0,
                y: -boundingBoxSize.y * 0.5,
                z: boundingBoxSize.z * 0.5
            ),
            SCNVector3(
                x: 0,
                y: -boundingBoxSize.y * 0.5,
                z: -boundingBoxSize.z * 0.5
            )
        ]
        
        widthTextNodes = positions.map { pos in
            let textNode = create(text: String.init(format: "%.2f", boundingBoxSize.x))
            textNode.position = boundingBoxCenter + pos
            if let child = textNode.childNodes.first {
                child.position.y = 0
                if pos.z > 0 {
                    textNode.position.z += child.boundingBoxCenter.x
                } else {
                    textNode.position.z -= child.boundingBoxCenter.x
                }
            }
            return textNode
        }
    }

    private func createDepthText() {
        let positions = [
            SCNVector3(
                x: boundingBoxSize.x * 0.5,
                y: -boundingBoxSize.y * 0.5,
                z: 0
            ),
            SCNVector3(
                x: -boundingBoxSize.x * 0.5,
                y: -boundingBoxSize.y * 0.5,
                z: 0
            )
        ]

        depthTextNodes = positions.map { pos in
            let textNode = create(text: String.init(format: "%.2f", boundingBoxSize.z))
            textNode.position = boundingBoxCenter + pos
            if let child = textNode.childNodes.first {
                child.position.y = 0
                if pos.x > 0 {
                    textNode.position.x += child.boundingBoxCenter.x
                } else {
                    textNode.position.x -= child.boundingBoxCenter.x
                }
            }
            return textNode
        }
    }

    private func createHeightText() {
        let positions = [
            SCNVector3(
                x: -boundingBoxSize.x * 0.5,
                y: 0,
                z: boundingBoxSize.z * 0.5
            ),
            SCNVector3(
                x: boundingBoxSize.x * 0.5,
                y: 0,
                z: boundingBoxSize.z * 0.5
            ),
            SCNVector3(
                x: +boundingBoxSize.x * 0.5,
                y: 0,
                z: -boundingBoxSize.z * 0.5
            ),
            SCNVector3(
                x: -boundingBoxSize.x * 0.5,
                y: 0,
                z: -boundingBoxSize.z * 0.5
            ),
        ]

        heightTextNodes = positions.map { pos in
            let textNode = create(text: String.init(format: "%.2f", boundingBoxSize.y))
            textNode.position = boundingBoxCenter + pos
            if let child = textNode.childNodes.first {
                if pos.x > 0 {
                    textNode.position.x += child.boundingBoxCenter.x / sqrt(2)
                } else {
                    textNode.position.x -= child.boundingBoxCenter.x / sqrt(2)
                }
                if pos.z > 0 {
                    textNode.position.z += child.boundingBoxCenter.x / sqrt(2)
                } else {
                    textNode.position.z -= child.boundingBoxCenter.x / sqrt(2)
                }
            }
            return textNode
        }
    }

    private func create(text: String) -> SCNNode {
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.init(red: 1, green: 0, blue: 0, alpha: 1)

        let scnText = SCNText(string: text, extrusionDepth: 0.2)
        for i in 0...5 {
            scnText.insertMaterial(material, at: i)
        }
        
        let scale: Float = 0.03

        let textNode = SCNNode(geometry: scnText)
        textNode.scale = .init(x: scale, y: scale, z: scale)
        textNode.position = .init(
            x: -textNode.boundingBoxCenter.x,
            y: -textNode.boundingBoxCenter.y,
            z: -textNode.boundingBoxCenter.z
        )
        let node = SCNNode()
        node.addChildNode(textNode)
        node.position = position
        let billboardConstraint = SCNBillboardConstraint()
        node.constraints = [billboardConstraint]
        parent?.addChildNode(node)
        
        return node
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

    var boundingBoxSize: SCNVector3 {
        return SCNVector3(
            x: (boundingBox.max.x - boundingBox.min.x) * scale.x,
            y: (boundingBox.max.y - boundingBox.min.y) * scale.y,
            z: (boundingBox.max.z - boundingBox.min.z) * scale.z
        )
    }

    var boundingBoxCenter: SCNVector3 {
        return SCNVector3(
            x: (boundingBox.max.x + boundingBox.min.x) * 0.5 * scale.x,
            y: (boundingBox.max.y + boundingBox.min.y) * 0.5 * scale.y,
            z: (boundingBox.max.z + boundingBox.min.z) * 0.5 * scale.z
        )
    }
    
    func showBoundingBox() {
        let box = SCNBox(
            width: CGFloat(boundingBoxSize.x),
            height: CGFloat(boundingBoxSize.y),
            length: CGFloat(boundingBoxSize.z),
            chamferRadius: 0
        )
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.init(red: 0, green: 1, blue: 0, alpha: 0.5)
        for i in 0...5 {
            box.insertMaterial(material, at: i)
        }
        let boxNode = SCNNode(geometry: box)
        boxNode.position = boundingBoxCenter
        parent?.addChildNode(boxNode)
    }

}
