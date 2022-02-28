//
//  NodeOutsideEdge.swift
//  SceneKitSample
//  
//  Created by ji-no on R 4/02/28
//  
//

import SceneKit

class NodeOutsideEdge {
    class Vertex {
        var point: SCNVector3
        var edges: [SCNNode] = []
        
        init(_ point: SCNVector3) {
            self.point = point
        }
    }
    
    weak var targetNode: SCNNode?
    private var vertices: [Vertex] = []
    private var edges: [SCNNode] = []

    private var color: UIColor = .init(red: 0, green: 1, blue: 1, alpha: 1)

    func createEdge() {
        guard let targetNode = targetNode else { return }

        createVertices(targetNode: targetNode)
        createTopEdges(targetNode: targetNode)
        createBottomEdges(targetNode: targetNode)
        createSideEdges(targetNode: targetNode)
        
        vertices.forEach { vertex in
            vertex.edges = edges
                .map { ($0, distance($0.position, vertex.point)) }
                .sorted { a, b in a.1 < b.1 }
                .enumerated()
                .compactMap { it in
                    it.offset < 3 ? it.element.0 : nil
                }
        }
        
    }

    func updateEdge(cameraPosition: SCNVector3) {
        edges.forEach { $0.isHidden = false }
        let sortedVertices = vertices
            .map { ($0, distance($0.point, cameraPosition)) }
            .sorted { a, b in a.1 < b.1 }
            .map { $0.0 }
        sortedVertices.first?.edges.forEach { $0.isHidden = true}
        sortedVertices.last?.edges.forEach { $0.isHidden = true}
    }

    private func createVertices(targetNode: SCNNode) {
        let boundingBoxSize = targetNode.boundingBoxSize
        let boundingBoxCenter = targetNode.boundingBoxCenter
        
        vertices = [
            SCNVector3(x: 1, y: 1, z: 1),
            SCNVector3(x: 1, y: 1, z: -1),
            SCNVector3(x: -1, y: 1, z: 1),
            SCNVector3(x: -1, y: 1, z: -1),
            SCNVector3(x: 1, y: -1, z: 1),
            SCNVector3(x: 1, y: -1, z: -1),
            SCNVector3(x: -1, y: -1, z: 1),
            SCNVector3(x: -1, y: -1, z: -1),
        ].map { point in
            .init(.init(
                x: boundingBoxCenter.x + boundingBoxSize.x * point.x,
                y: boundingBoxCenter.y + boundingBoxSize.y * point.y,
                z: boundingBoxCenter.z + boundingBoxSize.z * point.z
            ))
        }
    }

    private func createTopEdges(targetNode: SCNNode) {
        let boundingBoxSize = targetNode.boundingBoxSize
        let boundingBoxCenter = targetNode.boundingBoxCenter

        let radius: Float = 0.02
        let cylinder = SCNCylinder(radius: CGFloat(radius), height: 1)
        let material = SCNMaterial()
        material.diffuse.contents = color
        cylinder.insertMaterial(material, at: 0)

        let parameters: [(height: Float, axis: SCNVector3, position: SCNVector3)] = [
            (height: boundingBoxSize.x, axis: .init(x: 0, y: 0, z: 1), position: .init(x: 0, y: 1, z: 1)),
            (height: boundingBoxSize.x, axis: .init(x: 0, y: 0, z: 1), position: .init(x: 0, y: 1, z: -1)),
            (height: boundingBoxSize.z, axis: .init(x: 1, y: 0, z: 0), position: .init(x: 1, y: 1, z: 0)),
            (height: boundingBoxSize.z, axis: .init(x: 1, y: 0, z: 0), position: .init(x: -1, y: 1, z: 0)),
        ]

        parameters.forEach { height, axis, position in
            let node = SCNNode(geometry: cylinder)
            node.scale = SCNVector3(x: 1, y: height, z: 1)
            node.eulerAngles = axis * (-.pi * 0.5)
            node.position = boundingBoxCenter + SCNVector3(
                x: (boundingBoxSize.z * 0.5 + radius) * position.x,
                y: (boundingBoxSize.y * 0.5 + radius) * position.y,
                z: (boundingBoxSize.z * 0.5 + radius) * position.z
            )
            targetNode.parent?.addChildNode(node)
            edges.append(node)
        }
    }

    private func createBottomEdges(targetNode: SCNNode) {
        let boundingBoxSize = targetNode.boundingBoxSize
        let boundingBoxCenter = targetNode.boundingBoxCenter
        
        let radius: Float = 0.02
        let cylinder = SCNCylinder(radius: CGFloat(radius), height: 1)
        let material = SCNMaterial()
        material.diffuse.contents = color
        cylinder.insertMaterial(material, at: 0)

        let parameters: [(height: Float, axis: SCNVector3, position: SCNVector3)] = [
            (height: boundingBoxSize.x, axis: .init(x: 0, y: 0, z: 1), position: .init(x: 0, y: -1, z: 1)),
            (height: boundingBoxSize.x, axis: .init(x: 0, y: 0, z: 1), position: .init(x: 0, y: -1, z: -1)),
            (height: boundingBoxSize.z, axis: .init(x: 1, y: 0, z: 0), position: .init(x: 1, y: -1, z: 0)),
            (height: boundingBoxSize.z, axis: .init(x: 1, y: 0, z: 0), position: .init(x: -1, y: -1, z: 0)),
        ]

        parameters.forEach { height, axis, position in
            let node = SCNNode(geometry: cylinder)
            node.scale = SCNVector3(x: 1, y: height, z: 1)
            node.eulerAngles = axis * (-.pi * 0.5)
            node.position = boundingBoxCenter + SCNVector3(
                x: (boundingBoxSize.z * 0.5 + radius) * position.x,
                y: (boundingBoxSize.y * 0.5 + radius) * position.y,
                z: (boundingBoxSize.z * 0.5 + radius) * position.z
            )
            targetNode.parent?.addChildNode(node)
            edges.append(node)
        }
    }

    private func createSideEdges(targetNode: SCNNode) {
        let boundingBoxSize = targetNode.boundingBoxSize
        let boundingBoxCenter = targetNode.boundingBoxCenter
        
        let radius: Float = 0.02
        let cylinder = SCNCylinder(radius: CGFloat(radius), height: 1)
        let material = SCNMaterial()
        material.diffuse.contents = color
        cylinder.insertMaterial(material, at: 0)

        let positions: [SCNVector3] = [
            .init(x: 1, y: 0, z: 1),
            .init(x: 1, y: 0, z: -1),
            .init(x: -1, y: 0, z: 1),
            .init(x: -1, y: 0, z: -1),
        ]

        positions.forEach { position in
            let node = SCNNode(geometry: cylinder)
            node.scale = SCNVector3(x: 1, y: boundingBoxSize.y, z: 1)
            node.position = boundingBoxCenter + SCNVector3(
                x: (boundingBoxSize.z * 0.5 + radius) * position.x,
                y: (boundingBoxSize.y * 0.5 + radius) * position.y,
                z: (boundingBoxSize.z * 0.5 + radius) * position.z
            )
            targetNode.parent?.addChildNode(node)
            edges.append(node)
        }
    }

}
