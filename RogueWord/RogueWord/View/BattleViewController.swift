//
//  BattleViewController.swift
//  RogueWord
//
//  Created by shachar on 2024/9/16.
//
import UIKit
import FirebaseDatabase
import SnapKit

class BattleViewController: UIViewController {
    
    var ref: DatabaseReference!
    
    var actionButton: UIButton!
    var rank: Rank?
    
    var cardView: UIView = {
       let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = false
        return view
    }()
    
    var userImage: UIImageView = {
        let imageURL = UserDefaults.standard.string(forKey: "image")
        let image = UIImageView()
        image.image = UIImage(systemName: "person")
        return image
    }()
    
    var userName: UILabel = {
        let userName = UserDefaults.standard.string(forKey: "UserName")
        let label = UILabel()
        label.text = "名字: \(userName)"
        label.textColor = .black
        return label
    }()
    
    var divideLine: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    var rankScoreLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        return label
    }()
    
    var winRateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        return label
    }()
    
    var accurencyLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        fectchRank()
        setupUI()
    }
    
    func setupUI() {
        view.addSubview(cardView)
        cardView.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.centerY.equalTo(view)
            make.width.equalTo(view).offset(-32)
            make.height.equalTo(300)
        }
        cardView.addSubview(userImage)
        userImage.snp.makeConstraints { make in
            make.top.equalTo(cardView).offset(16)
            make.centerX.equalTo(cardView)
            make.width.height.equalTo(60)
        }
        
        cardView.addSubview(userName)
        userName.snp.makeConstraints { make in
            make.top.equalTo(userImage.snp.bottom).offset(8)
            make.centerX.equalTo(cardView)
            make.width.equalTo(60)
        }
        cardView.addSubview(divideLine)
        divideLine.snp.makeConstraints { make in
            make.top.equalTo(userName.snp.bottom).offset(8)
            make.left.equalTo(cardView).offset(16)
            make.right.equalTo(cardView).offset(-16)
            make.height.equalTo(3)
        }
        
        cardView.addSubview(rankScoreLabel)
        rankScoreLabel.snp.makeConstraints { make in
            make.top.equalTo(divideLine.snp.bottom).offset(16)
            make.left.equalTo(cardView).offset(16)
            make.right.equalTo(cardView).offset(-16)
            make.height.equalTo(40)
        }
        
        cardView.addSubview(winRateLabel)
        winRateLabel.snp.makeConstraints { make in
            make.top.equalTo(rankScoreLabel.snp.bottom).offset(16)
            make.left.equalTo(cardView).offset(16)
            make.right.equalTo(cardView).offset(-16)
            make.height.equalTo(40)
        }
        cardView.addSubview(accurencyLabel)
        accurencyLabel.snp.makeConstraints { make in
            make.top.equalTo(winRateLabel.snp.bottom).offset(16)
            make.left.equalTo(cardView).offset(16)
            make.right.equalTo(cardView).offset(-16)
            make.height.equalTo(40)
        }
        
        actionButton = UIButton(type: .system)
        actionButton.setTitle("進入遊戲", for: .normal)
        actionButton.addTarget(self, action: #selector(handleRoomAction), for: .touchUpInside)
        view.addSubview(actionButton)
        actionButton.snp.makeConstraints { make in
            make.top.equalTo(accurencyLabel.snp.bottom).offset(16)
            make.left.equalTo(cardView).offset(16)
            make.right.equalTo(cardView).offset(-16)
            make.height.equalTo(40)
        }
    }
    
    func fectchRank() {
        guard let userID = UserDefaults.standard.string(forKey: "userID") else { return }
                let query = FirestoreEndpoint.fetchPersonData.ref.document(userID)

        FirestoreService.shared.getDocument(query) { (personData: UserData?) in
            if let personData = personData {
                self.rank = personData.rank
                print("DEBUG here \(personData.rank)")
                self.updateAccuracyLabel()
            } else {
                print("DEBUG: Failed to fetch or decode UserData.")
            }
        }
    }
    
    func updateAccuracyLabel() {
        if let rank = self.rank {
            let accurency = (rank.correct / (rank.playTimes * 10)) * 100
            let winRate = (rank.winRate / rank.playTimes) * 100
            rankScoreLabel.text = "天梯分數 \(rank.rankScore)"
            winRateLabel.text = "對戰勝率 \(winRate) % "
            accurencyLabel.text = "準確率 \(accurency) % "
        } else {
            accurencyLabel.text = "準確率無法取得"
        }
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
                battlePage.rank = self.rank
                battlePage.modalPresentationStyle = .fullScreen
                battlePage.datadismiss = { [weak self] rank in
                    guard let self = self else { return }
                    if let rank = rank {
                        self.rank = rank
                        let newRank = [
                            "rank.correct" : rank.correct,
                            "rank.winRate" : rank.winRate,
                            "rank.playTimes" : rank.playTimes,
                            "rank.rankScore" : rank.rankScore
                        ]
                        guard let userID = UserDefaults.standard.string(forKey: "userID") else {return}
                        let query = FirestoreEndpoint.fetchPersonData.ref.document(userID)
                        FirestoreService.shared.updateData(at: query, with: newRank) { error in
                            if let error = error {
                                print("DEBUG: Failed to update LevelNumber -", error.localizedDescription)
                            } else {
                                print("DEBUG: Successfully updated LevelNumber to \(newRank)")
                            }
                        }
                    }
                    
                }
                self.present(battlePage, animated: true)
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
                battlePage.rank = self.rank
                battlePage.modalPresentationStyle = .fullScreen
                battlePage.datadismiss = { [weak self] rank in
                    guard let self = self else { return }
                    if let rank = rank {
                        self.rank = rank
                        let newRank = [
                            "rank.correct" : rank.correct,
                            "rank.winRate" : rank.winRate,
                            "rank.playTimes" : rank.playTimes,
                            "rank.rankScore" : rank.rankScore
                        ]
                        guard let userID = UserDefaults.standard.string(forKey: "userID") else {return}
                        let query = FirestoreEndpoint.fetchPersonData.ref.document(userID)
                        FirestoreService.shared.updateData(at: query, with: newRank) { error in
                            if let error = error {
                                print("DEBUG: Failed to update LevelNumber -", error.localizedDescription)
                            } else {
                                print("DEBUG: Successfully updated LevelNumber to \(newRank)")
                            }
                        }
                    }
                    
                }
                
                self.present(battlePage, animated: true)

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
