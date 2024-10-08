//
//  ListeningTestCell.swift
//  RogueWord
//
//  Created by shachar on 2024/9/20.
//
import SpriteKit
import FirebaseFirestore

class ListeningTestCell: UIViewController {

    private let viewModel = HomeModel()
    var rank: Rank?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backGroundView = UIImageView()
        backGroundView.image = UIImage(named: "battle")
        view.addSubview(backGroundView)
        backGroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        fectchRank()
    }

    func setupCollectionGameScene() {
            
           let skView = SKView(frame: self.view.bounds)
           skView.backgroundColor = UIColor.clear
           skView.isOpaque = false 
           self.view.addSubview(skView)

           let scene = BattleGameScene(size: skView.bounds.size)
           scene.scaleMode = .aspectFill
           scene.rank = self.rank
           scene.viewController = self

           skView.presentScene(scene)
       }
    
    func fectchRank() {
        guard let userID = UserDefaults.standard.string(forKey: "userID") else { return }
                let query = FirestoreEndpoint.fetchPersonData.ref.document(userID)

        FirestoreService.shared.getDocument(query) { (personData: UserData?) in
            if let personData = personData {
                self.rank = personData.rank
                self.setupCollectionGameScene()

            } else {
                print("DEBUG: Failed to fetch or decode UserData.")
            }
        }
    }
}
