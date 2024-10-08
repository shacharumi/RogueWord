//
//  CollectionViewController.swift
//  RogueWord
//
//  Created by shachar on 2024/10/6.
//

import UIKit
import SpriteKit
import FirebaseFirestore

class CollectionViewController: UIViewController {
    
    private let viewModel = CollectionPageViewModel()
    private var skView: SKView!
    private var currentScene: CollectionGameScene?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .yellow
        
        let backGroundView = UIImageView()
        backGroundView.image = UIImage(named: "examBackGround")
        view.addSubview(backGroundView)
        backGroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 初始化 SKView
        skView = SKView(frame: self.view.bounds)
        skView.backgroundColor = UIColor.clear
        skView.isOpaque = false // 允许透明背景
        view.addSubview(skView)
        
        // 获取数据
        viewModel.fetchTagFromFirebase()
        
        viewModel.onTagChange = { [weak self] in
            self?.setupCollectionGameScene()
            print("Data has changed, scene is reloaded.")
        }
    }
    
    func setupCollectionGameScene() {
        // 移除现有的场景（如果有）
        if let currentScene = currentScene {
            currentScene.removeAllActions()
            currentScene.removeAllChildren()
            skView.presentScene(nil)
        }
        
        // 创建新的场景
        let scene = CollectionGameScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        scene.tags = viewModel.tags // 传递数据
        scene.viewController = self
        
        // 设置闭包
        scene.onDeletionComplete = { [weak self] in
            DispatchQueue.main.async {
                self?.viewModel.fetchTagFromFirebase()
            }
        }
        
        skView.presentScene(scene)
        currentScene = scene
    }
}
