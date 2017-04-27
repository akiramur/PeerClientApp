//
//  ParticleViewController.swift
//  mySpriteKitDemo
//
//  Created by Akira Murao on 9/25/15.
//  Copyright (c) 2017 Akira Murao. All rights reserved.
//

import UIKit
import SpriteKit
import PeerClient

class ParticleViewController: UIViewController, DrawingSceneTouchDelegate {
    
    var peer: Peer?
    
    var particleColor: UIColor {
        get {
            var color = UIColor.blue
            
            let skView = self.view as! SKView
            if let scene = skView.scene as? DrawingScene {
                color = scene.particleColor
            }
            
            return color
        }
        set (newColor) {
            let skView = self.view as! SKView
            if let scene = skView.scene as? DrawingScene {
                scene.particleColor = newColor
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let scene = DrawingScene(fileNamed:"DrawingScene") {
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            skView.allowsTransparency = true
            scene.backgroundColor = UIColor.clear
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .aspectFill
            
            scene.touchDelegate = self
            
            skView.presentScene(scene)
        }
    }

/*
    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }
*/
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    /*
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    */
    
    // MARK: public

    func draw(_ data: Data) {

        print("peer didReceive data")

        let dp = ParticleData(data: data)

        switch dp.eventType {
        case .TouchBegin:
            let touchEvent = dp.touchEvent()
            let point = CGPoint(x: touchEvent.x, y: touchEvent.y)
            self.beginTouch(point: point)

        case .TouchMove:
            let touchEvent = dp.touchEvent()
            let point = CGPoint(x: touchEvent.x, y: touchEvent.y)
            self.moveTouch(point: point)

        case .TouchEnd:
            let touchEvent = dp.touchEvent()
            let point = CGPoint(x: touchEvent.x, y: touchEvent.y)
            self.endTouch(point: point)

        default:
            break
        }
    }

    // MARK: private for draw

    func beginTouch(point: CGPoint!) {
        
        let skView = self.view as! SKView
        if let scene = skView.scene as? DrawingScene {
            scene.particleColor = UIColor.red
            scene.beginTouch(point: point)
        }
    }
    
    func moveTouch(point: CGPoint!) {
        
        let skView = self.view as! SKView
        if let scene = skView.scene as? DrawingScene {
            scene.moveTouch(point: point)
        }
    }
    
    func endTouch(point: CGPoint!) {
        
        let skView = self.view as! SKView
        if let scene = skView.scene as? DrawingScene {
            scene.endTouch(point: point)
        }
    }
    
    // MARK: DrawingSceneTouchDelegate
    
    func drawingScene(drawingScene: DrawingScene!, shouldBeginTouchWithPoint point: CGPoint!) {
        let skView = self.view as! SKView
        if let scene = skView.scene as? DrawingScene {
            scene.particleColor = UIColor.blue
        }
    }
    
    func drawingScene(drawingScene: DrawingScene!, didBeginTouchWithPoint point: CGPoint!) {

        guard self.peer?.dataConnections.count == 1 else {
            return
        }

        guard let dataConnection = self.peer?.dataConnections.first as? DataConnection else {
            return
        }

        let dp = ParticleData(event: .TouchBegin, x: Double(point.x), y: Double(point.y))
        dataConnection.sendData(bytes: dp.byteArray)

    }
    
    func drawingScene(drawingScene: DrawingScene!, didMoveTouchWithPoint point: CGPoint!) {

        guard self.peer?.dataConnections.count == 1 else {
            return
        }

        guard let dataConnection = self.peer?.dataConnections.first as? DataConnection else {
            return
        }


        let dp = ParticleData(event: .TouchMove, x: Double(point.x), y: Double(point.y))
        dataConnection.sendData(bytes: dp.byteArray)
    }
    
    func drawingScene(drawingScene: DrawingScene!, didEndTouchWithPoint point: CGPoint!) {

        guard self.peer?.dataConnections.count == 1 else {
            return
        }

        guard let dataConnection = self.peer?.dataConnections.first as? DataConnection else {
            return
        }

        let dp = ParticleData(event: .TouchEnd, x: Double(point.x), y: Double(point.y))
        dataConnection.sendData(bytes: dp.byteArray)
    }
}
