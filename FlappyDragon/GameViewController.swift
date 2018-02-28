//
//  GameViewController.swift
//  FlappyDragon
//
//  Created by Leandro Pessini on 31/01/2018.
//  Copyright © 2018 Leandro Pessini. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import AVFoundation

class GameViewController: UIViewController {

    var stage: SKView!
    var musicPlayer: AVAudioPlayer!

    override func viewDidLoad() {
        super.viewDidLoad()

        stage = view as! SKView
        stage.ignoresSiblingOrder = true

        presentScene()
        playMusic()
    }

    func playMusic() {
        if let musicURL = Bundle.main.url(forResource: "music", withExtension: "m4a") {
            musicPlayer = try! AVAudioPlayer(contentsOf: musicURL)
            musicPlayer.numberOfLoops = -1
            musicPlayer.volume = 0.4
            musicPlayer.play()
        }
    }

    func presentScene() {
        let scene = GameScene(size: CGSize(width: 320, height: 568)) // iphone 5S +
        scene.gameViewController = self
        scene.scaleMode = .aspectFill
        stage.presentScene(scene, transition: .doorsOpenVertical(withDuration: 0.5))
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
