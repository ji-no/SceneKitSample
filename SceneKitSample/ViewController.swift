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
    @IBOutlet weak var resetButton: UIButton!
    let scene = SCNScene()
    var cameraNode: SCNNode!
    var model: USDZNode!
    
    struct CameraPosition: Equatable {
        var position: SCNVector3
        var eulerAngles: SCNVector3
        var fieldOfView: CGFloat?

        static func == (lhs: ViewController.CameraPosition, rhs: ViewController.CameraPosition) -> Bool {
            return lhs.position == rhs.position && lhs.eulerAngles == rhs.eulerAngles && lhs.fieldOfView == rhs.fieldOfView
        }
    }
    var prevCameraPosition: CameraPosition? = nil
    var isAnimating: Bool = false
    var isSwiping: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        setUp()
    }

    @IBAction func onTappedResetButton(_ sender: Any) {
//        sceneView.pointOfView?.position = cameraNode.position
//        sceneView.pointOfView?.eulerAngles = cameraNode.eulerAngles

        sceneView.pointOfView?.removeAllActions()
        
        let duration: CGFloat = 0.5
        let move = SCNAction.move(to: cameraNode.position, duration: duration)
        let rotate = SCNAction.rotateTo(
            x: CGFloat(cameraNode.eulerAngles.x),
            y: CGFloat(cameraNode.eulerAngles.y),
            z: CGFloat(cameraNode.eulerAngles.z),
            duration: duration
        )
        let startZoom = sceneView.pointOfView?.camera?.fieldOfView ?? 0
        let endZoom = cameraNode.camera?.fieldOfView ?? 0
        let zoom = SCNAction.customAction(duration: duration) { (node, elapsedTime) in
            node.camera?.fieldOfView = startZoom + (endZoom - startZoom) * (elapsedTime / duration)
        }
        let action = SCNAction.group([move, rotate, zoom])
        action.timingMode = .easeOut
        sceneView.pointOfView?.runAction(action)
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
        setUpGesture()
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
        toyBiplane.showBoundingBox()
        toyBiplane.createSizeText()
        //toyBiplane.setHighlighted()
        toyBiplane.createOutsideEdge()
        model = toyBiplane
    }

    func setUpGesture() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(onSwipeScene(_:)))
        panGestureRecognizer.delegate = self
        sceneView.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc private func onSwipeScene(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began, .changed:
            isSwiping = true
        default:
            isSwiping = false
        }
    }
}

extension ViewController: SCNSceneRendererDelegate {

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if let pointOfView = sceneView.pointOfView {
            model.updateSizeText(cameraPosition: pointOfView.position)
            model.updateOutsideEdge(cameraPosition: pointOfView.position)
            
            let cameraPosition = CameraPosition(
                position: pointOfView.position,
                eulerAngles: pointOfView.eulerAngles,
                fieldOfView: pointOfView.camera?.fieldOfView
            )
            let isAnimating = isSwiping || prevCameraPosition != cameraPosition
            if self.isAnimating != isAnimating {
                self.isAnimating = isAnimating
                DispatchQueue.main.async { [weak self] in
                    self?.resetButton.isEnabled = !isAnimating
                }
            }
            prevCameraPosition = cameraPosition
        }
    }

}

extension ViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}
