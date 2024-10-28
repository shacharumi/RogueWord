//
//  ExamViewController.swift
//  RogueWord
//
//  Created by shachar on 2024/9/15.
//
import UIKit
import SpriteKit
import FirebaseFirestore

class ExamViewController: UIViewController {

    var wordData: [Accurency] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .yellow

        let backGroundView = UIImageView()
        backGroundView.image = UIImage(named: "exam")
        view.addSubview(backGroundView)
        backGroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        fetchAccurencyRecords()
    }

    func setupGameScene() {

        let skView = SKView(frame: self.view.bounds)
        skView.backgroundColor = UIColor.clear
        skView.isOpaque = false
        self.view.addSubview(skView)

        let scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        scene.wordData = self.wordData
        scene.viewController = self

        skView.presentScene(scene)
    }

    func fetchAccurencyRecords() {
        let query = FirestoreEndpoint.fetchAccurencyRecords.ref
        FirestoreService.shared.getDocuments(query) { [weak self] (accurencyRecords: [Accurency]) in
            guard let self = self else { return }
            let sortedAccurencyRecords = accurencyRecords.sorted(by: { $0.title < $1.title })
            self.wordData = sortedAccurencyRecords
            print(self.wordData)

            DispatchQueue.main.async {
                self.setupGameScene()
            }
        }
    }
}
