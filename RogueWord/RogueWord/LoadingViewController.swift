//
//  LoadingViewController.swift
//  RogueWord
//
//  Created by shachar on 2024/9/27.
//

import UIKit
import SpriteKit

class LoadingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 創建一個 SKView
        let skView = SKView(frame: self.view.frame)
        self.view.addSubview(skView)
        
        // 載入 GameScene
        let scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        
        // 顯示 GameScene
        skView.presentScene(scene)
        
        // 顯示 FPS 及畫面更新資訊
        skView.showsFPS = true
        skView.showsNodeCount = true
    }
}
