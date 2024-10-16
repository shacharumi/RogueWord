//
//  BattlePlayViewModel.swift
//  RogueWord
//
//  Created by shachar on 2024/10/16.
//

import Foundation
import FirebaseDatabase

class BattlePlayViewModel {
    
    // MARK: - Properties
    var roomId: String?
    var ref: DatabaseReference!
    var rank: Rank?
    
    // UI 更新的闭包
    var updateUIHandler: ((BattlePlayUIState) -> Void)?
    var gameEndHandler: ((Rank?, String) -> Void)?
    var dismissHandler: (() -> Void)?
    
    // 游戏状态变量
    var player2Id: String?
    var player1Id: String?
    var whichPlayer: Int?
    var currentWord: JsonWord?
    var currentQuestionIndex: Int = 0
    var score: Int = 0
    var countdownValue: Float = 10
    var player1CountDown: Float = 0
    var player2CountDown: Float = 0
    var player1Select = ""
    var player2Select = ""
    var player1Score: Float = 0
    var player2Score: Float = 0
    var player1Correct: Float = 0
    var player2Correct: Float = 0
    var countdownTimer: Timer?
    
    // Firebase 观察者的引用
    var observers: [DatabaseHandle] = []
    
    init(roomId: String, rank: Rank?, whichPlayer: Int) {
        self.roomId = roomId
        self.rank = rank
        self.whichPlayer = whichPlayer
        ref = Database.database().reference()
    }
    
    deinit {
        removeAllObservers()
    }
    
    // MARK: - Firebase Setup
    
    func setupFirebaseObservers() {
        guard let roomId = roomId else { return }
        
        // 观察玩家名称的变化
        let player1NameHandle = ref.child("Rooms").child(roomId).child("Player1Name").observe(.value) { [weak self] snapshot in
            if let player1Name = snapshot.value as? String {
                self?.updateUIHandler?(.updatePlayer1Name(player1Name))
            }
        }
        
        let player2NameHandle = ref.child("Rooms").child(roomId).child("Player2Name").observe(.value) { [weak self] snapshot in
            if let player2Name = snapshot.value as? String {
                self?.updateUIHandler?(.updatePlayer2Name(player2Name))
            }
        }
        
        // 观察游戏进度
        let player1ScoreHandle = ref.child("Rooms").child(roomId).child("Player1Score").observe(.value) { [weak self] snapshot in
            if let player1Score = snapshot.value as? Float {
                self?.player1Score = player1Score
                self?.updateUIHandler?(.updatePlayer1Score(player1Score))
            }
        }
        
        let player2ScoreHandle = ref.child("Rooms").child(roomId).child("Player2Score").observe(.value) { [weak self] snapshot in
            if let player2Score = snapshot.value as? Float {
                self?.player2Score = player2Score
                self?.updateUIHandler?(.updatePlayer2Score(player2Score))
            }
        }
        
        // 倒计时
        let countdownHandle = ref.child("Rooms").child(roomId).child("PlayCounting").observe(.value) { [weak self] snapshot in
            if let countdownValue = snapshot.value as? Float {
                self?.countdownValue = countdownValue
                if countdownValue <= 0 {
                    if self?.whichPlayer == 1 {
                        self?.evaluateAnswersAndScore()
                        self?.updateQuestionAndResetValues()
                    }
                }
            }
        }
        
        // 题目数据
        let questionDataHandle = ref.child("Rooms").child(roomId).child("QuestionData").observe(.value) { [weak self] snapshot in
            if let questionData = snapshot.value as? [String: Any] {
                self?.updateQuestionFromFirebase(questionData: questionData)
            }
        }
        
        // 当前题目索引
        let currentQuestionIndexHandle = ref.child("Rooms").child(roomId).child("CurrentQuestionIndex").observe(.value) { [weak self] snapshot in
            if let currentIndex = snapshot.value as? Int {
                self?.handleQuestionIndexChange(currentIndex)
            }
        }
        
        // 游戏开始标志
        let roomIsStartHandle = ref.child("Rooms").child(roomId).child("RoomIsStart").observe(.value) { [weak self] snapshot in
            if let roomIsStart = snapshot.value as? Bool, roomIsStart {
                if self?.whichPlayer == 1 {
                    self?.randomizeWordAndOptions()
                    self?.startFirebaseCountdown()
                    self?.ref.child("Rooms").child(roomId).child("RoomIsStart").setValue(false)
                }
                self?.updateUIHandler?(.gameStarted)
            }
        }
        
        // 玩家选择
        let player1SelectHandle = ref.child("Rooms").child(roomId).child("Player1Select").observe(.value) { [weak self] snapshot in
            self?.player1CountDown = self?.countdownValue ?? 0
            self?.checkIfBothPlayersSelected(snapshot: snapshot, whichSelect: 1)
        }
        
        let player2SelectHandle = ref.child("Rooms").child(roomId).child("Player2Select").observe(.value) { [weak self] snapshot in
            self?.player2CountDown = self?.countdownValue ?? 0
            self?.checkIfBothPlayersSelected(snapshot: snapshot, whichSelect: 2)
        }
        
        // 保存观察者的句柄以便后续移除
        observers.append(contentsOf: [player1NameHandle, player2NameHandle, player1ScoreHandle, player2ScoreHandle, countdownHandle, questionDataHandle, currentQuestionIndexHandle, roomIsStartHandle, player1SelectHandle, player2SelectHandle])
    }
    
    func removeAllObservers() {
        guard let roomId = roomId else { return }
        for handle in observers {
            ref.child("Rooms").child(roomId).removeObserver(withHandle: handle)
        }
    }
    
    // MARK: - 游戏逻辑方法
    
    func startFirebaseCountdown() {
        guard whichPlayer == 1 else { return }
        
        countdownTimer?.invalidate()
        countdownValue = 10
        
        if let roomId = roomId {
            ref.child("Rooms").child(roomId).child("PlayCounting").setValue(countdownValue)
        }
        
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            self.countdownValue -= 1
            
            if let roomId = self.roomId {
                self.ref.child("Rooms").child(roomId).child("PlayCounting").setValue(self.countdownValue)
            }
            
            if self.countdownValue <= 0 {
                timer.invalidate()
                self.evaluateAnswersAndScore()
                self.updateQuestionAndResetValues()
            }
        }
    }
    
    func stopFirebaseCountdown() {
        countdownTimer?.invalidate()
    }
    
    func evaluateAnswersAndScore() {
        guard let roomId = roomId, let currentWord = currentWord else { return }
        
        // 计算玩家1的分数
        if self.player1Select == currentWord.chinese {
            self.player1Score += 1 * self.player1CountDown
            self.player1Correct += 1
            self.ref.child("Rooms").child(roomId).child("Player1Score").setValue(self.player1Score)
        }
        
        // 计算玩家2的分数
        if self.player2Select == currentWord.chinese {
            self.player2Score += 1 * self.player2CountDown
            self.player2Correct += 1
            self.ref.child("Rooms").child(roomId).child("Player2Score").setValue(self.player2Score)
        }
        
        // 更新按钮颜色
        self.updateUIHandler?(.updatePlayerSelections)
    }
    
    func updateQuestionAndResetValues() {
        guard let roomId = roomId else { return }
        
        ref.child("Rooms").child(roomId).child("CurrentQuestionIndex").observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }
            
            if let currentIndex = snapshot.value as? Int, currentIndex < 10 {
                self.currentQuestionIndex = currentIndex + 1
                
                self.ref.child("Rooms").child(roomId).updateChildValues([
                    "CurrentQuestionIndex": self.currentQuestionIndex,
                    "Player1Select": "",
                    "Player2Select": "",
                    "PlayCounting": 10
                ]) { error, _ in
                    if error == nil {
                        if self.whichPlayer == 1 {
                            self.randomizeWordAndOptions()
                            self.startFirebaseCountdown()
                        }
                    } else {
                        print("Failed to update question: \(error!.localizedDescription)")
                    }
                }
            } else {
                // 游戏结束
                self.currentQuestionIndex = (snapshot.value as? Int) ?? 10
                self.ref.child("Rooms").child(roomId).updateChildValues([
                    "CurrentQuestionIndex": self.currentQuestionIndex
                ])
                self.calculateFinalScore()
            }
        }
    }
    
    func checkIfBothPlayersSelected(snapshot: DataSnapshot, whichSelect: Int) {
        guard let roomData = snapshot.value as? String else { return }
        
        if whichSelect == 1 {
            player1Select = roomData
        } else {
            player2Select = roomData
        }
        
        if !player1Select.isEmpty && !player2Select.isEmpty {
            if whichPlayer == 1 {
                self.stopFirebaseCountdown()
                self.evaluateAnswersAndScore()
                
                // 延迟一段时间后更新题目，让玩家有时间查看答案
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.updateQuestionAndResetValues()
                }
            }
        }
    }
    
    func randomizeWordAndOptions() {
        let randomIndex = Int.random(in: 0...999)
        
        if let jsonWord = loadWordFromFile(for: randomIndex) {
            self.currentWord = jsonWord
            let correctAnswer = jsonWord.chinese
            
            var randomOptions = [correctAnswer]
            while randomOptions.count < 4 {
                let randomOptionIndex = Int.random(in: 0...999)
                if let wrongWord = loadWordFromFile(for: randomOptionIndex), !randomOptions.contains(wrongWord.chinese) {
                    randomOptions.append(wrongWord.chinese)
                }
            }
            randomOptions.shuffle()
            
            let questionData: [String: Any] = [
                "Question": jsonWord.english,
                "Options": [
                    "Option0": randomOptions[0],
                    "Option1": randomOptions[1],
                    "Option2": randomOptions[2],
                    "Option3": randomOptions[3]
                ],
                "CorrectAnswer": correctAnswer
            ]
            
            if let roomId = roomId {
                ref.child("Rooms").child(roomId).child("QuestionData").setValue(questionData)
            }
        } else {
            print("No data found in JSON for level \(randomIndex)")
        }
    }
    
    func updateQuestionFromFirebase(questionData: [String: Any]) {
        if let question = questionData["Question"] as? String,
           let options = questionData["Options"] as? [String: String],
           let correctAnswer = questionData["CorrectAnswer"] as? String {
            
            self.currentWord = JsonWord(levelNumber: 0, english: question, chinese: correctAnswer, property: "", sentence: "")
            
            let uiState = BattlePlayUIState.updateQuestion(question: question, options: [
                options["Option0"] ?? "",
                options["Option1"] ?? "",
                options["Option2"] ?? "",
                options["Option3"] ?? ""
            ])
            self.updateUIHandler?(uiState)
        }
    }
    
    func handleQuestionIndexChange(_ currentIndex: Int) {
        if currentIndex > 10 {
            self.stopFirebaseCountdown()
            self.calculateFinalScore()
        } else {
            if currentIndex >= 1 {
                self.updateUIHandler?(.updateQuestionIndex(currentIndex))
            }
        }
    }
    
    func calculateFinalScore() {
        guard let whichPlayer = self.whichPlayer,
              var rank = self.rank else { return }
        
        var message = ""
        
        if whichPlayer == 1 {
            if player1Score > player2Score {
                rank.playTimes += 1
                rank.winRate += 1
                rank.rankScore += 30
                rank.correct += player1Correct
                message = "恭喜玩家胜利！！"
            } else {
                rank.playTimes += 1
                rank.rankScore = max(0, rank.rankScore - 30)
                rank.correct += player1Correct
                message = "继续加油！！"
            }
        } else {
            if player2Score > player1Score {
                rank.playTimes += 1
                rank.winRate += 1
                rank.rankScore += 30
                rank.correct += player2Correct
                message = "恭喜玩家胜利！！"
            } else {
                rank.playTimes += 1
                rank.rankScore = max(0, rank.rankScore - 30)
                rank.correct += player2Correct
                message = "继续加油！！"
            }
        }
        
        self.gameEndHandler?(rank, message)
    }
    
    // MARK: - 选项选择
    
    func selectOption(_ option: String) {
        guard let roomId = roomId else { return }
        
        let playerKey = whichPlayer == 1 ? "Player1Select" : "Player2Select"
        ref.child("Rooms").child(roomId).updateChildValues([playerKey: option])
    }
    
    // MARK: - 帮助方法
    
    private func loadWordFromFile(for levelNumber: Int) -> JsonWord? {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Error: Could not find the documents directory.")
            return nil
        }
        
        let fileURL = documentDirectory.appendingPathComponent("words.json")
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("Error: words.json file not found in the documents directory.")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let wordData = json["\(levelNumber)"] as? [String: Any] {
                if let levelNumber = wordData["levelNumber"] as? Int,
                   let english = wordData["english"] as? String,
                   let chinese = wordData["chinese"] as? String,
                   let property = wordData["property"] as? String,
                   let sentence = wordData["sentence"] as? String {
                    
                    let jsonWord = JsonWord(levelNumber: levelNumber, english: english, chinese: chinese, property: property, sentence: sentence)
                    return jsonWord
                } else {
                    print("Error: Missing one or more fields in wordData")
                    return nil
                }
            } else {
                print("No word found for level \(levelNumber) in JSON")
                return nil
            }
        } catch {
            print("Error during JSON loading or decoding: \(error.localizedDescription)")
            return nil
        }
    }
}


// BattlePlayUIState.swift
enum BattlePlayUIState {
    case updatePlayer1Name(String)
    case updatePlayer2Name(String)
    case updatePlayer1Score(Float)
    case updatePlayer2Score(Float)
    case updateQuestion(question: String, options: [String])
    case updateQuestionIndex(Int)
    case gameStarted
    case updatePlayerSelections // 新增的状态，用于更新按钮颜色
}
