//
//  ViewController.swift
//  ARCampus
//
//  Created by Michael Liu on 11/21/24.
//

import UIKit
import SceneKit
import ARKit
import SwiftUI

class ViewController: UIViewController, ARSCNViewDelegate {

    // UI Elements
    @IBOutlet weak var helpButton: UIImageView!
    @IBOutlet var sceneView: ARSCNView!
    @IBAction func showHistory(_ sender: Any) {
        let history = UIHostingController(rootView: HistoryViewController(scannedHistory: self.scannedHistory))
        self.present(history, animated: true, completion: nil)
    }
    
    // Saved variables
    var label: UILabel!
    var infoLabel: UILabel!
    var scannedHistory: [(name: String, date: Date, detailText: String)] = []
    
    // Lifecycle Methods
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
        if reset{
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
            
            // Text can be further curated to make it more relevant for users
            switch referenceImage.name {
            case "rr_1":
                self.label.text = "Detected: Rush Rhees"
                self.infoLabel.text = "Located on the River Campus and named after Rush Rhees, former president of the University of Rochester (3rd president). With a distinctive tower that stands 186 feet (57m) tall and houses the Hopeman Memorial Carillon, the largest musical instrument in Rochester. Some key features include the Art and Music Library, Department of Rare Books, Special Collections & Preservation, Gleason Library, Rossell Hope Robbins Library for medieval studies, and University Archives."
                self.scannedHistory.append(("Rush Rhees", Date(), self.infoLabel.text ?? ""))
            case "carlson":
                self.label.text = "Detected: Carlson Painting"
                self.infoLabel.text = "Painting of Chester Carlson. A physicist, lawyer, inventor, and humanitarian. He was a generous benefactor of this University he invented an electrostatic printing process called xerography -- a process that not only solved a major problem in office-copying, but radically transformed the entire field of communication."
                self.scannedHistory.append(("Carlson", Date(), self.infoLabel.text ?? ""))
            case "StudioX":
                self.label.text = "Detected: Studio X"
                self.infoLabel.text = "Studio X is the University of Rochester's central hub for extended reality (XR), offering a collaborative space, advanced technology, expert guidance, and a thriving community. Located on the first floor of Carlson Library, our 3,000 square foot lab provides access to a wide range of XR equipment for students, faculty, and staff. We host skill-building workshops and personalized consultations to support XR content creation and development. Studio X also connects over 50 XR researchers across various disciplines, fostering collaboration and innovation in XR technologies at UR."
                self.scannedHistory.append(("Studio X", Date(), self.infoLabel.text ?? ""))
            case "studiox_b1":
                self.label.text = "Detected: Studio X Welcome Board"
                self.infoLabel.text = "Welcome Board located in Studio X."
                self.scannedHistory.append(("Studio X Board", Date(), self.infoLabel.text ?? ""))
            case "studiox_b2":
                self.label.text = "Detected: Studio X Board"
                self.infoLabel.text = "Reminder Board located in Studio X."
                self.scannedHistory.append(("Studio X Board 2", Date(), self.infoLabel.text ?? ""))
            case "studiox_b3":
                self.label.text = "Detected: UV Reminder Board"
                self.infoLabel.text = "Board located in Studio X."
                self.scannedHistory.append(("UV Reminder Board", Date(), self.infoLabel.text ?? ""))
            case "studiox_b5":
                self.label.text = "Detected: Studio X Help Board"
                self.infoLabel.text = "Help Board located in Studio X."
                self.scannedHistory.append(("Studio X Help Board", Date(), self.infoLabel.text ?? ""))
            case "poster":
                self.label.text = "Detected: Amazing Poster Board"
                self.infoLabel.text = "Poster Board located in Studio X. Perhaps the best thing you have ever seen"
                self.scannedHistory.append(("Amazing Poster Board", Date(), self.infoLabel.text ?? "")) 
            
                
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
    
    @objc func showHistory() {
        let history = UIHostingController(rootView: HistoryViewController(scannedHistory: scannedHistory))
        let navController = UINavigationController(rootViewController: history)
        present(navController, animated: true, completion: nil)
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
