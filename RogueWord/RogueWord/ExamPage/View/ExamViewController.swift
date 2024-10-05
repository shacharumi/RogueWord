import UIKit
import SpriteKit
import FirebaseFirestore

class ExamViewController: UIViewController {

    var wordData: [Accurency] = []

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
        fetchAccurencyRecords()
    }

    func setupGameScene() {
            
           let skView = SKView(frame: self.view.bounds)
           skView.backgroundColor = UIColor.clear
           skView.isOpaque = false // 允许透明背景
           self.view.addSubview(skView)

           let scene = GameScene(size: skView.bounds.size)
           scene.scaleMode = .aspectFill
           scene.wordData = self.wordData // 传递数据
           scene.viewController = self    

           skView.presentScene(scene)
       }

    // 获取数据的方法
    func fetchAccurencyRecords() {
        let query = FirestoreEndpoint.fetchAccurencyRecords.ref
        FirestoreService.shared.getDocuments(query) { [weak self] (accurencyRecords: [Accurency]) in
            guard let self = self else { return }
            let sortedAccurencyRecords = accurencyRecords.sorted(by: { $0.title < $1.title })
            self.wordData = sortedAccurencyRecords
            print(self.wordData)

            DispatchQueue.main.async {
                // 在获取到数据后，设置 GameScene
                self.setupGameScene()
            }
        }
    }
}
