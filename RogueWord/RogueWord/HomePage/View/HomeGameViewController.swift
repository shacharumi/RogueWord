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
            
           let skView = SKView(frame: self.view.bounds)
           skView.backgroundColor = UIColor.clear
           skView.isOpaque = false
           self.view.addSubview(skView)
           let scene = HomeGameScene(size: skView.bounds.size)
           scene.scaleMode = .aspectFill
           scene.personData = self.personData
           scene.viewController = self
           skView.presentScene(scene)
       }

}
