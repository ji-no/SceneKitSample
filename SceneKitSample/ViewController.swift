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
    @IBOutlet weak var pointImageView: UIImageView!
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
    var isMoving: Bool = false
    var isSwiping: Bool = false
    var isShaking: Bool = false
    var isStopAnimation: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUp()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func onTappedResetButton(_ sender: Any) {
        // sceneView.pointOfView?.position = cameraNode.position
        // sceneView.pointOfView?.eulerAngles = cameraNode.eulerAngles
        
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
        startShakeAnimation(after: 2.0)
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
        let cameraParentNode = SCNNode()
        cameraParentNode.addChildNode(cameraNode)
        scene.rootNode.addChildNode(cameraParentNode)
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
        let pinchiGestureReconizer = UIPinchGestureRecognizer(target: self, action: #selector(onPinchiScene(_:)))
        pinchiGestureReconizer.delegate = self
        sceneView.addGestureRecognizer(pinchiGestureReconizer)
    }
    
    @objc private func onSwipeScene(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began, .changed:
            isSwiping = true
        default:
            isSwiping = false
        }
        
        stopShakeAnimation()
    }
    
    @objc private func onPinchiScene(_ sender: UIPinchGestureRecognizer) {
        switch sender.state {
        case .began, .changed:
            isSwiping = true
        default:
            isSwiping = false
        }
        
        stopShakeAnimation()
    }

    func startShakeAnimation(after: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + after) { [weak self] in
            self?.shakeAnimationNode()
            self?.shakeAnimationPoint()
        }
    }
    
    func shakeAnimationNode() {
        let duration: CGFloat = 0.6
        let rad: CGFloat = .pi/8
        let rotate1 = SCNAction.rotateBy(
            x: 0,
            y: rad,
            z: 0,
            duration: duration
        )
        rotate1.timingFunction = { t in sin(t * .pi / 2) }
        let rotate2 = SCNAction.rotateBy(
            x: 0,
            y: -rad * 2,
            z: 0,
            duration: duration * 2
        )
        rotate2.timingFunction = { t in (1 - cos(t * .pi)) / 2 }
        let rotate3 = SCNAction.rotateBy(
            x: 0,
            y: rad,
            z: 0,
            duration: duration
        )
        rotate3.timingFunction = { t in 1 - cos(t * .pi / 2) }
        let action = SCNAction.sequence([rotate1, rotate2, rotate3])
        
        cameraNode.parent?.runAction(action)
    }
    
    func shakeAnimationPoint() {
        let duration: CGFloat = 0.6
        
        pointImageView.isHidden = false
        
        let start: CGFloat = sceneView.frame.width * 0.5
        let direction: CGFloat = sceneView.frame.width * 0.1
        
        let slide1 = CABasicAnimation(keyPath: "position.x")
        slide1.duration = duration
        slide1.fromValue = start
        slide1.toValue = start - direction
        slide1.fillMode = .forwards
        slide1.isRemovedOnCompletion = false
        slide1.timingFunction = CAMediaTimingFunction(controlPoints: 0.61, 1, 0.88, 1)
        let slide2 = CABasicAnimation(keyPath: "position.x")
        slide2.duration = duration * 2
        slide2.fromValue = start - direction
        slide2.toValue = start + direction
        slide2.fillMode = .forwards
        slide2.isRemovedOnCompletion = false
        slide2.timingFunction = CAMediaTimingFunction(controlPoints: 0.37, 0, 0.63, 1)
        let slide3 = CABasicAnimation(keyPath: "position.x")
        slide3.duration = duration
        slide3.fromValue = start + direction
        slide3.toValue = start
        slide3.fillMode = .forwards
        slide3.isRemovedOnCompletion = false
        slide3.timingFunction = CAMediaTimingFunction(controlPoints: 0.12, 0, 0.39, 0)
        
        isShaking = true
        CATransaction.begin()
        CATransaction.setCompletionBlock { [weak self] in
            CATransaction.begin()
            CATransaction.setCompletionBlock { [weak self] in
                CATransaction.begin()
                CATransaction.setCompletionBlock { [weak self] in
                    self?.pointImageView.isHidden = true
                    self?.isShaking = false
                    if self?.isStopAnimation != true {
                        self?.startShakeAnimation(after: 2.0)
                    }
                }
                self?.pointImageView.layer.add(slide3, forKey: slide3.keyPath)
                CATransaction.commit()
            }
            self?.pointImageView.layer.add(slide2, forKey: slide2.keyPath)
            CATransaction.commit()
        }
        pointImageView.layer.add(slide1, forKey: slide1.keyPath)
        CATransaction.commit()
    }
    
    func stopShakeAnimation() {
        cameraNode.parent?.removeAllActions()
        pointImageView.layer.removeAllAnimations()
        pointImageView.isHidden = true
        isShaking = false
        isStopAnimation = true
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
            let isMoving = isSwiping || isShaking || prevCameraPosition != cameraPosition
            if self.isMoving != isMoving {
                self.isMoving = isMoving
                DispatchQueue.main.async { [weak self] in
                    self?.resetButton.isEnabled = !isMoving
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
