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
        ref.child("Rooms").observeSingleEvent(of: .value) { snapshot in
            if let roomsData = snapshot.value as? [String: [String: Any]] {
                let availableRooms = roomsData.filter { room in
                    if let player2Name = room.value["Player2Name"] as? String {
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
                self.createRoom()
            }
        }
    }
    
    func createRoom() {
        let roomId = UUID().uuidString
           let roomData: [String: Any] = [
               "Player1Name": "Player1",
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
        
        ref.child("Rooms").child(roomId).setValue(roomData) { error, _ in
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
        updatedRoomData["Player2Name"] = "Player2"
        
        ref.child("Rooms").child(roomId).updateChildValues(updatedRoomData) { error, _ in
            if let error = error {
                print("加入房間失敗: \(error.localizedDescription)")
            } else {
                print("成功加入房間: \(roomId)")
                
                let battlePage = BattlePlay1ViewController()
                battlePage.roomId = roomId
                battlePage.player2Id = "Player2"
                battlePage.whichPlayer = 2
                self.navigationController?.pushViewController(battlePage, animated: true)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.ref.child("Rooms").child(roomId).updateChildValues(["RoomIsStart": true]) { error, _ in
                        if error == nil {
                            battlePage.startGameForPlayer2()
                        } else {
                            print("無法更新 RoomIsStart: \(error?.localizedDescription ?? "未知錯誤")")
                        }
                    }
                }
            }
        }
    }

}
