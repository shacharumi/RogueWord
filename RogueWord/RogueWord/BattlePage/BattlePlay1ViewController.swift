import Foundation
import UIKit
import FirebaseDatabase
import SnapKit
import Lottie

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
    let animationView = LottieAnimationView(name: "CountDown")
    let waitingAnimationView = LottieAnimationView(name: "searchBattle")

    // 新增：用于翻转动画的视图
    var questionContainerView: UIView!
    
    // 新增：遮罩视图
    var overlayView: UIView!
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
    let player1ImageView = UIImageView()
    let player2ImageView = UIImageView()
    
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
        setRoomID()
    }
    
    // MARK: - Setup Methods
    
    func setupUI() {
        let backgroundView = UIImageView()
        backgroundView.image = UIImage(named: "battlingBackGround")
        view.addSubview(backgroundView)
        backgroundView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        // Player View
        let playerView = UIView()
        playerView.backgroundColor = .clear
        view.addSubview(playerView)
        playerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.equalTo(view).offset(16)
            make.right.equalTo(view).offset(-16)
            make.height.equalTo(100)
        }
        
        
        animationView.contentMode = .scaleAspectFit
        animationView.tintColor = UIColor(named: "questionColor")
        animationView.loopMode = .loop
        
        playerView.addSubview(animationView)
        
        animationView.snp.makeConstraints { make in
            make.centerY.equalTo(playerView)
            make.centerX.equalTo(playerView)
            make.top.equalTo(playerView).offset(16)
            make.width.height.equalTo(60)
        }

        player1ImageView.image = UIImage(systemName: "person")
        player1ImageView.contentMode = .scaleAspectFill
        player1ImageView.clipsToBounds = true
        player1ImageView.layer.cornerRadius = 20
        player1ImageView.layer.borderWidth = 2
        playerView.addSubview(player1ImageView)
        player1ImageView.snp.makeConstraints { make in
            make.right.equalTo(animationView.snp.left).offset(-32)
            make.top.equalTo(playerView).offset(16)
            make.height.width.equalTo(40)
        }
        
        player1NameLabel = UILabel()
        player1NameLabel.textColor =  UIColor(named: "questionColor")
        player1NameLabel.font = UIFont.systemFont(ofSize: 16)
        player1NameLabel.text = "Player 1"
        playerView.addSubview(player1NameLabel)
        player1NameLabel.snp.makeConstraints { make in
            make.top.equalTo(player1ImageView.snp.bottom).offset(16)
            make.centerX.equalTo(player1ImageView)
        }
        
        
        player2ImageView.image = UIImage(systemName: "person")
        player2ImageView.contentMode = .scaleAspectFill
        player2ImageView.clipsToBounds = true
        player2ImageView.layer.cornerRadius = 20
        player2ImageView.layer.borderWidth = 2
        playerView.addSubview(player2ImageView)
        player2ImageView.snp.makeConstraints { make in
            make.top.equalTo(playerView).offset(16)
            make.left.equalTo(animationView.snp.right).offset(32)
            make.height.width.equalTo(40)
        }
        
        
        player2NameLabel = UILabel()
        player2NameLabel.textColor = UIColor(named: "questionColor")
        player2NameLabel.font = UIFont.systemFont(ofSize: 16)
        player2NameLabel.text = "Player 2"
        playerView.addSubview(player2NameLabel)
        player2NameLabel.snp.makeConstraints { make in
            make.top.equalTo(player2ImageView.snp.bottom).offset(16)
            make.centerX.equalTo(player2ImageView)
        }
        
        // 新增：用于翻转动画的容器视图
        questionContainerView = UIView()
        questionContainerView.backgroundColor = .clear
        view.addSubview(questionContainerView)
        questionContainerView.snp.makeConstraints { make in
            make.top.equalTo(playerView.snp.bottom).offset(16)
            make.left.equalTo(view).offset(16)
            make.right.equalTo(view).offset(-16)
            make.height.equalTo(200)
        }
        
        let questionView = UIView()
        questionView.backgroundColor = .white
        questionView.layer.cornerRadius = 15
        questionView.layer.masksToBounds = false
        questionContainerView.addSubview(questionView)
        questionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        questionIndexLabel = UILabel()
        questionIndexLabel.textAlignment = .center
        questionIndexLabel.font = UIFont.systemFont(ofSize: 32)
        questionIndexLabel.textColor = UIColor(named: "questionColor")
        questionIndexLabel.text = "Q0"
        questionView.addSubview(questionIndexLabel)
        
        questionIndexLabel.snp.makeConstraints { make in
            make.top.equalTo(questionView).offset(16)
            make.centerX.equalTo(questionView)
        }
        
        wordLabel = UILabel()
        wordLabel.textAlignment = .center
        wordLabel.font = UIFont.systemFont(ofSize: 32)
        wordLabel.textColor = UIColor(named: "questionColor")
        questionView.addSubview(wordLabel)
        
        wordLabel.snp.makeConstraints { make in
            make.top.equalTo(questionIndexLabel.snp.bottom).offset(16)
            make.centerX.equalTo(questionView)
        }
        
        buttonView = UIView()
        view.addSubview(buttonView)
        
        buttonView.snp.makeConstraints { make in
            make.top.equalTo(questionContainerView.snp.bottom).offset(16)
            make.left.equalTo(view).offset(16)
            make.right.equalTo(view).offset(-16)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        player1ProgressView = UIProgressView(progressViewStyle: .bar)
        player1ProgressView.progressTintColor = UIColor(named: "progressBarColor")
        player1ProgressView.trackTintColor = UIColor(named: "progressBarBackColor")
        player1ProgressView.layer.cornerRadius = 7
        player1ProgressView.layer.masksToBounds = true
        buttonView.addSubview(player1ProgressView)
        player1ProgressView.transform = CGAffineTransform(rotationAngle: -.pi / 2)
        
        player1ProgressView.snp.makeConstraints { make in
            make.centerX.equalTo(buttonView.snp.left).offset(16)
            make.centerY.equalTo(buttonView)
            make.height.equalTo(15)
            make.width.equalTo(buttonView.snp.height).offset(-80)
        }
        
        player1ScoreLabel = UILabel()
        player1ScoreLabel.textAlignment = .center
        player1ScoreLabel.font = UIFont.systemFont(ofSize: 20)
        player1ScoreLabel.textColor = UIColor(named: "questionColor")
        player1ScoreLabel.text = "0"
        buttonView.addSubview(player1ScoreLabel)
        
        player1ScoreLabel.snp.makeConstraints { make in
            make.centerX.equalTo(player1ProgressView)
            make.top.equalTo(buttonView).offset(8)
        }
        
        player2ProgressView = UIProgressView(progressViewStyle: .bar)
        player2ProgressView.progressTintColor = UIColor(named: "progressBarColor")
        player2ProgressView.trackTintColor = UIColor(named: "progressBarBackColor")
        player2ProgressView.layer.cornerRadius = 7
        player2ProgressView.layer.masksToBounds = true
        buttonView.addSubview(player2ProgressView)
        player2ProgressView.transform = CGAffineTransform(rotationAngle: -.pi / 2)
        
        player2ProgressView.snp.makeConstraints { make in
            make.centerX.equalTo(buttonView.snp.right).offset(-16)
            make.centerY.equalTo(buttonView)
            make.height.equalTo(15)
            make.width.equalTo(buttonView.snp.height).offset(-80)
        }
        
        player2ScoreLabel = UILabel()
        player2ScoreLabel.textAlignment = .center
        player2ScoreLabel.font = UIFont.systemFont(ofSize: 20)
        player2ScoreLabel.textColor = UIColor(named: "questionColor")
        player2ScoreLabel.text = "0"
        buttonView.addSubview(player2ScoreLabel)
        
        player2ScoreLabel.snp.makeConstraints { make in
            make.centerX.equalTo(player2ProgressView)
            make.top.equalTo(buttonView).offset(8)
        }
        
        setupButtons()
        
        overlayView = UIView()
        overlayView.isHidden = true 
        overlayView.backgroundColor = .white.withAlphaComponent(0.6)
        view.addSubview(overlayView)
        overlayView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        
        
        
           waitingAnimationView.loopMode = .loop
           overlayView.addSubview(waitingAnimationView)
           waitingAnimationView.snp.makeConstraints { make in
               make.center.equalTo(overlayView)
               make.width.height.equalTo(300)
           }
        
        
        let backButton = UIButton()
        backButton.setTitle("退出等待", for: .normal)
        backButton.setTitleColor(.black, for: .normal)
        backButton.layer.cornerRadius = 30
        backButton.layer.masksToBounds = false
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 24,weight: .heavy)
        backButton.backgroundColor = UIColor(named: "viewBackGround")
        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        backButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)

        overlayView.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.top.equalTo(waitingAnimationView.snp.bottom).offset(16)
            make.centerX.equalTo(waitingAnimationView)
            make.height.equalTo(60)
            make.width.equalTo(180)
        }
        view.bringSubviewToFront(overlayView)
    }
    
    @objc func back() {
        guard let roomId = roomId else { return }
        ref.child("Rooms").child(roomId).removeValue { [weak self] error, _ in
            if let error = error {
                print("Error deleting room: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    self?.dismiss(animated: true)
                }
            }
        }
    }

    func setupButtons() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        
        buttonView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 60, left: 48, bottom: 60, right: 48))
        }

        let numberOfButtons = 4
        let buttonHeight: CGFloat = 50

        for i in 0..<numberOfButtons {
            let button = UIButton(type: .system)
            button.backgroundColor = UIColor(named: "buttonBackGroundColor")
            button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 25
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOpacity = 0.3
            button.layer.shadowOffset = CGSize(width: 0, height: 2)
            button.tag = i
            button.addTarget(self, action: #selector(optionSelected(_:)), for: .touchUpInside)
            buttonArray.append(button)

            button.snp.makeConstraints { make in
                make.height.equalTo(buttonHeight)
            }

            stackView.addArrangedSubview(button)
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
                    if let imageData = UserDefaults.standard.data(forKey: "imageData") {
                        self?.player1ImageView.image = UIImage(data: imageData)
                    } else {
                        self?.player1ImageView.image = UIImage(systemName: "person")
                    }
                    
                    self?.overlayView.isHidden = false
                    self?.waitingAnimationView.play()

                }
            }
        }
        
        ref.child("Rooms").child(roomId).child("Player2Name").observe(.value) { [weak self] snapshot in
            if let player2Name = snapshot.value as? String {
                DispatchQueue.main.async {
                    self?.player2NameLabel.text = player2Name
                    if let imageData = UserDefaults.standard.data(forKey: "imageData") {
                        self?.player2ImageView.image = UIImage(data: imageData)
                    } else {
                        self?.player2ImageView.image = UIImage(systemName: "person")
                    }
                }
            }
        }
     
        ref.child("Rooms").child(roomId).child("Player1Score").observe(.value) { [weak self] snapshot in
            if let player1Score = snapshot.value as? Float {
                self?.player1Score = player1Score
                DispatchQueue.main.async {
                    self?.animationView.stop()
                    self?.player1ScoreLabel.text = "\(player1Score)"
                    self?.player1ProgressView.progress = player1Score / 100.0
                    self?.updateButtonColors()
                }
            }
        }
        
        ref.child("Rooms").child(roomId).child("Player2Score").observe(.value) { [weak self] snapshot in
            if let player2Score = snapshot.value as? Float {
                self?.player2Score = player2Score
                DispatchQueue.main.async {
                    self?.animationView.stop()
                    self?.player2ScoreLabel.text = "\(player2Score)"
                    self?.player2ProgressView.progress = player2Score / 100.0
                    self?.updateButtonColors()
                }
            }
        }
        
        ref.child("Rooms").child(roomId).child("PlayCounting").observe(.value) { [weak self] snapshot in
            if let countdownValue = snapshot.value as? Float {
                self?.countdownValue = countdownValue
                
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
                        self?.animationView.stop()
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
                    
                    if whichPlayer == 1 {
                        if player1Score >= player2Score {
                            rank.playTimes += 1
                            rank.winRate += 1
                            rank.rankScore += 30
                            rank.correct += player1Correct
                        } else if player2Score > player1Score {
                            rank.playTimes += 1
                            if rank.rankScore >= 30 {
                                rank.rankScore -= 30
                            } else {
                                rank.rankScore = 0
                            }
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
                            if rank.rankScore >= 30 {
                                rank.rankScore -= 30
                            } else {
                                rank.rankScore = 0
                            }
                            rank.correct += player2Correct
                        }
                    }
                    var mes = ""
                    if whichPlayer == 1 {
                        if player1Score > player2Score {
                            mes = "恭喜玩家勝利！！"
                        } else {
                            mes = "繼續加油！！"
                        }
                    } else {
                        if player1Score < player2Score {
                            mes = "恭喜玩家勝利！！"
                        } else {
                            mes = "繼續加油！！"
                        }
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        let alert = UIAlertController(title: "結算畫面", message: mes, preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "下一場", style: .default, handler: { _ in
                            self?.dismiss(animated: true) {
                                datadismiss(rank)
                            }
                        }))
                        
                        self?.present(alert, animated: true, completion: nil)
                    }
                    
                    
                } else {
                    DispatchQueue.main.async {
                        
                        if currentIndex >= 1{
                            self?.animationView.stop()
                            self?.animationView.play()
                            
                                self?.flipQuestionCard {
                                    self?.questionIndexLabel.text = "Q\(currentIndex)"
                                }
                            
                            
                            
                            DispatchQueue.main.async {
                                self?.buttonArray.forEach { button in
                                    button.subviews.forEach { subview in
                                        if subview is UIImageView && subview.tag == 999 {
                                            subview.removeFromSuperview()
                                        }
                                    }
                                    button.backgroundColor = UIColor(named: "buttonBackGroundColor")
                                }
                            }
                        }
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
                    self?.animationView.play()
                }
                
                DispatchQueue.main.async {
                    self?.overlayView.isHidden = true
                    self?.waitingAnimationView.stop()

                }
            }
        }
        
        ref.child("Rooms").child(roomId).child("Player1Select").observe(.value) { [weak self] snapshot in
            self?.player1CountDown = self?.countdownValue ?? 0
            self?.checkIfBothPlayersSelected(snapshot: snapshot, whichSelect: 1)
        }
        
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
        
        // 新增：在選中的按鈕上顯示勾勾
        displayCheckmark(on: sender)
    }
    
    // 新增方法：顯示勾勾
    func displayCheckmark(on button: UIButton) {
        // 移除所有按鈕上的勾勾
        buttonArray.forEach { btn in
            btn.subviews.forEach { subview in
                if subview is UIImageView && subview.tag == 999 {
                    subview.removeFromSuperview()
                }
            }
        }
        
        // 創建勾勾圖標
        let checkmarkImageView = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        checkmarkImageView.tintColor = .white
        checkmarkImageView.tag = 999 // 用於識別勾勾圖標
        
        button.addSubview(checkmarkImageView)
        
        checkmarkImageView.snp.makeConstraints { make in
            if whichPlayer == 1 {
                // 對於 Player 1，勾勾顯示在左側
                make.left.equalTo(button).offset(8)
            } else {
                // 對於 Player 2，勾勾顯示在右側
                make.right.equalTo(button).offset(-8)
            }
            make.centerY.equalTo(button)
            make.width.height.equalTo(24)
        }
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
                
                // 延遲一段時間後更新題目，讓玩家有時間查看答案
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.updateQuestionAndResetValues()
                }
            }
        }
    }
    
    // 新增方法：更新按鈕的背景顏色
    func updateButtonColors() {
        guard let correctAnswer = currentWord?.chinese else { return }
        
        for button in buttonArray {
            let buttonTitle = button.title(for: .normal)
            
            // 如果是正確答案，將按鈕背景設為綠色
            if buttonTitle == correctAnswer {
                button.backgroundColor = UIColor(named: "CorrectColor")
            }
            
            // 判斷玩家的選擇
            if whichPlayer == 1 && buttonTitle == player1Select {
                if player1Select == correctAnswer {
                    button.backgroundColor = UIColor(named: "CorrectColor")
                } else {
                    button.backgroundColor = UIColor(named: "FalseColor")
                }
            } else if whichPlayer == 2 && buttonTitle == player2Select {
                if player2Select == correctAnswer {
                    button.backgroundColor = UIColor(named: "CorrectColor")
                } else {
                    button.backgroundColor = UIColor(named: "FalseColor")
                }
            }
        }
    }
    
    func flipQuestionCard(completion: @escaping () -> Void) {
        let transitionOptions: UIView.AnimationOptions = [.transitionFlipFromRight]
        
        UIView.transition(with: questionContainerView, duration: 0.5, options: transitionOptions, animations: {
            completion()
        }, completion: nil)
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
                    self?.animationView.play()
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
