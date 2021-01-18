//
//  GameScene.swift
//  Breakout (New Version)
//
//  Created by  on 1/13/21.
//  Copyright © 2021 ZaCode. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let BallCategoryName = "ball"
    let PaddleCategoryName = "paddle"
    let BlockCategoryName = "block"
    
    var ball = SKSpriteNode()
    
    var isFingerOnPaddle = false
    
    let BallCategory: UInt32 = 0x1 << 0
    let BottomCategory : UInt32 = 0x1 << 1
    let BlockCategory : UInt32 = 0x1 << 2
    let PaddleCategory : UInt32 = 0x1 << 3
    let BorderCategory : UInt32 = 0x1 << 4
    
    
    var playerScoreLabel = SKLabelNode()
    var playerScore = 0
    {
        didSet
        {
            playerScoreLabel.text = "\(playerScore)"
        }
    }
    
    override func didMove(to view: SKView) {
        
        // Set border of the world to the frame
        let borderBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        borderBody.friction = 0.0
        self.physicsBody = borderBody
        // take gravity out of physics world.  Do this after you play for a little bit.
        physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
        // physicsWorld.gravity = CGVector(dx: 0.0, dy: -9.8)
        
        ball = childNode(withName: BallCategoryName) as! SKSpriteNode
        //ball.physicsBody?.applyImpulse(CGVector(dx: 20, dy: -20))
        
        let bottomRect = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: 1)
        let bottom = SKNode()
        bottom.physicsBody = SKPhysicsBody(edgeLoopFrom: bottomRect)
        addChild(bottom)
        
        
        let paddle = childNode(withName: PaddleCategoryName) as! SKSpriteNode
        
        
        bottom.physicsBody!.categoryBitMask = BottomCategory
        ball.physicsBody!.categoryBitMask = BallCategory
        paddle.physicsBody!.categoryBitMask = PaddleCategory
        borderBody.categoryBitMask = BorderCategory
        
        ball.physicsBody!.contactTestBitMask = BottomCategory | BlockCategory
        
        physicsWorld.contactDelegate = self
        createBlocks()
        createLabels()
    }
    
    func breakBlock(node: SKNode) {
        node.removeFromParent()
    }
    
    func createBlocks() {
        let numberOfBlocks = 8
        let blockWidth = SKSpriteNode(imageNamed: "block").size.width
        let totalBlockWidth = blockWidth * CGFloat(numberOfBlocks)
        
        let xOffset = (frame.width - totalBlockWidth) / 2
        
        for i in 0..<numberOfBlocks {
            let block = SKSpriteNode(imageNamed: "block")
            block.position = CGPoint(x: xOffset + CGFloat(CGFloat(i) + 0.5) * blockWidth, y: frame.height * 0.8)
            block.physicsBody = SKPhysicsBody(rectangleOf: block.frame.size)
            block.physicsBody!.allowsRotation = false
            block.physicsBody!.friction = 0.0
            block.physicsBody!.affectedByGravity = false
            block.physicsBody!.isDynamic = false
            block.name = "block"
            block.physicsBody!.categoryBitMask = BlockCategory
            block.zPosition = 1
            addChild(block)
        }
    }
    
    func createLabels() {
            playerScoreLabel = SKLabelNode(fontNamed: "Avenir")
            playerScoreLabel.text = "0"
            playerScoreLabel.fontSize = 75
            playerScoreLabel.color = UIColor.white
            playerScoreLabel.position = CGPoint(x: frame.width*0.25, y: frame.height*0.2)
            addChild(playerScoreLabel)
        }
    
    func didBegin(_ contact: SKPhysicsContact) {
           
           let firstBody : SKPhysicsBody
           let secondBody : SKPhysicsBody
           
           
           if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
               firstBody = contact.bodyA
               secondBody = contact.bodyB
           } else {
               firstBody = contact.bodyB
               secondBody = contact.bodyA
           }
           
           if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == BottomCategory {
               print("ball hit bottom")
           }
           
           if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == BlockCategory {
               print("ball Hit Block")
               playerScore += 1
               breakBlock(node: secondBody.node!)
           }
           
       }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        // self is a SKScene, so we can use self there
        let touchLocation = touch!.location(in: self)
        print("touch location")
        if let body = physicsWorld.body(at: touchLocation) {
            if body.node?.name == PaddleCategoryName {
                print("Began touch on Paddle")
                isFingerOnPaddle = true
            }
        }
        if let body = physicsWorld.body(at: touchLocation) {
            if body.node?.name == BallCategoryName {
                print("Reset Ball Position")
                ball.physicsBody?.applyImpulse(CGVector(dx: 400, dy: 400))
            }
        }
        
    }
        
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.location(in:self)
        let previousLocation = touch!.previousLocation(in: self)
        let myPaddle = childNode(withName: PaddleCategoryName) as! SKSpriteNode
        
        var paddlex = myPaddle.position.x + (touchLocation.x - previousLocation.x)
                  paddlex = max(paddlex, myPaddle.size.width/2.0)
                  paddlex = min(paddlex, size.width - myPaddle.size.width/2.0)
                  
                  myPaddle.position = CGPoint(x: paddlex, y: myPaddle.position.y)
        
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isFingerOnPaddle = false
    }
}
