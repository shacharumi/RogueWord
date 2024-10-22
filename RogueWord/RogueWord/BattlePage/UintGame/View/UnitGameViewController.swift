//
//  UnitGameViewController.swift
//  RogueWord
//
//  Created by shachar on 2024/10/14.
//

import UIKit
import SnapKit
import Firebase
import FirebaseDatabaseInternal

class UnitGameViewController: UIViewController {

    var collectionData: [FireBaseWord] = []
    var roomID: String?

    private var cardView: UIView!
    private var currentQuestionIndex: Int = 0
    private var correctCount: Int = 0
    private var wrongCount: Int = 0
    private var isCorrect: [Bool] = []

    private var hasSelectedAnswer: Bool = false

    private var startTime: Date?
    private var totalTime: TimeInterval = 0

    private let accurencyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.text = "答對率: 0%"
        return label
    }()

    private let indexLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.text = "當前題數: 0"
        return label
    }()

    private let englishLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.text = "English Text"
        return label
    }()

    private let propertyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label.textAlignment = .center
        label.text = "(Property)"
        return label
    }()

    private let sentenceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "Sentence goes here."
        return label
    }()

    private let answerButtons: [UIButton] = {
        var buttons = [UIButton]()
        for _ in 0..<4 {
            let button = UIButton(type: .system)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle("Answer", for: .normal)
            button.backgroundColor = UIColor(named: "ButtonColor")
            button.setTitleColor(.white, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            button.layer.cornerRadius = 15
            buttons.append(button)
        }
        return buttons
    }()

    private let alertLabel: UILabel = {
        let label = UILabel()
        label.text = "答錯了！即將進入下一題..."
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.textAlignment = .center
        label.isHidden = true
        label.numberOfLines = 2
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "PlayViewColor")
        setupUI()
        setupCustomNavigationBar()
        startTimer()
        displayQuestion()
    }

    private func startTimer() {
        startTime = Date()
    }

    private func stopTimer() {
        if let startTime = startTime {
            totalTime = Date().timeIntervalSince(startTime)
        }
    }

    private func calculateAccuracy() -> Float {
        let total = correctCount + wrongCount
        return total > 0 ? (Float(correctCount) / Float(total)) * 100 : 0
    }

    private func updateParticipantData(accuracy: Float, time: TimeInterval) {
        guard let roomID = self.roomID else { return }
        let ref = Database.database().reference()
        let email = UserDefaults.standard.string(forKey: "email") ?? "unknownEmail"
        let userEmail = email
        let playerName = UserDefaults.standard.string(forKey: "fullName") ?? "Unknown Player"

        ref.child("rooms").child(roomID).child("participants").child(encodeEmail(userEmail)).setValue([
            "name": playerName,
            "accuracy": accuracy,
            "time": time
        ])
    }

    func encodeEmail(_ email: String) -> String {
        return email.replacingOccurrences(of: ".", with: ",")
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
        cardView.addSubview(accurencyLabel)
        cardView.addSubview(indexLabel)
        cardView.addSubview(englishLabel)
        cardView.addSubview(propertyLabel)
        cardView.addSubview(sentenceLabel)
        cardView.addSubview(alertLabel)

        cardView.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.centerY.equalTo(view).offset(-100)
            make.left.equalTo(view).offset(32)
            make.right.equalTo(view).offset(-32)
            make.height.equalTo(400)
        }

        accurencyLabel.snp.makeConstraints { make in
            make.top.equalTo(cardView).offset(50)
            make.centerX.equalTo(cardView)
        }

        indexLabel.snp.makeConstraints { make in
            make.top.equalTo(cardView).offset(100)
            make.centerX.equalTo(cardView)
        }

        englishLabel.snp.makeConstraints { make in
            make.top.equalTo(cardView).offset(150)
            make.centerX.equalTo(cardView)
        }

        propertyLabel.snp.makeConstraints { make in
            make.top.equalTo(englishLabel.snp.bottom).offset(8)
            make.centerX.equalTo(englishLabel)
        }

        sentenceLabel.snp.makeConstraints { make in
            make.top.equalTo(propertyLabel.snp.bottom).offset(8)
            make.left.equalTo(cardView).offset(16)
            make.right.equalTo(cardView).offset(-16)
        }

        alertLabel.snp.makeConstraints { make in
            make.top.equalTo(sentenceLabel.snp.bottom).offset(32)
            make.centerX.equalTo(cardView.snp.centerX)
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
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }

        for button in answerButtons {
            button.addTarget(self, action: #selector(answerTapped(_:)), for: .touchUpInside)
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
        titleLabel.text = "英翻中選擇題"
        titleLabel.textColor = UIColor(named: "TextColor")
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textAlignment = .center
        customNavBar.addSubview(titleLabel)

        titleLabel.snp.makeConstraints { make in
            make.centerY.centerX.equalTo(customNavBar)
        }
    }

    @objc private func goBack() {
        self.dismiss(animated: true, completion: nil)
    }

    @objc private func answerTapped(_ sender: UIButton) {
        guard !hasSelectedAnswer, let selectedAnswer = sender.currentTitle else { return }
        hasSelectedAnswer = true

        for button in answerButtons {
            button.isEnabled = false
        }

        let currentWord = collectionData[currentQuestionIndex].word

        if selectedAnswer == currentWord.chinese {
            correctCount += 1
            isCorrect.append(true)
            sender.backgroundColor = UIColor(named: "CorrectColor")
            updateAccurencyLabel()

            flipCardAndShowNextQuestion()
        } else {
            wrongCount += 1
            isCorrect.append(false)
            sender.backgroundColor = UIColor(named: "FalseColor")
            alertLabel.isHidden = false
            highlightCorrectAnswer(correctAnswer: currentWord.chinese)
            updateAccurencyLabel()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.flipCardAndShowNextQuestion()
            }
        }
    }

    private func updateAccurencyLabel() {
        let total = correctCount + wrongCount
        let accuracy = total > 0 ? (Float(correctCount) / Float(total)) * 100 : 0
        accurencyLabel.text = "答對率: \(String(format: "%.0f%%", accuracy))"
    }

    private func highlightCorrectAnswer(correctAnswer: String) {
        for button in answerButtons where button.currentTitle == correctAnswer {
                button.backgroundColor = UIColor(named: "CorrectColor")
                break
        }
    }

    private func flipCardAndShowNextQuestion() {
        UIView.transition(with: cardView, duration: 0.5, options: .transitionFlipFromRight, animations: {
            self.moveToNextQuestion()
        }, completion: nil)
    }

    private func moveToNextQuestion() {
        currentQuestionIndex += 1
        hasSelectedAnswer = false

        if currentQuestionIndex < collectionData.count && currentQuestionIndex < 15 {
            alertLabel.isHidden = true
            displayQuestion()
        } else {
            showCompletionAlert()
        }
    }

    private func displayQuestion() {
        guard currentQuestionIndex < collectionData.count else {
            showCompletionAlert()
            return
        }

        let currentWord = collectionData[currentQuestionIndex].word

        alertLabel.isHidden = true

        indexLabel.text = "當前題數: \(currentQuestionIndex + 1)"
        englishLabel.text = currentWord.english
        propertyLabel.text = "(\(currentWord.property))"
        sentenceLabel.text = currentWord.sentence

        var answers = [currentWord.chinese]

        var wrongAnswers = collectionData.filter { $0.word.chinese != currentWord.chinese }.map { $0.word.chinese }
        wrongAnswers.shuffle()
        let numberOfWrongAnswers = min(3, wrongAnswers.count)
        answers.append(contentsOf: wrongAnswers.prefix(numberOfWrongAnswers))

        while answers.count < 4 {
            answers.append("錯誤答案")
        }

        answers.shuffle()

        for (index, button) in answerButtons.enumerated() where index < answers.count {
            button.setTitle(answers[index], for: .normal)
            button.backgroundColor = UIColor(named: "ButtonColor")
            button.isEnabled = true
        }
        
        updateAccurencyLabel()
    }

    private func showCompletionAlert() {
        stopTimer()
        let accuracy = calculateAccuracy()

        updateParticipantData(accuracy: accuracy, time: totalTime)

        let alert = UIAlertController(title: "完成", message: "你已經完成所有問題", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "確定", style: .default, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
}
