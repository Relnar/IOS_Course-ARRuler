//
//  ViewController.swift
//  ARRuler
//
//  Created by Pierre-Luc Bruyere on 2018-11-10.
//  Copyright © 2018 Pierre-Luc Bruyere. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate
{
  // MARK: - Attributes

  @IBOutlet var sceneView: ARSCNView!

  private let dotGeometry = SCNSphere(radius: 0.005)
  private let dotMaterial = SCNMaterial()
  private var dotNodes = [SCNNode]()
  private var textNode : SCNNode?

  // MARK: -

  override func viewDidLoad()
  {
    super.viewDidLoad()

    // Set the view's delegate
    sceneView.delegate = self

    sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]

    dotMaterial.diffuse.contents = UIColor.red
    dotGeometry.materials = [dotMaterial]
  }

  override func viewWillAppear(_ animated: Bool)
  {
    super.viewWillAppear(animated)

    // Create a session configuration
    let configuration = ARWorldTrackingConfiguration()

    // Run the view's session
    sceneView.session.run(configuration)
  }

  override func viewWillDisappear(_ animated: Bool)
  {
    super.viewWillDisappear(animated)

    // Pause the view's session
    sceneView.session.pause()
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
  {
    if let touchLocation = touches.first?.location(in: sceneView)
    {
      let hitTestResult = sceneView.hitTest(touchLocation, types: .featurePoint)
      if let hitResult = hitTestResult.first
      {
        addDot(at: hitResult)

        calculate()
      }
    }
  }

  // MARK: - Private methods

  private func addDot(at hitResult: ARHitTestResult)
  {
    let dotNode = SCNNode(geometry: dotGeometry)
    dotNode.position = SCNVector3(hitResult.worldTransform.columns.3.x,
                                  hitResult.worldTransform.columns.3.y + Float(dotGeometry.radius),
                                  hitResult.worldTransform.columns.3.z)

    sceneView.scene.rootNode.addChildNode(dotNode)

    dotNodes.append(dotNode)
  }

  private func calculate()
  {
    if dotNodes.count < 2
    {
      return
    }

    let start = dotNodes[0]
    let end = dotNodes[1]

    if dotNodes.count > 2
    {
      dotNodes.removeFirst()
      dotNodes.removeFirst()
      start.removeFromParentNode()
      end.removeFromParentNode()
      return
    }

    let distances = SCNVector3(end.position.x - start.position.x,
                               end.position.y - start.position.y,
                               end.position.z - start.position.z)
    let distance = sqrt(distances.x * distances.x +
                        distances.y * distances.y +
                        distances.z * distances.z)

    updateText(with: distance, distances)
  }

  private func updateText(with distance: Float, _ distances: SCNVector3)
  {
    let textGeometry = SCNText(string: String(distance), extrusionDepth: 1.0)
    textGeometry.materials = [dotMaterial]

    if let oldTextNode = textNode
    {
      oldTextNode.removeFromParentNode()
      textNode = nil
    }

    let newTextNode = SCNNode(geometry: textGeometry)
    newTextNode.position = SCNVector3(dotNodes[1].position.x - distances.x / 2,
                                      dotNodes[1].position.y - distances.y / 2,
                                      dotNodes[1].position.z - distances.z / 2)
    newTextNode.position.y += 0.01

    let scale = 0.01 * min(distance, 1.0)
    newTextNode.scale = SCNVector3(scale, scale, scale)

    sceneView.scene.rootNode.addChildNode(newTextNode)
    textNode = newTextNode
  }
}
