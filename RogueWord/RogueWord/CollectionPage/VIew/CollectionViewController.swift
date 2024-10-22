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
        
        skView = SKView(frame: self.view.bounds)
        skView.backgroundColor = UIColor.clear
        skView.isOpaque = false
        view.addSubview(skView)
        
        viewModel.fetchTagFromFirebase()
        
        viewModel.onTagChange = { [weak self] in
            self?.setupCollectionGameScene()
            print("Data has changed, scene is reloaded.")
        }
    }
    
    func setupCollectionGameScene() {
        if let currentScene = currentScene {
            currentScene.removeAllActions()
            currentScene.removeAllChildren()
            skView.presentScene(nil)
        }
        
        let scene = CollectionGameScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        scene.tags = viewModel.tags
        scene.viewController = self
        
        scene.onDeletionComplete = { [weak self] in
            DispatchQueue.main.async {
                self?.viewModel.fetchTagFromFirebase()
            }
        }
        
        skView.presentScene(scene)
        currentScene = scene
    }
}
