//
//  ViewController.swift
//  
//  
//  Created by ji-no on R 4/02/26
//  
//

import UIKit
import SceneKit

class ViewController: UIViewController {
    @IBOutlet weak var sceneView: SCNView!
    let scene = SCNScene()
    var cameraNode: SCNNode!
    var model: USDZNode!

    override func viewDidLoad() {
        super.viewDidLoad()

        setUp()
    }

}

extension ViewController {
    
    func setUp() {
        sceneView.scene = scene
        sceneView.delegate = self

        setUpLight()
        setUpCamera()
        setUpPlane()
        setUpObject()
        setUpTechnique()
    }

    func setUpTechnique() {
        if let path = Bundle.main.path(forResource: "NodeTechnique", ofType: "plist") {
            if let dict = NSDictionary(contentsOfFile: path)  {
                let dict2 = dict as! [String : AnyObject]
                let technique = SCNTechnique(dictionary: dict2)

                // set the glow color to yellow
                let color = SCNVector3(1.0, 1.0, 0.0)
                technique?.setValue(NSValue(scnVector3: color), forKeyPath: "glowColorSymbol")
                sceneView.technique = technique
            }
        }
    }

    func setUpLight() {
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)

        let ambientLightNode = SCNNode()
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.color = UIColor(white: 0.5, alpha: 1)
        ambientLightNode.light = ambientLight
        scene.rootNode.addChildNode(ambientLightNode)
    }

    func setUpCamera() {
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        cameraNode.position = SCNVector3(x: 9, y: 3, z: 9)
        cameraNode.eulerAngles = SCNVector3(0, Float.pi/4, 0)
        sceneView.allowsCameraControl = true
        self.cameraNode = cameraNode
    }
    
    func setUpPlane() {
        let plane = SCNPlane(width: 15, height: 15)
        let m1 = SCNMaterial()
        m1.diffuse.contents = UIColor.brown
        plane.insertMaterial(m1, at: 0)
        let planeNode = SCNNode(geometry: plane)
        planeNode.eulerAngles = SCNVector3(-Float.pi/2, 0, 0)
        scene.rootNode.addChildNode(planeNode)
    }

    func setUpObject() {
        let toyBiplane = USDZNode(type: .ToyBiplane)
        toyBiplane.position = SCNVector3(x: 0, y: 0, z: 0)
        scene.rootNode.addChildNode(toyBiplane)
        
        //toyBiplane.showBoundingBox()
        toyBiplane.createSizeText()
        //toyBiplane.setHighlighted()
        toyBiplane.createOutsideEdge()
        model = toyBiplane
    }

}

extension ViewController: SCNSceneRendererDelegate {

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if let pointOfView = sceneView.pointOfView {
            model.updateSizeText(cameraPosition: pointOfView.position)
            model.updateOutsideEdge(cameraPosition: pointOfView.position)
        }
    }

}
