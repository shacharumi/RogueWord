////
////  GamingViewController.swift
////  RogueWord
////
////  Created by shachar on 2024/9/12.
////
//
//import UIKit
//import FirebaseDatabase
//
//class GamingViewController: UIViewController {
//    @IBOutlet weak var player1Label: UILabel!
//    @IBOutlet weak var player2Label: UILabel!
//    @IBOutlet weak var startButton: UIButton!
//
//    var gameId: String?  // 房間ID
//    var player1Id: String?  // Player1 ID
//    var player2Id: String?  // Player2 ID (初始為nil)
//    
//    let gameService = GameService()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        // 初始設置
//        player1Label.text = player1Id
//        player2Label.text = "Waiting for Player 2..."  // Player2 初始等待
//        startButton.isEnabled = false  // 開始按鈕初始為不可點擊
//        
//        // 監聽遊戲狀態，更新 Player2 的狀態
//        if let gameId = gameId {
//                    gameService.observeGame(gameId: gameId) { [weak self] gameData in
//                        let player2Id = gameData["player2Id"] as? String ?? ""
//                        self?.player2Label.text = player2Id.isEmpty ? "Waiting for Player 2..." : player2Id
//                        self?.player2Id = player2Id
//                        
//                        // 當 Player1 和 Player2 都不為空時，啟用開始按鈕
//                        if let player1 = self?.player1Id, !player1.isEmpty, !player2Id.isEmpty {
//                            self?.startButton.isEnabled = true
//                        }
//                    }
//                }
//    }
//
//    // 點擊開始按鈕
//    @IBAction func startGameTapped(_ sender: UIButton) {
//        if startButton.isEnabled {
//            print("Game Started!")
//            // 可以加入其他開始遊戲的邏輯
//        }
//    }
//}
//
