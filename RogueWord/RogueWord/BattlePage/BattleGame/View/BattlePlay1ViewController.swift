import UIKit
import SnapKit
import Lottie
import FirebaseDatabase

class BattlePlay1ViewController: UIViewController {
    
    var viewModel: BattlePlayViewModel!
    var roomId: String?
    var rank: Rank?
    var whichPlayer: Int?
    var datadismiss: ((Rank?) -> Void)?
    
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
    var questionContainerView: UIView!
    
    var overlayView: UIView!
    
    let player1ImageView = UIImageView()
    let player2ImageView = UIImageView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let roomId = roomId, let rank = rank, let whichPlayer = whichPlayer else {
            print("缺少必要的初始化参数")
            return
        }
        viewModel = BattlePlayViewModel(roomId: roomId, rank: rank, whichPlayer: whichPlayer)
        
        setupUI()
        setupBindings()
        viewModel.setupFirebaseObservers()
    }
    
    deinit {
        viewModel.removeAllObservers()
    }
    
    
    func setupUI() {
        let backgroundView = UIImageView()
        backgroundView.image = UIImage(named: "battlingBackGround")
        view.addSubview(backgroundView)
        backgroundView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
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
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .heavy)
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
    
    func setupBindings() {
        viewModel.updateUIHandler = { [weak self] state in
            DispatchQueue.main.async {
                switch state {
                case .updatePlayer1Name(let name):
                    self?.player1NameLabel.text = name
                    self?.updatePlayer1Image()
                    self?.overlayView.isHidden = false
                    self?.waitingAnimationView.play()
                case .updatePlayer2Name(let name):
                    self?.player2NameLabel.text = name
                    self?.updatePlayer2Image()
                case .updatePlayer1Score(let score):
                    self?.player1ScoreLabel.text = "\(score)"
                    self?.player1ProgressView.progress = score / 100.0
                    self?.updateButtonColors()
                case .updatePlayer2Score(let score):
                    self?.player2ScoreLabel.text = "\(score)"
                    self?.player2ProgressView.progress = score / 100.0
                    self?.updateButtonColors()
                case .updateQuestion(let question, let options):
                    self?.wordLabel.text = question
                    for i in 0..<self!.buttonArray.count {
                        self?.buttonArray[i].setTitle(options[i], for: .normal)
                    }
                case .updateQuestionIndex(let index):
                    self?.animationView.stop()
                    self?.animationView.play()
                    self?.flipQuestionCard {
                        self?.questionIndexLabel.text = "Q\(index)"
                    }
                    self?.resetButtonStates()
                case .gameStarted:
                    self?.overlayView.isHidden = true
                    self?.waitingAnimationView.stop()
                case .updatePlayerSelections:
                    self?.updateButtonColors()
                }
            }
        }
        
        viewModel.gameEndHandler = { [weak self] updatedRank, message in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                let alert = UIAlertController(title: "結算畫面", message: message, preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "下一場", style: .default, handler: { _ in
                    self?.dismiss(animated: true) {
                        self?.datadismiss?(updatedRank)
                    }
                }))
                
                self?.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    
    @objc func optionSelected(_ sender: UIButton) {
        let selectedValue = sender.title(for: .normal) ?? ""
        viewModel.selectOption(selectedValue)
        displayCheckmark(on: sender)
    }
    
    func displayCheckmark(on button: UIButton) {
        buttonArray.forEach { btn in
            btn.subviews.forEach { subview in
                if subview is UIImageView && subview.tag == 999 {
                    subview.removeFromSuperview()
                }
            }
        }
        
        let checkmarkImageView = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        checkmarkImageView.tintColor = .white
        checkmarkImageView.tag = 999
        
        button.addSubview(checkmarkImageView)
        
        checkmarkImageView.snp.makeConstraints { make in
            if viewModel.whichPlayer == 1 {
                make.left.equalTo(button).offset(8)
            } else {
                make.right.equalTo(button).offset(-8)
            }
            make.centerY.equalTo(button)
            make.width.height.equalTo(24)
        }
    }
    
    @objc func back() {
        viewModel.removeAllObservers()
        guard let roomId = viewModel.roomId else { return }
        viewModel.ref.child("Rooms").child(roomId).removeValue { [weak self] error, _ in
            if let error = error {
                print("Error deleting room: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    self?.dismiss(animated: true)
                }
            }
        }
    }
    
    
    func updatePlayer1Image() {
        if let imageData = UserDefaults.standard.data(forKey: "imageData") {
            self.player1ImageView.image = UIImage(data: imageData)
        } else {
            self.player1ImageView.image = UIImage(systemName: "person")
        }
    }
    
    func updatePlayer2Image() {
        if let imageData = UserDefaults.standard.data(forKey: "imageData") {
            self.player2ImageView.image = UIImage(data: imageData)
        } else {
            self.player2ImageView.image = UIImage(systemName: "person")
        }
    }
    
    func updateButtonColors() {
        guard let correctAnswer = viewModel.currentWord?.chinese else { return }
        
        for button in buttonArray {
            let buttonTitle = button.title(for: .normal)
            
            if buttonTitle == correctAnswer {
                button.backgroundColor = UIColor(named: "CorrectColor")
            }
            
            if viewModel.whichPlayer == 1 && buttonTitle == viewModel.player1Select {
                if viewModel.player1Select == correctAnswer {
                    button.backgroundColor = UIColor(named: "CorrectColor")
                } else {
                    button.backgroundColor = UIColor(named: "FalseColor")
                }
            } else if viewModel.whichPlayer == 2 && buttonTitle == viewModel.player2Select {
                if viewModel.player2Select == correctAnswer {
                    button.backgroundColor = UIColor(named: "CorrectColor")
                } else {
                    button.backgroundColor = UIColor(named: "FalseColor")
                }
            }
        }
    }
    
    func resetButtonStates() {
        DispatchQueue.main.async {
            self.buttonArray.forEach { button in
                button.subviews.forEach { subview in
                    if subview is UIImageView && subview.tag == 999 {
                        subview.removeFromSuperview()
                    }
                }
                button.backgroundColor = UIColor(named: "buttonBackGroundColor")
            }
        }
    }
    
    func flipQuestionCard(completion: @escaping () -> Void) {
        let transitionOptions: UIView.AnimationOptions = [.transitionFlipFromRight]
        
        UIView.transition(with: questionContainerView, duration: 0.5, options: transitionOptions, animations: {
            completion()
        }, completion: nil)
    }
}
