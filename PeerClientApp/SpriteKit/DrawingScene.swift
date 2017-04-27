//
//  DrawingScene.swift
//  mySpriteKitDemo
//
//  Created by Akira Murao on 9/25/15.
//  Copyright (c) 2017 Akira Murao. All rights reserved.
//

import SpriteKit

protocol DrawingSceneTouchDelegate {
    func drawingScene(drawingScene: DrawingScene!, shouldBeginTouchWithPoint point: CGPoint!)
    func drawingScene(drawingScene: DrawingScene!, didBeginTouchWithPoint point: CGPoint!)
    func drawingScene(drawingScene: DrawingScene!, didMoveTouchWithPoint point: CGPoint!)
    func drawingScene(drawingScene: DrawingScene!, didEndTouchWithPoint point: CGPoint!)
}

class DrawingScene: SKScene {
    
    let particleFileName = "DrawingParticle"
    //let particleFileName = "MyFireParticle"
    //let particleFileName = "MyBokehParticle"
    
    var touchDelegate: DrawingSceneTouchDelegate?
    
    lazy var particleColor: UIColor = UIColor.blue
    
    private lazy var cleanParticlesTimer: Timer? = nil
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
       /* Called when a touch begins */
        
        self.cleanParticles()
        self.cleanParticlesTimer?.invalidate()
        
        //for touch in touches {
         if let touch = touches.first as UITouch! {
            let location = touch.location(in: self)
            self.touchDelegate?.drawingScene(drawingScene: self, shouldBeginTouchWithPoint: location)
            
            addDrawingParticle(point: location)
            
            self.touchDelegate?.drawingScene(drawingScene: self, didBeginTouchWithPoint: location)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {

        //for touch in touches {
        if let touch = touches.first as UITouch! {
            let location = touch.location(in: self)
            self.children.last?.position = location
            
            self.touchDelegate?.drawingScene(drawingScene: self, didMoveTouchWithPoint: location)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

        super.touchesEnded(touches, with: event)
        
        //for touch in touches {
        if let touch = touches.first as UITouch! {
            let location = touch.location(in: self)
            
            self.touchDelegate?.drawingScene(drawingScene: self, didEndTouchWithPoint: location)
        }
        
        self.cleanParticlesTimer?.invalidate()
        self.cleanParticlesTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(cleanParticles), userInfo: nil, repeats: false)
    }
    
    func cleanParticles() {
        self.removeAllChildren()
    }
   
//    override func update(currentTime: CFTimeInterval) {
//        /* Called before each frame is rendered */
//    }
    
    func addDrawingParticle(point: CGPoint) {
        
        self.removeAllChildren()
        
        if let path = Bundle.main.path(forResource: particleFileName, ofType: "sks") {
            if let emitter = NSKeyedUnarchiver.unarchiveObject(withFile: path) as? SKEmitterNode {
                emitter.position = CGPoint(x: point.x, y: point.y)
                emitter.particleColor = self.particleColor
                emitter.particleColorBlendFactor = 1.0
                emitter.particleColorSequence = nil
                emitter.targetNode = self.scene
                self.addChild(emitter)
                
                // TODO: do this in timer after touchEnd
                /*
                let fadeOut = SKAction.fadeOutWithDuration(2.0)
                let remove = SKAction.removeFromParent()
                let sequence = SKAction.sequence([fadeOut, remove])
                emitter.runAction(sequence)
                */
            }
        }
    }
    
    // MARK: public for draw
    
    func beginTouch(point: CGPoint!) {
        
        self.cleanParticles()
        self.cleanParticlesTimer?.invalidate()
        
        addDrawingParticle(point: point)
    }
    
    func moveTouch(point: CGPoint!) {
        
        self.children.last?.position = point
    }
    
    func endTouch(point: CGPoint!) {
        
        self.cleanParticlesTimer?.invalidate()
        self.cleanParticlesTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(cleanParticles), userInfo: nil, repeats: false)
    }
    
}
