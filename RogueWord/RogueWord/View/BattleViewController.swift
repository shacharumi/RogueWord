//
//  BattleViewController.swift
//  RogueWord
//
//  Created by shachar on 2024/9/16.
//
import UIKit
import FirebaseDatabase

class BattleViewController: UIViewController {
    
    var ref: DatabaseReference!
    
    var actionButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        setupUI()
    }
    
    func setupUI() {
        actionButton = UIButton(type: .system)
        actionButton.setTitle("進入遊戲", for: .normal)
        actionButton.addTarget(self, action: #selector(handleRoomAction), for: .touchUpInside)
        actionButton.frame = CGRect(x: 100, y: 200, width: 200, height: 50)
        view.addSubview(actionButton)
    }
    
    @objc func handleRoomAction() {
        ref.child("rooms").observeSingleEvent(of: .value) { snapshot in
            if let roomsData = snapshot.value as? [String: [String: Any]] {
                let availableRooms = roomsData.filter { room in
                    if let player2Name = room.value["Player2 Name"] as? String {
                        return player2Name.isEmpty
                    }
                    return false
                }
                
                if let randomRoom = availableRooms.randomElement() {
                    self.joinRoom(roomId: randomRoom.key, roomData: randomRoom.value)
                } else {
                    self.createRoom()
                }
            } else {
                // 如果沒有任何房間，則建立新房間
                self.createRoom()
            }
        }
    }
    
    func createRoom() {
        let roomId = UUID().uuidString // 建立唯一的房間ID
           let roomData: [String: Any] = [
               "Player1 Name": "Player1",
               "Player2 Name": "",
               "Player1 Score": 0,
               "Player2 Score": 0,
               "CurrentQuestionIndex": 0,
               "PlayCounting": 10,
               "Player1Select": 0,
               "Player2Select": 0,
               "Player1Prepare": false,
               "Player2Prepare": false,
               "QuestionData": [ // 將題目和選項存儲在 QuestionData 中
                   "Question": "", // 當前題目
                   "Options": [
                       "Option0": "", // 選項0
                       "Option1": "", // 選項1
                       "Option2": "", // 選項2
                       "Option3": ""  // 選項3
                   ],
                   "CorrectAnswer": "" // 正確答案
               ]
           ]
        
        ref.child("rooms").child(roomId).setValue(roomData) { error, _ in
            if let error = error {
                print("建立房間失敗: \(error.localizedDescription)")
            } else {
                print("房間建立成功，房間ID: \(roomId)")
                
                let battlePage = BattlePlay1ViewController()
                battlePage.roomId = roomId
                battlePage.player1Id = "Player1"
                battlePage.whichPlayer = 1
                self.navigationController?.pushViewController(battlePage, animated: true)
            }
        }
    }
    
    func joinRoom(roomId: String, roomData: [String: Any]) {
        var updatedRoomData = roomData
        updatedRoomData["Player2 Name"] = "Player2"
        
        ref.child("rooms").child(roomId).updateChildValues(updatedRoomData) { error, _ in
            if let error = error {
                print("加入房間失敗: \(error.localizedDescription)")
            } else {
                print("成功加入房間: \(roomId)")
                
                let battlePage = BattlePlay1ViewController()
                battlePage.roomId = roomId
                battlePage.player2Id = "Player2"
                battlePage.whichPlayer = 2
                self.navigationController?.pushViewController(battlePage, animated: true)
            }
        }
    }
}
