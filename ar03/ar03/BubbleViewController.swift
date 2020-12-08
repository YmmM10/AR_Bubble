//
//  BubbleViewController.swift
//  ARKit-Emperor
//
//  Created by Kei Fujikawa on 2018/12/18.
//  Copyright © 2018 KBOY. All rights reserved.
//
import UIKit
import ARKit

class BubbleViewController: UIViewController {
    @IBOutlet var sceneView: ARSCNView!
    
    let defaultConfiguration: ARWorldTrackingConfiguration = {
        //スマートフォンの向きと位置を把握する
        let configuration = ARWorldTrackingConfiguration()
        //configuration.planeDetection = .horizontal
        //configuration.environmentTexturing = .automatic
        return configuration
    }()
    
    override func viewDidLoad() {
        //なんかやったほうがいいやつらしい
        //戻り値がない時にやったほうがいいやつ
        super.viewDidLoad()
        //多分明るさ
        sceneView.autoenablesDefaultLighting = true
        //デバッグの黄色い点
        //平面を検知して平面に黄色い点が出るだけなので、コメントアウトした
        //sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sceneView.session.run(defaultConfiguration)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //球作成
        let bubble = SCNSphere(radius: 0.1)
        //透けるための処理
        bubble.firstMaterial?.transparency = 0.25
        //重なってもどちらも描画される
        bubble.firstMaterial?.writesToDepthBuffer = false
        
        //シャボン玉のnode
        let node = SCNNode(geometry: bubble)
        node.position = SCNVector3Make(0, 0.1, 0)
        //親のノードを作る
        let parentNode = SCNNode()
        parentNode.addChildNode(node)
        
        if let camera = sceneView.pointOfView {
            parentNode.position = camera.position
            
            // Animation like bubble
            let wait = SCNAction.wait(duration: 0.2)
            
            let speedsArray: [TimeInterval] = [0.5, 1.0, 1.5]
            let speed: TimeInterval = speedsArray[Int(arc4random_uniform(UInt32(speedsArray.count)))]
            
            let toPositionCamera = SCNVector3Make(0, 0, -2)
            let toPosition = camera.convertPosition(toPositionCamera, to: nil)
            //飛んでいくアニメーション
            let move = SCNAction.move(to: toPosition, duration: speed)
            move.timingMode = .easeOut
            let group = SCNAction.sequence([wait, move])
            parentNode.runAction(group) {
                //ふわふわ動くアニメーション
                let rotate = SCNAction.rotateBy(x: 0, y: 0, z: 1, duration: 1)
                let roop = SCNAction.repeatForever(rotate)
                parentNode.runAction(roop)
            }
        }
        sceneView.scene.rootNode.addChildNode(parentNode)
    }
    
}
