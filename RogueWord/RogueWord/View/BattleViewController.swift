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
        let label = UILabel()
        let userName = UserDefaults.standard.string(forKey: "userName")
        if let userNamedata = userName {
            label.text = "名字: \(userNamedata)"
        }
        label.textColor = UIColor(named: "waitingNameColor")
        return label
    }()
    
    var divideLine: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    
    var rankScoreLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "waitingLabel")
        return label
    }()
    
    var winRateScoreLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "waitingLabel")
        return label
    }()
    
    var accurencyScoreLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "waitingLabel")
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        fectchRank()
        setupUI()
        
        let gradientLayer = CAGradientLayer()
            
            // 設置漸層顏色 (從藍色到綠色)
            gradientLayer.colors = [
                UIColor(named: "waitingBackGround")?.cgColor,
                UIColor(named: "waitingBackGroundEnd")?.cgColor
            ]
            
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.7)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
            
            gradientLayer.frame = self.view.bounds
            
            self.view.layer.insertSublayer(gradientLayer, at: 0)
        
        let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()  // 設置為不透明背景
            appearance.backgroundColor = UIColor.black  // 背景顏色

            // 設置字體大小和粗細
            appearance.titleTextAttributes = [
                .font: UIFont.systemFont(ofSize: 24, weight: .bold),  // 自定義字體大小和粗細
                .foregroundColor: UIColor.white  // 設置字體顏色
            ]

            // 應用 appearance 到 Navigation Bar
            navigationController?.navigationBar.standardAppearance = appearance
        
    }
    
    func setupUI() {
        view.addSubview(cardView)
        cardView.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.centerY.equalTo(view).offset(-50)
            make.width.equalTo(view).offset(-32)
            make.height.equalTo(400)
        }

        // userImage 設置
        cardView.addSubview(userImage)
        userImage.snp.makeConstraints { make in
            make.top.equalTo(cardView).offset(16)
            make.centerX.equalTo(cardView)
            make.width.height.equalTo(60)
        }

        // userName 設置
        cardView.addSubview(userName)
        userName.snp.makeConstraints { make in
            make.top.equalTo(userImage.snp.bottom).offset(8)
            make.centerX.equalTo(cardView)
        }
        // 修改字體大小與粗細
        userName.font = UIFont.systemFont(ofSize: 20, weight: .bold)

        // divideLine 設置
        cardView.addSubview(divideLine)
        divideLine.snp.makeConstraints { make in
            make.top.equalTo(userName.snp.bottom).offset(8)
            make.left.equalTo(cardView).offset(16)
            make.right.equalTo(cardView).offset(-16)
            make.height.equalTo(1)
        }

        // Rank Card 設置
        let rankCardView = UIView()
        rankCardView.backgroundColor = UIColor(named: "waitingButtonBackGround")
        rankCardView.layer.cornerRadius = 10
        rankCardView.layer.masksToBounds = false
        cardView.addSubview(rankCardView)

        rankCardView.snp.makeConstraints { make in
            make.top.equalTo(divideLine.snp.bottom).offset(24)
            make.left.equalTo(cardView).offset(16)
            make.right.equalTo(cardView).offset(-16)
            make.height.equalTo(60)
        }

        // Rank Label 設置
        let rankLabel = UILabel()
        rankLabel.textColor = UIColor(named: "waitingLabel")
        rankLabel.text = "排名分數"
        rankLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        rankCardView.addSubview(rankLabel)

        rankLabel.snp.makeConstraints { make in
            make.centerY.equalTo(rankCardView)
            make.left.equalTo(rankCardView).offset(16)
        }

        // Rank Score 設置
        rankCardView.addSubview(rankScoreLabel)
        rankScoreLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        rankScoreLabel.snp.makeConstraints { make in
            make.centerY.equalTo(rankCardView)
            make.right.equalTo(rankCardView).offset(-16)
        }

        // WinRate Card 設置
        let winRateCardView = UIView()
        winRateCardView.backgroundColor = UIColor(named: "waitingButtonBackGround")
        winRateCardView.layer.cornerRadius = 10
        winRateCardView.layer.masksToBounds = false
        cardView.addSubview(winRateCardView)

        winRateCardView.snp.makeConstraints { make in
            make.top.equalTo(rankCardView.snp.bottom).offset(24)
            make.left.equalTo(cardView).offset(16)
            make.right.equalTo(cardView).offset(-16)
            make.height.equalTo(60)
        }

        // WinRate Label 設置
        let winRateLabel = UILabel()
        winRateLabel.textColor = UIColor(named: "waitingLabel")
        winRateLabel.text = "勝率"
        winRateLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        winRateCardView.addSubview(winRateLabel)

        winRateLabel.snp.makeConstraints { make in
            make.centerY.equalTo(winRateCardView)
            make.left.equalTo(winRateCardView).offset(16)
        }

        // WinRate Score 設置
        winRateCardView.addSubview(winRateScoreLabel)
        winRateScoreLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        winRateScoreLabel.snp.makeConstraints { make in
            make.centerY.equalTo(winRateCardView)
            make.right.equalTo(winRateCardView).offset(-16)
        }

        // Accurency Card 設置
        let accurencyCardView = UIView()
        accurencyCardView.backgroundColor = UIColor(named: "waitingButtonBackGround")
        accurencyCardView.layer.cornerRadius = 10
        accurencyCardView.layer.masksToBounds = false
        cardView.addSubview(accurencyCardView)

        accurencyCardView.snp.makeConstraints { make in
            make.top.equalTo(winRateCardView.snp.bottom).offset(24)
            make.left.equalTo(cardView).offset(16)
            make.right.equalTo(cardView).offset(-16)
            make.height.equalTo(60)
        }

        // Accurency Label 設置
        let accurencyLabel = UILabel()
        accurencyLabel.textColor = UIColor(named: "waitingLabel")
        accurencyLabel.text = "正確率"
        accurencyLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        accurencyCardView.addSubview(accurencyLabel)

        accurencyLabel.snp.makeConstraints { make in
            make.centerY.equalTo(accurencyCardView)
            make.left.equalTo(accurencyCardView).offset(16)
        }

        // Accurency Score 設置
        accurencyCardView.addSubview(accurencyScoreLabel)
        accurencyScoreLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        accurencyScoreLabel.snp.makeConstraints { make in
            make.centerY.equalTo(accurencyCardView)
            make.right.equalTo(accurencyCardView).offset(-16)
        }

        let buttonView = UIView()
        
        view.addSubview(buttonView)
        buttonView.backgroundColor = UIColor(named: "waitingActionButtonColor")
        buttonView.layer.cornerRadius = 10
        buttonView.layer.masksToBounds = false
        buttonView.snp.makeConstraints { make in
            make.top.equalTo(cardView.snp.bottom).offset(16)
            make.left.equalTo(cardView).offset(16)
            make.right.equalTo(cardView).offset(-16)
            make.height.equalTo(60)
        }
        
        actionButton = UIButton(type: .system)
        actionButton.setTitle("開始對戰", for: .normal)
        actionButton.tintColor = .white
        actionButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        actionButton.backgroundColor = .clear
        actionButton.addTarget(self, action: #selector(handleRoomAction), for: .touchUpInside)
        buttonView.addSubview(actionButton)
        actionButton.snp.makeConstraints { make in
            make.centerX.centerY.equalTo(buttonView)
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
            rankScoreLabel.text = String(format: "%.1f", rank.rankScore)
            winRateScoreLabel.text = String(format: "%.1f", winRate)
            accurencyScoreLabel.text = String(format: "%.1f", accurency)
        } else {
            accurencyScoreLabel.text = "準確率無法取得"
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
        guard let userName = UserDefaults.standard.string(forKey: "userName") else {return}
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
        
        ref.child("Rooms").child(roomId).setValue(roomData) { error, _ in
            if let error = error {
                print("建立房間失敗: \(error.localizedDescription)")
            } else {
                print("房間建立成功，房間ID: \(roomId)")
                
                let battlePage = BattlePlay1ViewController()
                battlePage.roomId = roomId
                battlePage.player1Id = userName
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
        guard let userName = UserDefaults.standard.string(forKey: "userName") else {return}
        updatedRoomData["Player2Name"] = userName
        
        ref.child("Rooms").child(roomId).updateChildValues(updatedRoomData) { error, _ in
            if let error = error {
                print("加入房間失敗: \(error.localizedDescription)")
            } else {
                print("成功加入房間: \(roomId)")
                
                let battlePage = BattlePlay1ViewController()
                battlePage.roomId = roomId
                battlePage.player2Id = userName
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
