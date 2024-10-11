import UIKit
import SnapKit

class SayingGoesPageViewController: UIViewController {
    
    private var cardView: UIView!
    private var currentQuestionIndex: Int = 0
    private var sayings: [(english: String, chinese: String)] = [
        ("Actions speak louder than words.", "行動勝於言語"),
        ("A picture is worth a thousand words.", "一張圖片勝過千言萬語"),
        ("The early bird catches the worm.", "早起的鳥兒有蟲吃"),
        ("Don't judge a book by its cover.", "不要以貌取人"),
        ("Better late than never.", "遲做總比不做好"),
        ("Rome wasn't built in a day.", "羅馬不是一天建成的"),
        ("When in Rome, do as the Romans do.", "入鄉隨俗"),
        ("Two heads are better than one.", "三個臭皮匠，勝過一個諸葛亮"),
        ("A watched pot never boils.", "心急水不開"),
        ("Every cloud has a silver lining.", "黑暗中總有一線光明")
    ]
    
    private var shuffledOptions: [String] = []
    private var correctAnswer: String = ""
    
    private let indexLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private let englishLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let answerButtons: [UIButton] = {
        var buttons = [UIButton]()
        for _ in 0..<4 {
            let button = UIButton(type: .system)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.backgroundColor = UIColor(named: "ButtonColor")
            button.setTitleColor(.white, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            button.layer.cornerRadius = 15
            buttons.append(button)
        }
        return buttons
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "PlayViewColor")
        setupUI()
        setupCustomNavigationBar()
        displayQuestion()
        
        for button in answerButtons {
            button.addTarget(self, action: #selector(answerTapped(_:)), for: .touchUpInside)
        }
    }
    
    private func setupUI() {
        cardView = UIView()
        cardView.backgroundColor = UIColor(named: "PlayCardColor")
        cardView.layer.cornerRadius = 12
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.2
        cardView.layer.shadowOffset = CGSize(width: 0, height: 5)
        
        cardView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cardView)
        cardView.addSubview(indexLabel)
        cardView.addSubview(englishLabel)
        
        cardView.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.centerY.equalTo(view).offset(-100)
            make.left.equalTo(view).offset(32)
            make.right.equalTo(view).offset(-32)
            make.height.equalTo(400)
        }
        
        indexLabel.snp.makeConstraints { make in
            make.top.equalTo(cardView).offset(20)
            make.centerX.equalTo(cardView)
        }
        
        englishLabel.snp.makeConstraints { make in
            make.centerX.centerY.equalTo(cardView)
            make.left.equalTo(cardView).offset(16)
            make.right.equalTo(cardView).offset(-16)
        }
        
        let stackView = UIStackView(arrangedSubviews: answerButtons)
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        view.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(cardView.snp.bottom).offset(16)
            make.left.equalTo(view).offset(32)
            make.right.equalTo(view).offset(-32)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func setupCustomNavigationBar() {
        let customNavBar = UIView()
        customNavBar.backgroundColor = .clear
        view.addSubview(customNavBar)
    
        customNavBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalTo(view)
            make.height.equalTo(50)
        }
    
        let backButton = UIButton(type: .system)
        backButton.tintColor = UIColor(named: "TextColor")
        backButton.setImage(UIImage(systemName: "arrowshape.turn.up.backward.2.fill"), for: .normal)
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        customNavBar.addSubview(backButton)
    
        backButton.snp.makeConstraints { make in
            make.left.equalTo(customNavBar).offset(16)
            make.centerY.equalTo(customNavBar)
        }
        
        let titleLabel = UILabel()
        titleLabel.text = "諺語與中文翻譯"
        titleLabel.textColor = UIColor(named: "TextColor")
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textAlignment = .center
        customNavBar.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalTo(customNavBar)
            make.centerY.equalTo(customNavBar)
        }
    }
    
    private func displayQuestion() {
        let saying = sayings[currentQuestionIndex]
        indexLabel.text = "第 \(currentQuestionIndex + 1) 題"
        englishLabel.text = saying.0
        correctAnswer = saying.1
        
        // 生成隨機的選項（1 個正確答案 + 3 個錯誤答案）
        shuffledOptions = generateOptions(correctAnswer: correctAnswer)
        for (index, button) in answerButtons.enumerated() {
            button.setTitle(shuffledOptions[index], for: .normal)
            button.backgroundColor = UIColor(named: "ButtonColor")
            button.isEnabled = true
        }
    }
    
    private func generateOptions(correctAnswer: String) -> [String] {
        var wrongAnswers = sayings.map { $0.chinese }.filter { $0 != correctAnswer }
        wrongAnswers.shuffle()
        var options = [correctAnswer]
        options.append(contentsOf: wrongAnswers.prefix(3))
        return options.shuffled()
    }
    
    @objc private func answerTapped(_ sender: UIButton) {
        guard let selectedAnswer = sender.currentTitle else { return }
        
        for button in answerButtons {
            button.isEnabled = false
        }
        
        if selectedAnswer == correctAnswer {
            sender.backgroundColor = UIColor(named: "CorrectColor")
        } else {
            sender.backgroundColor = UIColor(named: "FalseColor")
            highlightCorrectAnswer()
        }
        
        // 延遲2秒後翻轉卡片並顯示下一題
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            UIView.transition(with: self.cardView, duration: 0.5, options: .transitionFlipFromRight, animations: {
                self.moveToNextQuestion()
            }, completion: nil)
        }
    }
    
    private func highlightCorrectAnswer() {
        for button in answerButtons {
            if button.currentTitle == correctAnswer {
                button.backgroundColor = UIColor(named: "CorrectColor")
            }
        }
    }
    
    private func moveToNextQuestion() {
        if currentQuestionIndex < sayings.count - 1 {
            currentQuestionIndex += 1
        } else {
            currentQuestionIndex = 0 // 如果已經是最後一題，重新從第一題開始
        }
        displayQuestion()
    }
    
    @objc private func goBack() {
        self.dismiss(animated: true, completion: nil)
    }
}
