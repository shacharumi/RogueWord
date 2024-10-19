//
//  BattleViewModel.swift
//  RogueWord
//
//  Created by shachar on 2024/10/16.
//



import Foundation
import FirebaseDatabase

class BattleViewModel {
    
    var ref: DatabaseReference!
    var rank: Rank?
    var userID: String?
    var userName: String?
    
    // 闭包，用于数据绑定
    var onRankFetched: ((Rank?) -> Void)?
    var onError: ((Error) -> Void)?
    
    init() {
        ref = Database.database().reference()
        self.userID = UserDefaults.standard.string(forKey: "userID")
        self.userName = UserDefaults.standard.string(forKey: "userName")
    }
    
    // 获取排名数据
    func fetchRank() {
        guard let userID = self.userID else { return }
        let query = FirestoreEndpoint.fetchPersonData.ref.document(userID)
        
        FirestoreService.shared.getDocument(query) { [weak self] (personData: UserData?) in
            if let personData = personData {
                self?.rank = personData.rank
                self?.onRankFetched?(self?.rank)
            } else {
                // 处理错误
                let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch or decode UserData."])
                self?.onError?(error)
            }
        }
    }
    
    // 处理房间逻辑
    func handleRoomAction(completion: @escaping (BattlePlay1ViewController) -> Void) {
        ref.child("Rooms").observeSingleEvent(of: .value) { snapshot in
            if let roomsData = snapshot.value as? [String: [String: Any]] {
                let availableRooms = roomsData.filter { room in
                    if let player2Name = room.value["Player2Name"] as? String {
                        return player2Name.isEmpty
                    }
                    return false
                }
                
                if let randomRoom = availableRooms.randomElement() {
                    self.joinRoom(roomId: randomRoom.key, roomData: randomRoom.value, completion: completion)
                } else {
                    self.createRoom(completion: completion)
                }
            } else {
                self.createRoom(completion: completion)
            }
        }
    }
    
    // 创建新房间
    func createRoom(completion: @escaping (BattlePlay1ViewController) -> Void) {
        let roomId = UUID().uuidString
        guard let userName = self.userName else { return }
        let roomData: [String: Any] = [
            "Player1Name": userName,
            "Player2Name": "",
            "Player1Score": 0,
            "Player2Score": 0,
            "CurrentQuestionIndex": 0,
            "PlayCounting": 10,
            "Player1Select": "",
            "Player2Select": "",
            "RoomIsStart": false,
            "QuestionData": [
                "Question": "",
                "Options": [
                    "Option0": "",
                    "Option1": "",
                    "Option2": "",
                    "Option3": ""
                ],
                "CorrectAnswer": ""
            ]
        ]
        
        ref.child("Rooms").child(roomId).setValue(roomData) { [weak self] error, _ in
            if let error = error {
                self?.onError?(error)
            } else {
                let battlePage = BattlePlay1ViewController()
                battlePage.roomId = roomId
                //battlePage.player1Id = userName
                battlePage.whichPlayer = 1
                battlePage.rank = self?.rank
                battlePage.modalPresentationStyle = .fullScreen
                battlePage.datadismiss = { [weak self] rank in
                    self?.rank = rank
                    self?.updateRankInFirestore(rank)
                    // 通知 ViewController 更新 UI
                    self?.onRankFetched?(rank)
                }
                completion(battlePage)
            }
        }
    }
    
    // 加入现有房间
    func joinRoom(roomId: String, roomData: [String: Any], completion: @escaping (BattlePlay1ViewController) -> Void) {
        var updatedRoomData = roomData
        guard let userName = self.userName else { return }
        updatedRoomData["Player2Name"] = userName
        
        ref.child("Rooms").child(roomId).updateChildValues(updatedRoomData) { [weak self] error, _ in
            if let error = error {
                self?.onError?(error)
            } else {
                let battlePage = BattlePlay1ViewController()
                battlePage.roomId = roomId
                //battlePage.player2Id = userName
                battlePage.whichPlayer = 2
                battlePage.rank = self?.rank
                battlePage.modalPresentationStyle = .fullScreen
                battlePage.datadismiss = { [weak self] rank in
                    self?.rank = rank
                    self?.updateRankInFirestore(rank)
                    // 通知 ViewController 更新 UI
                    self?.onRankFetched?(rank)
                }
                completion(battlePage)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self?.ref.child("Rooms").child(roomId).updateChildValues(["RoomIsStart": true]) { error, _ in
                        if error == nil {
                            //battlePage.startGameForPlayer2()
                            battlePage.animationView.play()
                        } else {
                            let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to update RoomIsStart"])
                            self?.onError?(error)
                        }
                    }
                }
            }
        }
    }
    
    // 更新排名数据到 Firestore
    func updateRankInFirestore(_ rank: Rank?) {
        guard let rank = rank else { return }
        let newRank = [
            "rank.correct": rank.correct,
            "rank.winRate": rank.winRate,
            "rank.playTimes": rank.playTimes,
            "rank.rankScore": rank.rankScore
        ]
        guard let userID = self.userID else { return }
        let query = FirestoreEndpoint.fetchPersonData.ref.document(userID)
        FirestoreService.shared.updateData(at: query, with: newRank) { [weak self] error in
            if let error = error {
                self?.onError?(error)
            } else {
                self?.onRankFetched?(rank)
            }
        }
    }
}
