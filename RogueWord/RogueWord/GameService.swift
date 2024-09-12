//import FirebaseDatabase
//
//class GameService {
//    private let dbRef = Database.database().reference()  // 初始化 Realtime Database 引用
//
//    // 創建新遊戲房間
//    func createGame(player1Id: String, roomId: String, completion: @escaping (String?) -> Void) {
//        let gameData: [String: Any] = [
//            "player1Id": player1,
//            "player2Id": "",  // 初始 player2 為空
//            "currentQuestionIndex": 0,
//            "player1Score": 0,
//            "player2Score": 0,
//            "isGameOver": false
//        ]
//        
//        // 使用傳入的 roomId 建立新的遊戲房間
//        let newGameRef = dbRef.child("games").child(roomId)
//        newGameRef.setValue(gameData) { error, _ in
//            if let error = error {
//                print("Error creating game: \(error.localizedDescription)")
//                completion(nil)
//            } else {
//                print("Game created with ID: \(newGameRef.key!)")
//                completion(newGameRef.key)
//            }
//        }
//    }
//    
//    // 監聽遊戲房間列表
//    func observeGames(completion: @escaping ([String]) -> Void) {
//        dbRef.child("games").observe(.value) { snapshot in
//            var rooms: [String] = []
//            for child in snapshot.children {
//                if let snap = child as? DataSnapshot {
//                    rooms.append(snap.key)  // 房間ID為snapshot的key
//                }
//            }
//            completion(rooms)
//        }
//    }
//    
//    
//
//
//    // 加入現有遊戲房間並設定 player2
//    func joinGame(gameId: String, player2Id: String, completion: @escaping (Bool) -> Void) {
//        let gameRef = dbRef.child("games").child(gameId)
//        
//        gameRef.observeSingleEvent(of: .value) { snapshot in
//            guard let gameData = snapshot.value as? [String: Any] else {
//                print("Game document does not exist")
//                completion(false)
//                return
//            }
//
//            // 確認 player2 是否已設置
//            if let player2 = gameData["player2Id"] as? String, player2.isEmpty {
//                // 更新 player2
//                gameRef.updateChildValues(["player2Id": player2Id]) { error, _ in
//                    if let error = error {
//                        print("Error joining game: \(error.localizedDescription)")
//                        completion(false)
//                    } else {
//                        print("Player 2 successfully joined the game")
//                        completion(true)
//                    }
//                }
//            } else {
//                print("Player 2 is already set or invalid game state")
//                completion(false)
//            }
//        }
//    }
//}
