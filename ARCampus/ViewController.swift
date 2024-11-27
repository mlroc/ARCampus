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

    // UI Elements
    @IBOutlet weak var helpButton: UIImageView!
    @IBOutlet var sceneView: ARSCNView!

    var label: UILabel!
    var infoLabel: UILabel!

    
    // Lifecycle Methodsdo i
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.showsStatistics = false
        sceneView.scene = SCNScene()
        setupHelpButton()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        runARSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    
    // UI Setup
    private func setupHelpButton() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(helpButtonTapped))
        helpButton.isUserInteractionEnabled = true
        helpButton.addGestureRecognizer(tapGesture)
    }
    
    private func createLabel(fontSize: CGFloat, numberOfLines: Int) -> UILabel {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: fontSize)
        label.numberOfLines = numberOfLines
        label.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    func setupFlatText() {
        label = createLabel(fontSize: 20, numberOfLines: 1)
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            label.widthAnchor.constraint(equalToConstant: 300),
            label.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
             scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
             scrollView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
             scrollView.widthAnchor.constraint(equalToConstant: 300),
             scrollView.heightAnchor.constraint(equalToConstant: 200)
         ])
        
        infoLabel = createLabel(fontSize: 18, numberOfLines: 0)
        scrollView.addSubview(infoLabel)
        NSLayoutConstraint.activate([
            infoLabel.topAnchor.constraint(equalTo: scrollView.topAnchor),
            infoLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            infoLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            infoLabel.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            infoLabel.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    
    // AR Session
    
    private func runARSession(reset: Bool = false) {
        let configuration = ARWorldTrackingConfiguration()
        if let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) {
            configuration.detectionImages = referenceImages
        }
        if reset {
            sceneView.session.run(configuration)
        }
        sceneView.session.run(configuration, options: reset ? [.resetTracking, .removeExistingAnchors] : [])
    }
    
    
    @IBAction func resetButton(_ sender: Any) {
        sceneView.session.pause()
        runARSession(reset: true)
        DispatchQueue.main.async {
            self.label?.isHidden = true
            self.infoLabel?.isHidden = true
        }
    }


    // AR Methods
    func renderer(_ renderer: any SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }

        DispatchQueue.main.async {
            self.displayDetectedImgInfo(imageAnchor: imageAnchor, node: node)
        }
    }
    
    private func displayDetectedImgInfo(imageAnchor: ARImageAnchor, node: SCNNode) {
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
            
            // self.label.text = "Detected: \(imageAnchor.referenceImage.name ?? "Image")"
            
            switch referenceImage.name {
            case "rr_1":
                self.label.text = "Detected: Rush Rhees"
                self.infoLabel.text = "Located on the River Campus and named after Rush Rhees, former president of the University of Rochester (3rd president). With a distinctive tower that stands 186 feet (57m) tall and houses the Hopeman Memorial Carillon, the largest musical instrument in Rochester. Some key features include the Art and Music Library, Department of Rare Books, Special Collections & Preservation, Gleason Library, Rossell Hope Robbins Library for medieval studies, and University Archives."
                
//            case "":
//                self.label.text =
//                self.infoLabel.text =
                
            default:
                self.label.text = "Detected: Unknown Image"
                self.infoLabel.text = "Please try again."
            }
            self.infoLabel.sizeToFit()
            self.label.isHidden = false
            self.infoLabel.isHidden = false
        }
    }
    
    @objc func helpButtonTapped() {
        let alert = UIAlertController(
            title: "Tutorial",
            message: "Point your camera at desired landmark or object. Press reset if new landmark isn't refreshing.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
