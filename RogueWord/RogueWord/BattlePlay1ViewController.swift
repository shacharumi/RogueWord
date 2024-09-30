import Foundation
import UIKit
import FirebaseDatabase
import SnapKit


class BattlePlay1ViewController: UIViewController {
    
    // MARK: - Properties
    
    var roomId: String?
    var ref: DatabaseReference!
    var rank: Rank?

    // MARK: - UI Elements
    
    var countdownLabel: UILabel!
    var questionIndexLabel: UILabel!
    var wordLabel: UILabel!
    var player1NameLabel: UILabel!
    var player2NameLabel: UILabel!
    var player1ScoreLabel: UILabel!
    var player2ScoreLabel: UILabel!
    var player1ProgressView: UIProgressView!
    var player2ProgressView: UIProgressView!
    var buttonView: UIView!
    var buttonArray: [UIButton] = []
    
    // MARK: - Game State Variables
    
    var player2Id: String?
    var player1Id: String?
    var whichPlayer: Int?
    var currentWord: JsonWord?
    var currentQuestionIndex: Int = 0
    var score: Int = 0
    var countdownActive = true
    var player1CountDown: Float = 0
    var player2CountDown: Float = 0
    var player1Select = ""
    var player2Select = ""
    var player1Score: Float = 0
    var player2Score: Float = 0
    var player1Correct: Float = 0
    var player2Correct: Float = 0

    var countdownTimer: Timer?
    var countdownValue: Float = 10
    var datadismiss: ((Rank?) -> Void)?

    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 初始化 Firebase Reference
        ref = Database.database().reference()
        
        // 设置 UI
        setupUI()
        
        // 设置 Firebase 监听器
        setRoomID()
    }
    
    // MARK: - Setup Methods
    
    func setupUI() {
        view.backgroundColor = .white
        
        // Player View
        let playerView = UIView()
        playerView.backgroundColor = .orange
        view.addSubview(playerView)
        playerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.equalTo(view).offset(16)
            make.right.equalTo(view).offset(-16)
            make.height.equalTo(100)
        }
        
        // Countdown Label
        countdownLabel = UILabel()
        countdownLabel.textAlignment = .center
        countdownLabel.font = UIFont.systemFont(ofSize: 32)
        countdownLabel.textColor = .black
        countdownLabel.text = "等待"
        playerView.addSubview(countdownLabel)
        
        countdownLabel.snp.makeConstraints { make in
            make.top.equalTo(playerView).offset(16)
            make.centerX.equalTo(playerView)
        }
        
        // Player 1 Name Label
        player1NameLabel = UILabel()
        player1NameLabel.textColor = .black
        player1NameLabel.font = UIFont.systemFont(ofSize: 32)
        player1NameLabel.text = "Player 1"
        playerView.addSubview(player1NameLabel)
        player1NameLabel.snp.makeConstraints { make in
            make.top.equalTo(playerView).offset(16)
            make.left.equalTo(playerView).offset(16)
            make.right.equalTo(countdownLabel.snp.left).offset(-16)
        }
        
        // Player 2 Name Label
        player2NameLabel = UILabel()
        player2NameLabel.textColor = .black
        player2NameLabel.font = UIFont.systemFont(ofSize: 32)
        player2NameLabel.text = "Player 2"
        playerView.addSubview(player2NameLabel)
        player2NameLabel.snp.makeConstraints { make in
            make.top.equalTo(playerView).offset(16)
            make.left.equalTo(countdownLabel.snp.right).offset(16)
            make.right.equalTo(playerView).offset(-16)
        }
        
        // Question View
        let questionView = UIView()
        questionView.backgroundColor = .yellow
        view.addSubview(questionView)
        questionView.snp.makeConstraints { make in
            make.top.equalTo(playerView.snp.bottom).offset(16)
            make.left.equalTo(view).offset(16)
            make.right.equalTo(view).offset(-16)
            make.height.equalTo(200)
        }
        
        // Question Index Label
        questionIndexLabel = UILabel()
        questionIndexLabel.textAlignment = .center
        questionIndexLabel.font = UIFont.systemFont(ofSize: 32)
        questionIndexLabel.textColor = .black
        questionIndexLabel.text = "題目: 0"
        view.addSubview(questionIndexLabel)
        
        questionIndexLabel.snp.makeConstraints { make in
            make.top.equalTo(questionView).offset(16)
            make.centerX.equalTo(view)
        }
        
        // Word Label
        wordLabel = UILabel()
        wordLabel.textAlignment = .center
        wordLabel.font = UIFont.systemFont(ofSize: 32)
        wordLabel.textColor = .black
        view.addSubview(wordLabel)
        
        wordLabel.snp.makeConstraints { make in
            make.top.equalTo(questionIndexLabel.snp.bottom).offset(16)
            make.centerX.equalTo(view)
        }
        
        // Button View
        buttonView = UIView()
        view.addSubview(buttonView)
        
        buttonView.snp.makeConstraints { make in
            make.top.equalTo(questionView.snp.bottom).offset(16)
            make.left.equalTo(view).offset(16)
            make.right.equalTo(view).offset(-16)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        // Player 1 Progress View
        player1ProgressView = UIProgressView(progressViewStyle: .bar)
        player1ProgressView.progressTintColor = .blue
        player1ProgressView.trackTintColor = .lightGray
        buttonView.addSubview(player1ProgressView)
        player1ProgressView.transform = CGAffineTransform(rotationAngle: -.pi / 2)
        
        player1ProgressView.snp.makeConstraints { make in
            make.centerX.equalTo(buttonView.snp.left).offset(16)
            make.centerY.equalTo(buttonView)
            make.height.equalTo(10)
            make.width.equalTo(buttonView.snp.height).offset(-48)
        }
        
        // Player 1 Score Label
        player1ScoreLabel = UILabel()
        player1ScoreLabel.textAlignment = .center
        player1ScoreLabel.font = UIFont.systemFont(ofSize: 20)
        player1ScoreLabel.textColor = .black
        player1ScoreLabel.text = "0"
        buttonView.addSubview(player1ScoreLabel)
        
        player1ScoreLabel.snp.makeConstraints { make in
            make.left.equalTo(buttonView).offset(16)
            make.top.equalTo(buttonView).offset(8)
        }
        
        // Player 2 Progress View
        player2ProgressView = UIProgressView(progressViewStyle: .bar)
        player2ProgressView.progressTintColor = .red
        player2ProgressView.trackTintColor = .lightGray
        buttonView.addSubview(player2ProgressView)
        
        player2ProgressView.transform = CGAffineTransform(rotationAngle: -.pi / 2)
        
        player2ProgressView.snp.makeConstraints { make in
            make.centerX.equalTo(buttonView.snp.right).offset(-16)
            make.centerY.equalTo(buttonView)
            make.height.equalTo(10)
            make.width.equalTo(buttonView.snp.height).offset(-48)
        }
        
        // Player 2 Score Label
        player2ScoreLabel = UILabel()
        player2ScoreLabel.textAlignment = .center
        player2ScoreLabel.font = UIFont.systemFont(ofSize: 20)
        player2ScoreLabel.textColor = .black
        player2ScoreLabel.text = "分數: 0"
        buttonView.addSubview(player2ScoreLabel)
        
        player2ScoreLabel.snp.makeConstraints { make in
            make.right.equalTo(buttonView).offset(-16)
            make.top.equalTo(buttonView).offset(8)
        }
        
        // 设置选项按钮
        setupButtons()
    }
    
    func setupButtons() {
        for i in 0..<4 {
            let button = UIButton(type: .system)
            button.backgroundColor = .lightGray
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 25
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOpacity = 0.3
            button.layer.shadowOffset = CGSize(width: 0, height: 2)
            button.tag = i
            button.addTarget(self, action: #selector(optionSelected(_:)), for: .touchUpInside)
            buttonView.addSubview(button)
            buttonArray.append(button)
            
            button.snp.makeConstraints { make in
                make.centerX.equalTo(buttonView)
                make.top.equalTo(buttonView.snp.top).offset(40 + i * 70)
                make.left.equalTo(buttonView).offset(26)
                make.right.equalTo(buttonView).offset(-26)
                make.height.equalTo(50)
            }
        }
    }
    
    // MARK: - Firebase Setup
    
    func setRoomID() {
        guard let roomId = roomId else {
            print("roomId 未設置，無法設置 Firebase 監聽器")
            return
        }
        
        ref.child("Rooms").child(roomId).child("Player1Name").observe(.value) { [weak self] snapshot in
            if let player1Name = snapshot.value as? String {
                DispatchQueue.main.async {
                    self?.player1NameLabel.text = player1Name
                }
            }
        }
        
        ref.child("Rooms").child(roomId).child("Player2Name").observe(.value) { [weak self] snapshot in
            if let player2Name = snapshot.value as? String {
                DispatchQueue.main.async {
                    self?.player2NameLabel.text = player2Name
                }
            }
        }
        
        ref.child("Rooms").child(roomId).child("Player1Score").observe(.value) { [weak self] snapshot in
            if let player1Score = snapshot.value as? Float {
                self?.player1Score = player1Score
                DispatchQueue.main.async {
                    self?.player1ScoreLabel.text = "分數: \(player1Score)"
                    self?.player1ProgressView.progress = player1Score / 100.0
                }
            }
        }
        
        ref.child("Rooms").child(roomId).child("Player2Score").observe(.value) { [weak self] snapshot in
            if let player2Score = snapshot.value as? Float {
                self?.player2Score = player2Score
                DispatchQueue.main.async {
                    self?.player2ScoreLabel.text = "分數: \(player2Score)"
                    self?.player2ProgressView.progress = player2Score / 100.0
                }
            }
        }
        
        ref.child("Rooms").child(roomId).child("PlayCounting").observe(.value) { [weak self] snapshot in
            if let countdownValue = snapshot.value as? Float {
                self?.countdownValue = countdownValue
                DispatchQueue.main.async {
                    self?.countdownLabel.text = "倒數: \(countdownValue) 秒"
                }
                
                if countdownValue <= 0  {
                    if self?.whichPlayer == 1 {
                        self?.evaluateAnswersAndScore()
                        self?.updateQuestionAndResetValues()
                    }
                }
            }
        }
        
        ref.child("Rooms").child(roomId).child("QuestionData").observe(.value) { [weak self] snapshot in
            if let questionData = snapshot.value as? [String: Any] {
                self?.updateQuestionFromFirebase(questionData: questionData)
            }
        }
        
        ref.child("Rooms").child(roomId).child("CurrentQuestionIndex").observe(.value) { [weak self] snapshot in
            if let currentIndex = snapshot.value as? Int {
                if currentIndex > 10 {
                        
                        DispatchQueue.main.async {
                            self?.countdownLabel.text = "遊戲結束！"
                            self?.stopFirebaseCountdown()
                            print("Game ended")
                        }
                        
                        // 分別檢查每個屬性
                        guard let whichPlayer = self?.whichPlayer else {
                            print("Error: whichPlayer is nil")
                            return
                        }
                        guard let player1Correct = self?.player1Correct else {
                            print("Error: player1Correct is nil")
                            return
                        }
                        guard let player2Correct = self?.player2Correct else {
                            print("Error: player2Correct is nil")
                            return
                        }
                        guard let player1Score = self?.player1Score else {
                            print("Error: player1Score is nil")
                            return
                        }
                        guard let player2Score = self?.player2Score else {
                            print("Error: player2Score is nil")
                            return
                        }
                        guard var rank = self?.rank else {
                            print("Error: rank is nil")
                            return
                        }
                        guard let datadismiss = self?.datadismiss else {
                            print("Error: datadismiss is nil")
                            return
                        }
                        
                        // 如果所有屬性都不為 nil，則繼續執行邏輯
                        if whichPlayer == 1 {
                            if player1Score >= player2Score {
                                rank.playTimes += 1
                                rank.winRate += 1
                                rank.rankScore += 30
                                rank.correct += player1Correct
                            } else if player2Score > player1Score {
                                rank.playTimes += 1
                                rank.rankScore -= 30
                                rank.correct += player1Correct
                            }
                        } else {
                            if player2Score >= player1Score {
                                rank.playTimes += 1
                                rank.winRate += 1
                                rank.rankScore += 30
                                rank.correct += player2Correct
                            } else if player1Score > player2Score {
                                rank.playTimes += 1
                                rank.rankScore -= 30
                                rank.correct += player2Correct
                            }
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            self?.dismiss(animated: true) {
                                datadismiss(rank)
                            }
                        }
                    
                    
                    
                } else {
                    DispatchQueue.main.async {
                        self?.questionIndexLabel.text = "目前題目: \(currentIndex)"
                    }
                    

                }
            }
        }
        
        ref.child("Rooms").child(roomId).child("RoomIsStart").observe(.value) { [weak self] snapshot in
            if let roomIsStart = snapshot.value as? Bool, roomIsStart {
                if self?.whichPlayer == 1 {
                    self?.randomizeWordAndOptions()
                    self?.startFirebaseCountdown()
                    self?.ref.child("Rooms").child(roomId).child("RoomIsStart").setValue(false)
                }
            }
        }
        
        ref.child("Rooms").child(roomId).child("Player1Select").observe(.value) { [weak self] snapshot in
            self?.player1CountDown = self?.countdownValue ?? 0
            self?.checkIfBothPlayersSelected(snapshot: snapshot, whichSelect: 1)
        }
        
        // Player2Select 监听
        ref.child("Rooms").child(roomId).child("Player2Select").observe(.value) { [weak self] snapshot in
            self?.player2CountDown = self?.countdownValue ?? 0
            self?.checkIfBothPlayersSelected(snapshot: snapshot, whichSelect: 2)
        }
        
        
    }
    
    // MARK: - Game Logic Methods
    
    @objc func optionSelected(_ sender: UIButton) {
        guard let roomId = roomId else { return }
        
        let selectedValue = sender.title(for: .normal)
        let playerKey = whichPlayer == 1 ? "Player1Select" : "Player2Select"
        
        ref.child("Rooms").child(roomId).updateChildValues([playerKey: selectedValue ?? ""])
    }
    
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
        
        print("Player1 started countdown with value: \(countdownValue)")
    }
    
    func stopFirebaseCountdown() {
        countdownTimer?.invalidate()
    }
    
    func updateQuestionAndResetValues() {
        guard let roomId = roomId else { return }
        
        ref.child("Rooms").child(roomId).child("CurrentQuestionIndex").observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }
            
            if let currentIndex = snapshot.value as? Int, currentIndex < 10 {
                currentQuestionIndex = currentIndex + 1
                
                DispatchQueue.main.async {
                    self.questionIndexLabel.text = "目前題目: \(self.currentQuestionIndex)"
                }
                
                self.ref.child("Rooms").child(roomId).updateChildValues([
                    "CurrentQuestionIndex": currentQuestionIndex,
                    "Player1Select": "",
                    "Player2Select": "",
                    "PlayCounting": 10
                ]) { error, _ in
                    if error == nil {
                        if self.whichPlayer == 1 {
                            self.randomizeWordAndOptions()
                            self.startFirebaseCountdown()
                        }
                        print("Moved to next question: \(self.currentQuestionIndex)")
                    } else {
                        print("Failed to update question: \(error!.localizedDescription)")
                    }
                }
            } else {
                
                currentQuestionIndex += 1
                self.ref.child("Rooms").child(roomId).updateChildValues([
                    "CurrentQuestionIndex": currentQuestionIndex ])
                
            }
        }
    }
    
    func evaluateAnswersAndScore() {
        guard let roomId = roomId, let currentWord = currentWord else { return }
        
        if self.player1Select == self.currentWord?.chinese {
            self.player1Score += 1 * self.player1CountDown
            self.player1Correct += 1
            self.ref.child("Rooms").child(roomId).child("Player1Score").setValue(self.player1Score)
        }
        
        if self.player2Select == self.currentWord?.chinese {
            self.player2Score += 1 * self.player2CountDown
            self.player2Correct += 1
            self.ref.child("Rooms").child(roomId).child("Player2Score").setValue(self.player2Score)
        }
    }
    
    func checkIfBothPlayersSelected(snapshot: DataSnapshot, whichSelect: Int) {
        guard let roomData = snapshot.value as? String else { return }
        
        if whichSelect == 1 {
            player1Select = roomData
            print("Player1 Select: \(player1Select)")
        } else {
            player2Select = roomData
            print("Player2 Select: \(player2Select)")
        }
        
        if !player1Select.isEmpty && !player2Select.isEmpty  {
            
            if whichPlayer == 1 {
                self.stopFirebaseCountdown()
                self.evaluateAnswersAndScore()
                self.updateQuestionAndResetValues()
            }
        }
    }
    
    // MARK: - Helper Methods
    
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
    
    func startGameForPlayer2() {
        guard let roomId = roomId else { return }
        
        ref.child("Rooms").child(roomId).child("RoomIsStart").observeSingleEvent(of: .value) { [weak self] snapshot in
            if let roomIsStart = snapshot.value as? Bool, roomIsStart {
                if self?.whichPlayer == 1 {
                    self?.randomizeWordAndOptions()
                }
            }
        }
    }
    
    
    func updateQuestionFromFirebase(questionData: [String: Any]) {
        if let question = questionData["Question"] as? String,
           let options = questionData["Options"] as? [String: String],
           let correctAnswer = questionData["CorrectAnswer"] as? String {
            
            self.currentWord = JsonWord(levelNumber: 0, english: question, chinese: correctAnswer, property: "", sentence: "")
            DispatchQueue.main.async {
                self.wordLabel.text = question
                
                for i in 0..<self.buttonArray.count {
                    self.buttonArray[i].setTitle(options["Option\(i)"], for: .normal)
                }
            }
        }
    }
    
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
            print("Successfully loaded data from words.json in documents directory.")
            
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
