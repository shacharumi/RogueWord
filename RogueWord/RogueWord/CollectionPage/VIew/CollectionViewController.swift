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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .yellow
        
        let backGroundView = UIImageView()
        backGroundView.image = UIImage(named: "examBackGround")
        view.addSubview(backGroundView)
        backGroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // 获取数据
        viewModel.fetchTagFromFirebase()
        
        viewModel.onTagChange = { [weak self] in
            self?.setupCollectionGameScene()
            print("aaaaa")
        }
    }

    func setupCollectionGameScene() {
            
           let skView = SKView(frame: self.view.bounds)
           skView.backgroundColor = UIColor.clear
           skView.isOpaque = false // 允许透明背景
           self.view.addSubview(skView)

           let scene = CollectionGameScene(size: skView.bounds.size)
           scene.scaleMode = .aspectFill
            scene.tags = viewModel.tags // 传递数据
           scene.viewController = self

           skView.presentScene(scene)
       }

}
