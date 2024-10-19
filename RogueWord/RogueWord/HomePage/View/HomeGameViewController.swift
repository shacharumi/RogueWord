//
//  HomeGameViewController.swift
//  RogueWord
//
//  Created by shachar on 2024/10/6.
//

import UIKit
import SpriteKit
import FirebaseFirestore

class HomeGameViewController: UIViewController {

    private let viewModel = HomeModel()
    var personData: UserData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .yellow
        
        let backGroundView = UIImageView()
        backGroundView.image = UIImage(named: "Home")
        view.addSubview(backGroundView)
        backGroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        viewModel.fetchLevelNumber { [weak self] userData in
            guard let self = self else { return }
            if let userData = userData {
                self.personData = userData
                setupCollectionGameScene()
                print("Successfully fetched UserData: \(userData)")
            } else {
                print("Failed to fetch LevelNumber.")
            }
        }
    }

    func setupCollectionGameScene() {
        let skView = SKView()
        skView.backgroundColor = UIColor.clear
        skView.isOpaque = false
        self.view.addSubview(skView)
        skView.snp.makeConstraints { make in
            make.left.right.top.equalTo(view)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        let sceneSize = CGSize(width: view.bounds.width, height: view.bounds.height)
        let scene = HomeGameScene(size: sceneSize)
        scene.scaleMode = .aspectFill
        scene.personData = self.personData
        scene.viewController = self
        skView.presentScene(scene)
    }


}
