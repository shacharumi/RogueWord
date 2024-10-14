//
//  CollectionPageGameViewController.swift
//  RogueWord
//
//  Created by shachar on 2024/10/13.
//

import UIKit
import SnapKit

class CollectionPageGameViewController: UIViewController {

    // MARK: - Properties

    var collectionData: [FireBaseWord] = [] // 接收來自 CollectionPageViewController 的資料

    private var cardView: UIView!
    private var currentQuestionIndex: Int = 0
    private var correctCount: Int = 0
    private var wrongCount: Int = 0
    private var isCorrect: [Bool] = []

    private var hasSelectedAnswer: Bool = false

    // MARK: - UI Elements

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

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "PlayViewColor")
        setupUI()
        setupCustomNavigationBar()
        displayQuestion()
    }

    // MARK: - UI Setup

    private func setupUI() {
        // Initialize cardView
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
        
        // Set constraints for cardView
        cardView.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.centerY.equalTo(view).offset(-100)
            make.left.equalTo(view).offset(32)
            make.right.equalTo(view).offset(-32)
            make.height.equalTo(400)
        }
        
        // Set constraints for accurencyLabel
        accurencyLabel.snp.makeConstraints { make in
            make.top.equalTo(cardView).offset(50)
            make.centerX.equalTo(cardView)
        }
        
        // Set constraints for indexLabel
        indexLabel.snp.makeConstraints { make in
            make.top.equalTo(cardView).offset(100)
            make.centerX.equalTo(cardView)
        }
        
        // Set constraints for englishLabel
        englishLabel.snp.makeConstraints { make in
            make.top.equalTo(cardView).offset(150)
            make.centerX.equalTo(cardView)
        }
        
        // Set constraints for propertyLabel
        propertyLabel.snp.makeConstraints { make in
            make.top.equalTo(englishLabel.snp.bottom).offset(8)
            make.centerX.equalTo(englishLabel)
        }

        // Set constraints for sentenceLabel
        sentenceLabel.snp.makeConstraints { make in
            make.top.equalTo(propertyLabel.snp.bottom).offset(8)
            make.left.equalTo(cardView).offset(16)
            make.right.equalTo(cardView).offset(-16)
        }
        
        // Set constraints for alertLabel
        alertLabel.snp.makeConstraints { make in
            make.top.equalTo(sentenceLabel.snp.bottom).offset(32)
            make.centerX.equalTo(cardView.snp.centerX)
        }
        
        // Initialize and set up answerButtons' StackView
        let stackView = UIStackView(arrangedSubviews: answerButtons)
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        view.addSubview(stackView)

        // Set constraints for stackView
        stackView.snp.makeConstraints { make in
            make.top.equalTo(cardView.snp.bottom).offset(16)
            make.left.equalTo(view).offset(32)
            make.right.equalTo(view).offset(-32)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }

        // Add target actions for each button
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

        let previousButton = UIButton(type: .system)
        previousButton.setTitle("上一題", for: .normal)
        previousButton.setTitleColor(UIColor(named: "TextColor"), for: .normal)
        previousButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)

        previousButton.addTarget(self, action: #selector(goToPreviousQuestion), for: .touchUpInside)
        customNavBar.addSubview(previousButton)

        previousButton.snp.makeConstraints { make in
            make.right.equalTo(customNavBar).offset(-16)
            make.centerY.equalTo(customNavBar)
        }
        
        let titleLabel = UILabel()
        titleLabel.text = "英翻中選擇題"
        titleLabel.textColor = UIColor(named: "TextColor")
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textAlignment = .center
        customNavBar.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(backButton.snp.right)
            make.right.equalTo(previousButton.snp.left)
            make.centerY.equalTo(customNavBar)
        }
    }

    // MARK: - Actions

    @objc private func goBack() {
        self.dismiss(animated: true, completion: nil)
    }

    @objc private func goToPreviousQuestion() {
        if currentQuestionIndex > 0 {
            currentQuestionIndex -= 1

            // 更新答對和答錯的計數
            if isCorrect[currentQuestionIndex] {
                correctCount -= 1
            } else {
                wrongCount -= 1
            }
            isCorrect.remove(at: currentQuestionIndex)

            // 執行單次翻轉動畫以顯示上一題
            UIView.transition(with: cardView, duration: 0.5, options: .transitionFlipFromLeft, animations: {
                self.displayQuestion()
            }, completion: nil)
        } else {
            let alert = UIAlertController(title: "提示", message: "這是第一張卡片，無法回退", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "確定", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }

    @objc private func answerTapped(_ sender: UIButton) {
        guard !hasSelectedAnswer, let selectedAnswer = sender.currentTitle else { return }
        hasSelectedAnswer = true

        // 禁用所有按鈕
        for button in answerButtons {
            button.isEnabled = false
        }

        // 獲取當前題目
        let currentWord = collectionData[currentQuestionIndex].word

        if selectedAnswer == currentWord.chinese {
            // 答對
            correctCount += 1
            isCorrect.append(true)
            sender.backgroundColor = UIColor(named: "CorrectColor")
            updateAccurencyLabel()

            // 執行翻轉動畫
            flipCardAndShowNextQuestion()
        } else {
            // 答錯
            wrongCount += 1
            isCorrect.append(false)
            sender.backgroundColor = UIColor(named: "FalseColor")
            alertLabel.isHidden = false
            highlightCorrectAnswer(correctAnswer: currentWord.chinese)
            updateAccurencyLabel()

            // 延遲一秒後執行翻轉動畫
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.flipCardAndShowNextQuestion()
            }
        }
    }

    // MARK: - Helper Methods

    private func updateAccurencyLabel() {
        let total = correctCount + wrongCount
        let accuracy = total > 0 ? (Float(correctCount) / Float(total)) * 100 : 0
        accurencyLabel.text = "答對率: \(String(format: "%.0f%%", accuracy))"
    }

    private func highlightCorrectAnswer(correctAnswer: String) {
        for button in answerButtons {
            if button.currentTitle == correctAnswer {
                button.backgroundColor = UIColor(named: "CorrectColor")
                break
            }
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

        if currentQuestionIndex < collectionData.count {
            // 隱藏 alertLabel
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

        // 隱藏 alertLabel
        alertLabel.isHidden = true

        // 更新 UI 元素
        indexLabel.text = "當前題數: \(currentQuestionIndex + 1)"
        englishLabel.text = currentWord.english
        propertyLabel.text = "(\(currentWord.property))"
        sentenceLabel.text = currentWord.sentence

        // 生成答案選項
        var answers = [currentWord.chinese]
        
        // 收集錯誤答案，確保不重複且不包含正確答案
        var wrongAnswers = collectionData.filter { $0.word.chinese != currentWord.chinese }.map { $0.word.chinese }
        wrongAnswers.shuffle()
        let numberOfWrongAnswers = min(3, wrongAnswers.count)
        answers.append(contentsOf: wrongAnswers.prefix(numberOfWrongAnswers))
        
        // 如果錯誤答案不足3個，補充一些固定的錯誤答案
        while answers.count < 4 {
            answers.append("錯誤答案")
        }
        
        // 打亂答案順序
        answers.shuffle()
        
        // 更新按鈕標題並重置按鈕顏色和啟用狀態
        for (index, button) in answerButtons.enumerated() {
            if index < answers.count {
                button.setTitle(answers[index], for: .normal)
                button.backgroundColor = UIColor(named: "ButtonColor")
                button.isEnabled = true
            }
        }

        updateAccurencyLabel()
    }

    private func showCompletionAlert() {
        let alert = UIAlertController(title: "完成", message: "你已經完成所有問題", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "確定", style: .default, handler: { _ in
            self.goBack()
        }))
        present(alert, animated: true, completion: nil)
    }
}
