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
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.layer.cornerRadius = 40
        image.layer.borderWidth = 1
        image.layer.borderColor = UIColor.systemBlue.cgColor
        image.isUserInteractionEnabled = true
        if let imageData = UserDefaults.standard.data(forKey: "imageData") {
            image.image = UIImage(data: imageData)
        } else {
            image.image = UIImage(systemName: "person")
        }
        return image
    }()
    
    var userName: UILabel = {
        let label = UILabel()
        let userName = UserDefaults.standard.string(forKey: "userName")
        if let userNamedata = userName {
            label.text = "\(userNamedata)"
        }
        label.textColor = UIColor(named: "waitingLabel")
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
    
    var backGroundView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "battleBackGround")
        return view
    }()
    
    // 添加自定义导航栏视图
    var customNavBar: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    // 添加返回按钮
    var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = UIColor.black
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        fectchRank()
        setupUI()
    }
    
    func setupUI() {
        // 添加背景图片
        view.addSubview(backGroundView)
        backGroundView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        
        // 添加自定义导航栏视图
        view.addSubview(customNavBar)
        customNavBar.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top)
            make.left.right.equalTo(view)
            make.height.equalTo(88) // 导航栏高度，包括状态栏
        }
        
        // 添加返回按钮到导航栏
        customNavBar.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.left.equalTo(customNavBar.snp.left).offset(16)
            make.bottom.equalTo(customNavBar.snp.bottom).offset(-8)
            make.width.height.equalTo(44)
        }
        
        // 添加卡片视图
        view.addSubview(cardView)
        cardView.alpha = 0.8
        cardView.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(customNavBar.snp.bottom).offset(16)
            make.width.equalTo(view).offset(-56)
            make.height.equalTo(450)
        }
        
        // 以下是原有的视图设置代码
        // userImage 设置
        cardView.addSubview(userImage)
        userImage.snp.makeConstraints { make in
            make.top.equalTo(cardView).offset(16)
            make.centerX.equalTo(cardView)
            make.width.height.equalTo(80)
        }
        
        // userName 设置
        cardView.addSubview(userName)
        userName.snp.makeConstraints { make in
            make.top.equalTo(userImage.snp.bottom).offset(8)
            make.centerX.equalTo(cardView)
        }
        // 修改字体大小与粗细
        userName.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        
        // divideLine 设置
        cardView.addSubview(divideLine)
        divideLine.snp.makeConstraints { make in
            make.top.equalTo(userName.snp.bottom).offset(8)
            make.left.equalTo(cardView).offset(16)
            make.right.equalTo(cardView).offset(-16)
            make.height.equalTo(1)
        }
        
        // Rank Card 设置
        let rankCardView = UIView()
        rankCardView.backgroundColor = UIColor(named: "waitingButtonBackGround")
        rankCardView.layer.cornerRadius = 10
        rankCardView.layer.masksToBounds = false
        cardView.addSubview(rankCardView)
        
        rankCardView.snp.makeConstraints { make in
            make.top.equalTo(divideLine.snp.bottom).offset(36)
            make.left.equalTo(cardView).offset(16)
            make.right.equalTo(cardView).offset(-16)
            make.height.equalTo(60)
        }
        
        // Rank Label 设置
        let rankLabel = UILabel()
        rankLabel.textColor = UIColor(named: "waitingLabel")
        rankLabel.text = "排名分数"
        rankLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        rankCardView.addSubview(rankLabel)
        
        rankLabel.snp.makeConstraints { make in
            make.centerY.equalTo(rankCardView)
            make.left.equalTo(rankCardView).offset(16)
        }
        
        // Rank Score 设置
        rankCardView.addSubview(rankScoreLabel)
        rankScoreLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        rankScoreLabel.snp.makeConstraints { make in
            make.centerY.equalTo(rankCardView)
            make.right.equalTo(rankCardView).offset(-16)
        }
        
        // WinRate Card 设置
        let winRateCardView = UIView()
        winRateCardView.backgroundColor = UIColor(named: "waitingButtonBackGround")
        winRateCardView.layer.cornerRadius = 10
        winRateCardView.layer.masksToBounds = false
        cardView.addSubview(winRateCardView)
        
        winRateCardView.snp.makeConstraints { make in
            make.top.equalTo(rankCardView.snp.bottom).offset(36)
            make.left.equalTo(cardView).offset(16)
            make.right.equalTo(cardView).offset(-16)
            make.height.equalTo(60)
        }
        
        // WinRate Label 设置
        let winRateLabel = UILabel()
        winRateLabel.textColor = UIColor(named: "waitingLabel")
        winRateLabel.text = "胜率"
        winRateLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        winRateCardView.addSubview(winRateLabel)
        
        winRateLabel.snp.makeConstraints { make in
            make.centerY.equalTo(winRateCardView)
            make.left.equalTo(winRateCardView).offset(16)
        }
        
        // WinRate Score 设置
        winRateCardView.addSubview(winRateScoreLabel)
        winRateScoreLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        winRateScoreLabel.snp.makeConstraints { make in
            make.centerY.equalTo(winRateCardView)
            make.right.equalTo(winRateCardView).offset(-16)
        }
        
        // Accurency Card 设置
        let accurencyCardView = UIView()
        accurencyCardView.backgroundColor = UIColor(named: "waitingButtonBackGround")
        accurencyCardView.layer.cornerRadius = 10
        accurencyCardView.layer.masksToBounds = false
        cardView.addSubview(accurencyCardView)
        
        accurencyCardView.snp.makeConstraints { make in
            make.top.equalTo(winRateCardView.snp.bottom).offset(36)
            make.left.equalTo(cardView).offset(16)
            make.right.equalTo(cardView).offset(-16)
            make.height.equalTo(60)
        }
        
        // Accurency Label 设置
        let accurencyLabel = UILabel()
        accurencyLabel.textColor = UIColor(named: "waitingLabel")
        accurencyLabel.text = "正确率"
        accurencyLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        accurencyCardView.addSubview(accurencyLabel)
        
        accurencyLabel.snp.makeConstraints { make in
            make.centerY.equalTo(accurencyCardView)
            make.left.equalTo(accurencyCardView).offset(16)
        }
        
        // Accurency Score 设置
        accurencyCardView.addSubview(accurencyScoreLabel)
        accurencyScoreLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        accurencyScoreLabel.snp.makeConstraints { make in
            make.centerY.equalTo(accurencyCardView)
            make.right.equalTo(accurencyCardView).offset(-16)
        }
        
        let buttonView = UIView()
        view.addSubview(buttonView)
        buttonView.backgroundColor = UIColor(named: "viewBackGround")
        buttonView.layer.cornerRadius = 10
        buttonView.alpha = 0.9
        buttonView.layer.masksToBounds = false
        buttonView.snp.makeConstraints { make in
            make.top.equalTo(cardView.snp.bottom).offset(32)
            make.left.equalTo(cardView).offset(24)
            make.right.equalTo(cardView).offset(-24)
            make.height.equalTo(60)
        }
        
        actionButton = UIButton(type: .system)
        actionButton.setTitle("开始对战", for: .normal)
        actionButton.tintColor = UIColor(named: "waitingLabel")
        actionButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        actionButton.backgroundColor = .clear
        actionButton.addTarget(self, action: #selector(handleRoomAction), for: .touchUpInside)
        buttonView.addSubview(actionButton)
        actionButton.snp.makeConstraints { make in
            make.centerX.centerY.equalTo(buttonView)
        }
    }
    
    @objc func backButtonTapped() {
        self.dismiss(animated: true, completion: nil)
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
            rankScoreLabel.text = String(format: "%.f", rank.rankScore)
            winRateScoreLabel.text = String(format: "%.1f %%", winRate)
            accurencyScoreLabel.text = String(format: "%.1f %%", accurency)
        } else {
            accurencyScoreLabel.text = "准确率无法取得"
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
        guard let userName = UserDefaults.standard.string(forKey: "userName") else { return }
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
                print("建立房间失败: \(error.localizedDescription)")
            } else {
                print("房间建立成功，房间ID: \(roomId)")
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
                            "rank.correct": rank.correct,
                            "rank.winRate": rank.winRate,
                            "rank.playTimes": rank.playTimes,
                            "rank.rankScore": rank.rankScore
                        ]
                        guard let userID = UserDefaults.standard.string(forKey: "userID") else { return }
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
        guard let userName = UserDefaults.standard.string(forKey: "userName") else { return }
        updatedRoomData["Player2Name"] = userName
        
        ref.child("Rooms").child(roomId).updateChildValues(updatedRoomData) { error, _ in
            if let error = error {
                print("加入房间失败: \(error.localizedDescription)")
            } else {
                print("成功加入房间: \(roomId)")
                
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
                            "rank.correct": rank.correct,
                            "rank.winRate": rank.winRate,
                            "rank.playTimes": rank.playTimes,
                            "rank.rankScore": rank.rankScore
                        ]
                        guard let userID = UserDefaults.standard.string(forKey: "userID") else { return }
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
                            battlePage.animationView.play()
                        } else {
                            print("无法更新 RoomIsStart: \(error?.localizedDescription ?? "未知错误")")
                        }
                    }
                }
            }
        }
    }
}
