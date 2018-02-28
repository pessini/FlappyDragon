//
//  GameScene.swift
//  FlappyDragon
//
//  Created by Leandro Pessini on 31/01/2018.
//  Copyright © 2018 Leandro Pessini. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var floor: SKSpriteNode!
    var intro: SKSpriteNode!
    var player: SKSpriteNode!
    var gameArea: CGFloat = 410.0
    var velocity: Double = 100.0
    var gameFinished = false
    var gameStarted = false
    var restart = false
    var scoreLabel: SKLabelNode!
    var score: Int = 0
    var flyForce: CGFloat = 25.0
    var playerCategory: UInt32 = 1
    var enemyCategory: UInt32 = 2
    var scoreCategory: UInt32 = 4
    var timer: Timer!
    weak var gameViewController: GameViewController?
    let scoreSound = SKAction.playSoundFileNamed("score.mp3", waitForCompletion: false)
    let gameOverSound = SKAction.playSoundFileNamed("hit.mp3", waitForCompletion: false)
    
    override func didMove(to view: SKView) {

        physicsWorld.contactDelegate = self

        addBackground()
        addFloor()
        addIntro()
        addPlayer()
        moveFloor()
    }

    func addBackground() {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0 // mais afastada
        addChild(background)
    }

    func addFloor() {
        floor = SKSpriteNode(imageNamed: "floor")
        floor.zPosition = 2
        floor.position = CGPoint(x: floor.size.width/2, y: size.height - gameArea - floor.size.height/2)
        addChild(floor)

        let invisibleFloor = SKNode()
        invisibleFloor.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width, height: 1))
        invisibleFloor.physicsBody?.isDynamic = false
        invisibleFloor.position = CGPoint(x: size.width/2, y: size.height - gameArea)
        invisibleFloor.zPosition = 2

        invisibleFloor.physicsBody?.categoryBitMask = enemyCategory
        invisibleFloor.physicsBody?.contactTestBitMask = playerCategory

        addChild(invisibleFloor)

        let invisibleRoof = SKNode()
        invisibleRoof.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width, height: 1))
        invisibleRoof.physicsBody?.isDynamic = false
        invisibleRoof.position = CGPoint(x: size.width/2, y: size.height)
        invisibleRoof.zPosition = 2
        addChild(invisibleRoof)
    }

    func addIntro() {
        intro = SKSpriteNode(imageNamed: "intro")
        intro.zPosition = 3
        intro.position = CGPoint(x: size.width/2, y: size.height - gameArea/2)
        addChild(intro)
    }

    func addPlayer() {
        player = SKSpriteNode(imageNamed: "player1")
        player.zPosition = 4
        player.position = CGPoint(x: 60, y: size.height - gameArea/2)

        var playerTextures = [SKTexture]()
        for i in 1...4 {
            playerTextures.append(SKTexture(imageNamed: "player\(i)"))
        }
        let animationAction = SKAction.animate(with: playerTextures, timePerFrame: 0.09)
        let repeatAction = SKAction.repeatForever(animationAction)
        player.run(repeatAction)

         addChild(player)
    }

    func moveFloor() {
        // espaço sobre tempo?
        let duration = Double(floor.size.width/2) / velocity
        // é - pq quero que ele vá para a esquerda
        let moveFloorAction = SKAction.moveBy(x: -floor.size.width/2, y: 0, duration: duration)
        let resetXAction = SKAction.moveBy(x: floor.size.width/2, y: 0, duration: 0)
        let sequenceAction = SKAction.sequence([moveFloorAction, resetXAction])
        let repeatAction = SKAction.repeatForever(sequenceAction)
        floor.run(repeatAction)
    }

    func addScore() {
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.fontSize = 94
        scoreLabel.text = "\(score)"
        scoreLabel.zPosition = 5
        scoreLabel.position = CGPoint(x: size.width/2, y: size.height - 100)
        scoreLabel.alpha = 0.8 // por padrão a cor é branca
        addChild(scoreLabel)
    }

    func spawnEnemies() {
        let initialPosition = CGFloat(arc4random_uniform(132) + 74)
        let enemyNumber = Int(arc4random_uniform(4) + 1)
        let enemiesDistance = self.player.size.height * 2.5

        let enemyTop = SKSpriteNode(imageNamed: "enemytop\(enemyNumber)")
        let enemyWidth = enemyTop.size.width
        let enemyHeight = enemyTop.size.height

        enemyTop.position = CGPoint(x: size.width + enemyWidth/2, y: size.height - initialPosition + enemyHeight/2)
        enemyTop.zPosition = 1
        enemyTop.physicsBody = SKPhysicsBody(rectangleOf: enemyTop.size)
        enemyTop.physicsBody?.isDynamic = false

        enemyTop.physicsBody?.categoryBitMask = enemyCategory
        enemyTop.physicsBody?.contactTestBitMask = playerCategory

        let enemyBottom = SKSpriteNode(imageNamed: "enemybottom\(enemyNumber)")
        enemyBottom.position = CGPoint(x: size.width + enemyWidth/2, y: enemyTop.position.y - enemyTop.size.height - enemiesDistance)
        enemyBottom.zPosition = 1
        enemyBottom.physicsBody = SKPhysicsBody(rectangleOf: enemyBottom.size)
        enemyBottom.physicsBody?.isDynamic = false

        enemyBottom.physicsBody?.categoryBitMask = enemyCategory
        enemyBottom.physicsBody?.contactTestBitMask = playerCategory

        let laser = SKNode()
        laser.position = CGPoint(x: enemyTop.position.x + enemyWidth/2, y: enemyTop.position.y - enemyTop.size.height/2 - enemiesDistance/2)
        laser.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 1, height: enemiesDistance))
        laser.physicsBody?.isDynamic = false
        laser.physicsBody?.categoryBitMask = scoreCategory

        let distance = size.width + enemyHeight
        let duration = Double(distance)/velocity
        let moveAction = SKAction.moveBy(x: -distance, y: 0, duration: duration)
        let removeAction = SKAction.removeFromParent()
        let sequenceAction = SKAction.sequence([moveAction, removeAction])

        enemyTop.run(sequenceAction)
        enemyBottom.run(sequenceAction)
        laser.run(sequenceAction)

        addChild(enemyTop)
        addChild(enemyBottom)
        addChild(laser)
    }

    func gameOver() {
        timer.invalidate()
        player.zRotation = 0
        player.texture = SKTexture(imageNamed: "playerDead")

        for node in self.children {
            node.removeAllActions()
        }

        player.physicsBody?.isDynamic = false
        gameFinished = true
        gameStarted = false

        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { (timer) in
            let gameOverLabel = SKLabelNode(fontNamed: "Chalkduster")
            gameOverLabel.fontColor = .red
            gameOverLabel.fontSize = 40
            gameOverLabel.numberOfLines = 0
            gameOverLabel.preferredMaxLayoutWidth = self.size.width
            gameOverLabel.lineBreakMode = .byWordWrapping
            gameOverLabel.text = "Caraio! Game Over"
            gameOverLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/2)

            gameOverLabel.zPosition = 5
            self.addChild(gameOverLabel)
            self.restart = true
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !gameFinished {
            if !gameStarted {
                intro.removeFromParent()
                addScore()

                player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width/2 - 10)
                player.physicsBody?.isDynamic = true
                player.physicsBody?.allowsRotation = true
                player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: flyForce))
                player.physicsBody?.categoryBitMask = playerCategory
                player.physicsBody?.contactTestBitMask = scoreCategory
                player.physicsBody?.collisionBitMask = enemyCategory

                gameStarted = true

                timer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true, block: { (timer) in
                    self.spawnEnemies()
                })

            } else {
                player.physicsBody?.velocity = CGVector.zero
                player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: flyForce))
            }
        } else {
            if restart {
                restart = false
                gameViewController?.presentScene()
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if gameStarted {
            let yVelocity = player.physicsBody!.velocity.dy * 0.001 as CGFloat
            player.zRotation = yVelocity
        }
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        if gameStarted {
            if contact.bodyA.categoryBitMask == scoreCategory || contact.bodyB.categoryBitMask == scoreCategory {
                score += 1
                scoreLabel.text = "\(score)"
                run(scoreSound)
            } else if contact.bodyA.categoryBitMask == enemyCategory || contact.bodyB.categoryBitMask == enemyCategory {
                gameOver()
                run(gameOverSound)
            }
        }
    }
}
