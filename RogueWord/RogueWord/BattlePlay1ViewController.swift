import Foundation
import UIKit
import FirebaseDatabase
import SnapKit

class BattlePlay1ViewController: UIViewController {
    
    var roomId: String?
    var countdownLabel: UILabel!
    var questionIndexLabel: UILabel!
    var wordLabel: UILabel!
    var ref: DatabaseReference!
    var player2Id: String?
    var player1Id: String?
    var whichPlayer: Int?
    var currentWord: JsonWord?
    var score: Int = 0
    var buttonArray: [UIButton] = []
    var player1ScoreLabel: UILabel!
    var player2ScoreLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()

        setupUI()

        if let roomId = roomId {
            ref.child("Rooms").child(roomId).child("Player1Score").observe(.value) { [weak self] snapshot in
                if let player1Score = snapshot.value as? Int {
                    self?.player1ScoreLabel.text = "Player 1 分數: \(player1Score)"
                }
            }

            ref.child("Rooms").child(roomId).child("Player2Score").observe(.value) { [weak self] snapshot in
                if let player2Score = snapshot.value as? Int {
                    self?.player2ScoreLabel.text = "Player 2 分數: \(player2Score)"
                }
            }

            ref.child("Rooms").child(roomId).child("PlayCounting").observe(.value) { [weak self] snapshot in
                if let countdownValue = snapshot.value as? Int {
                    self?.countdownLabel.text = "倒數: \(countdownValue) 秒"
                }
            }

            ref.child("Rooms").child(roomId).child("QuestionData").observe(.value) { [weak self] snapshot in
                if let questionData = snapshot.value as? [String: Any] {
                    self?.updateQuestionFromFirebase(questionData: questionData)
                }
            }

            ref.child("Rooms").child(roomId).child("CurrentQuestionIndex").observe(.value) { [weak self] snapshot in
                if let currentIndex = snapshot.value as? Int {
                    self?.questionIndexLabel.text = "目前題目: \(currentIndex)"
                }
            }

            ref.child("Rooms").child(roomId).child("RoomIsStart").observe(.value) { [weak self] snapshot in
                if let roomIsStart = snapshot.value as? Bool, roomIsStart {
                    if self?.whichPlayer == 1 {
                        self?.randomizeWordAndOptions()
                    }
                    self?.startFirebaseCountdown()
                }
            }
        }
    }

    
    func setupUI() {
        view.backgroundColor = .white
        
        countdownLabel = UILabel(frame: CGRect(x: 0, y: 100, width: view.bounds.width, height: 50))
        countdownLabel.textAlignment = .center
        countdownLabel.font = UIFont.systemFont(ofSize: 32)
        countdownLabel.textColor = .black
        countdownLabel.text = "等待玩家準備..."
        view.addSubview(countdownLabel)
        
        questionIndexLabel = UILabel(frame: CGRect(x: 0, y: 160, width: view.bounds.width, height: 50))
        questionIndexLabel.textAlignment = .center
        questionIndexLabel.font = UIFont.systemFont(ofSize: 32)
        questionIndexLabel.textColor = .black
        questionIndexLabel.text = "目前題目: 0"
        view.addSubview(questionIndexLabel)
        
        wordLabel = UILabel(frame: CGRect(x: 0, y: 220, width: view.bounds.width, height: 50))
        wordLabel.textAlignment = .center
        wordLabel.font = UIFont.systemFont(ofSize: 32)
        wordLabel.textColor = .black
        view.addSubview(wordLabel)
        
        player1ScoreLabel = UILabel(frame: CGRect(x: 20, y: view.bounds.height - 150, width: view.bounds.width / 2 - 40, height: 50))
        player1ScoreLabel.textAlignment = .center
        player1ScoreLabel.font = UIFont.systemFont(ofSize: 10)
        player1ScoreLabel.textColor = .black
        player1ScoreLabel.text = "Player 1 分數: 0"
        view.addSubview(player1ScoreLabel)
        
        player2ScoreLabel = UILabel(frame: CGRect(x: view.bounds.width / 2 + 20, y: view.bounds.height - 150, width: view.bounds.width / 2 - 40, height: 50))
        player2ScoreLabel.textAlignment = .center
        player2ScoreLabel.font = UIFont.systemFont(ofSize: 10)
        player2ScoreLabel.textColor = .black
        player2ScoreLabel.text = "Player 2 分數: 0"
        view.addSubview(player2ScoreLabel)
        
        setupButtons()
    }
    
    func setupButtons() {
        for i in 0..<4 {
            let button = UIButton(type: .system)
            button.frame = CGRect(x: 50, y: 300 + i * 60, width: Int(view.bounds.width) - 100, height: 50)
            button.tag = i
            button.addTarget(self, action: #selector(optionSelected(_:)), for: .touchUpInside)
            button.backgroundColor = .lightGray
            button.setTitleColor(.white, for: .normal)
            view.addSubview(button)
            buttonArray.append(button)
        }
    }
    
    
    
    func startGameForPlayer2() {
        guard let roomId = roomId else { return }
        
        ref.child("Rooms").child(roomId).child("RoomIsStart").observeSingleEvent(of: .value) { [weak self] snapshot in
            if let roomIsStart = snapshot.value as? Bool, roomIsStart {
                if self?.whichPlayer == 1 {
                    self?.randomizeWordAndOptions()
                }
                self?.startFirebaseCountdown()
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
           let options = questionData["Options"] as? [String: String] {
            self.wordLabel.text = question
            
            for i in 0..<buttonArray.count {
                buttonArray[i].setTitle(options["Option\(i)"], for: .normal)
            }
        }
    }
    
    @objc func optionSelected(_ sender: UIButton) {
        guard let roomId = roomId else { return }
        
        let selectedValue = sender.title(for: .normal)
        
        let playerKey = whichPlayer == 1 ? "Player1Select" : "Player2Select"
        
        ref.child("Rooms").child(roomId).updateChildValues([playerKey: selectedValue ?? ""])
        
        print("玩家 \(whichPlayer == 1 ? "1" : "2") choose：\(selectedValue ?? "no choose")")
    }
    
    
    func startFirebaseCountdown() {
        guard let roomId = roomId, whichPlayer == 1 else { return }
        
        ref.child("Rooms").child(roomId).child("PlayCounting").observeSingleEvent(of: .value) { snapshot in
            if let playCounting = snapshot.value as? Int, playCounting > 0 {
                self.updateFirebaseCountdown(playCounting)
                
            }
        }
    }
    
    func updateFirebaseCountdown(_ countdownValue: Int) {
        guard let roomId = roomId, whichPlayer == 1 else { return }
        
        countdownLabel.text = "倒數: \(countdownValue) 秒"
        
        if countdownValue <= 0 {
            evaluateAnswersAndScore()
            updateQuestionAndResetValues()
            return
        }
        
        ref.child("Rooms").child(roomId).child("PlayCounting").setValue(countdownValue - 1) { [weak self] error, _ in
            if error == nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self?.updateFirebaseCountdown(countdownValue - 1)
                }
            } else {
                print("更新 PlayCounting 失敗：\(error!.localizedDescription)")
            }
        }
    }
    
    func updateQuestionAndResetValues() {
        guard let roomId = roomId, whichPlayer == 1 else { return }
        
        ref.child("Rooms").child(roomId).child("CurrentQuestionIndex").observeSingleEvent(of: .value) { [weak self] snapshot in
            if let currentIndex = snapshot.value as? Int, currentIndex < 10 {
                let nextIndex = currentIndex + 1
                
                self?.questionIndexLabel.text = "目前題目: \(nextIndex)"
                
                self?.ref.child("Rooms").child(roomId).updateChildValues([
                    "CurrentQuestionIndex": nextIndex,
                    "PlayCounting": 10,
                    "Player1Select": 0,
                    "Player2Select": 0
                ])
                
                self?.randomizeWordAndOptions()
                self?.startFirebaseCountdown()
            } else {
                DispatchQueue.main.async {
                    self?.countdownLabel.text = "遊戲結束！"
                }
            }
        }
    }
    
    func evaluateAnswersAndScore() {
        guard let roomId = roomId, let currentWord = currentWord else { return }
        
        ref.child("Rooms").child(roomId).observe(.value) { [weak self] snapshot in
            if let roomData = snapshot.value as? [String: Any] {
                let player1Select = roomData["Player1Select"] as? String
                let player2Select = roomData["Player2Select"] as? String
                
                if let player1Select = player1Select, player1Select == currentWord.chinese {
                    var player1Score = roomData["Player1Score"] as? Float ?? 0
                    player1Score += 0.5
                    self?.ref.child("Rooms").child(roomId).child("Player1Score").setValue(player1Score)
                }
                
                if let player2Select = player2Select, player2Select == currentWord.chinese {
                    var player2Score = roomData["Player2Score"] as? Float ?? 0
                    player2Score += 0.5
                    self?.ref.child("Rooms").child(roomId).child("Player2Score").setValue(player2Score)
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
