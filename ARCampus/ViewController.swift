//
//  ViewController.swift
//  ARCampus
//
//  Created by Michael Liu on 11/21/24.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView! // connects view from SceneKit from storyboard rendering AR experience
    
    @IBAction func resetButton(_ sender: Any) {
        sceneView.session.pause()
        let configuration = ARWorldTrackingConfiguration()
        let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil)!
        configuration.detectionImages = referenceImages
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    // set sceneView to self to respond to events
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = false
        
        // Create a empty scene
        sceneView.scene = SCNScene()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        // 6-DOF tracking
        let configuration = ARWorldTrackingConfiguration()
        
        
        
        
        // detect image from "AR Resource" group
        // ARKit looks for reference image
        let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil)!
        configuration.detectionImages = referenceImages
        //
        
        
        
        

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    // pause AR session when view disappears
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    // called when ARKit detects image
    // cast anchor to imageanchor to access detected imageproperties
    // semi transparent blue plane (SCNPlane)
    // rotate plan to lie flat
    // attch node associated with anchor
    func renderer(_ renderer: any SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        
        let referenceImage = imageAnchor.referenceImage
        
        let plane = SCNPlane(width: referenceImage.physicalSize.width, height: referenceImage.physicalSize.height)
        plane.firstMaterial?.diffuse.contents = UIColor.blue
        let planeNode = SCNNode(geometry: plane)
        planeNode.opacity = 0.25
        planeNode.eulerAngles.x = -Float.pi / 2
        node.addChildNode(planeNode)
        
        // adding text
        let text = SCNText(string: "This is a keyboard", extrusionDepth: 0.01)
        text.font = UIFont.systemFont(ofSize: 50)
        text.firstMaterial?.diffuse.contents = UIColor.white
        let textNode = SCNNode(geometry: text)
        
        textNode.scale = SCNVector3(0.01, 0.01, 0.01)
        textNode.position = SCNVector3(0, 0.1, 0)
                          

        node.addChildNode(textNode)
    
    }
    
    
    // Error handling
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
