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

    @IBOutlet var sceneView: ARSCNView!
    
    @IBAction func resetButton(_ sender: Any) {
        sceneView.session.pause()
        let configuration = ARWorldTrackingConfiguration()
        let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil)!
        configuration.detectionImages = referenceImages
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        DispatchQueue.main.async {
            self.label?.isHidden = true
            self.infoLabel?.isHidden = true
        }
    }
    
    var label: UILabel!
    var infoLabel: UILabel!
    var detectedText: String?
    
    // set sceneView to self to respond to events
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.showsStatistics = false
        sceneView.scene = SCNScene()
    }
    
    func setupFlatText() {
        label = UILabel()
        label.text = "This is rush rhees"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        label.isHidden = true

        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)

        // constraints
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            label.widthAnchor.constraint(equalToConstant: 300),
            label.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // UI info label
        infoLabel = UILabel()
        infoLabel.text = "Information about the image will appear here."
                infoLabel.textColor = .white
                infoLabel.textAlignment = .center
                infoLabel.font = UIFont.systemFont(ofSize: 18)
                infoLabel.numberOfLines = 0 // Allow multiple lines for paragraph
                infoLabel.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                infoLabel.layer.cornerRadius = 10
                infoLabel.layer.masksToBounds = true
                infoLabel.isHidden = true
                
                infoLabel.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(infoLabel)

                // Constraints for the second label (info paragraph)
                NSLayoutConstraint.activate([
                    infoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    infoLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                    infoLabel.widthAnchor.constraint(equalToConstant: 300),
                    infoLabel.heightAnchor.constraint(equalToConstant: 200)
                ])
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        // detect image from "AR Resource" group
        // ARKit looks for reference image
        let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil)!
        configuration.detectionImages = referenceImages
        sceneView.session.run(configuration)
    }
    
    // pause AR session when view disappears
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
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
        
        DispatchQueue.main.async {
            if self.label == nil || self.infoLabel == nil {
                self.setupFlatText()
            }
//            self.label.text = "Detected: \(imageAnchor.referenceImage.name ?? "Image")"
            
            switch referenceImage.name {
            case "rr_2":
                self.label.text = "Detected: Rush Rhees"
                self.infoLabel.text = "Located on the River Campus and named after Rush Rhees, former president of the University of Rochester (3rd president). With a distinctive tower that stands 186 feet (57m) tall and houses the Hopeman Memorial Carillon, the largest musical instrument in Rochester. Some key features include the Art and Music Library, Department of Rare Books, Special Collections & Preservation, Gleason Library, Rossell Hope Robbins Library for medieval studies, and University Archives."
            case "keyboard":
                self.label.text = "Detected: Image 2"
                self.infoLabel.text = "This is a detailed description of Image 2. Here you can explain the significance or details about the second image."
            case "image3":
                self.label.text = "Detected: Image 3"
                self.infoLabel.text = "This is a detailed description of Image 3. A paragraph of information can go here, giving the user more context."
            default:
                self.label.text = "Unknown Image"
                self.infoLabel.text = "This image does not match any known references."
            }
            
            self.label.isHidden = false
            self.infoLabel.isHidden = false
        }
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
