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

    var collectionData: [FireBaseWord] = [] // 接收来自其他控制器的数据

    private var cardView: UIView!
    private var hasSelectedAnswer: Bool = false

    // ViewModel
    private var viewModel: CollectionGameViewModel!

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
        // 初始化 ViewModel
        viewModel = CollectionGameViewModel(collectionData: collectionData)
        displayQuestion()
    }

    // MARK: - UI Setup

    private func setupUI() {
        // 初始化 cardView
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
        
        // 设置 cardView 的约束
        cardView.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.centerY.equalTo(view).offset(-100)
            make.left.equalTo(view).offset(32)
            make.right.equalTo(view).offset(-32)
            make.height.equalTo(400)
        }
        
        // 设置 accurencyLabel 的约束
        accurencyLabel.snp.makeConstraints { make in
            make.top.equalTo(cardView).offset(50)
            make.centerX.equalTo(cardView)
        }
        
        // 设置 indexLabel 的约束
        indexLabel.snp.makeConstraints { make in
            make.top.equalTo(cardView).offset(100)
            make.centerX.equalTo(cardView)
        }
        
        // 设置 englishLabel 的约束
        englishLabel.snp.makeConstraints { make in
            make.top.equalTo(cardView).offset(150)
            make.centerX.equalTo(cardView)
        }
        
        // 设置 propertyLabel 的约束
        propertyLabel.snp.makeConstraints { make in
            make.top.equalTo(englishLabel.snp.bottom).offset(8)
            make.centerX.equalTo(englishLabel)
        }

        // 设置 sentenceLabel 的约束
        sentenceLabel.snp.makeConstraints { make in
            make.top.equalTo(propertyLabel.snp.bottom).offset(8)
            make.left.equalTo(cardView).offset(16)
            make.right.equalTo(cardView).offset(-16)
        }
        
        // 设置 alertLabel 的约束
        alertLabel.snp.makeConstraints { make in
            make.top.equalTo(sentenceLabel.snp.bottom).offset(32)
            make.centerX.equalTo(cardView.snp.centerX)
        }
        
        // 初始化并设置 answerButtons 的 StackView
        let stackView = UIStackView(arrangedSubviews: answerButtons)
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        view.addSubview(stackView)

        // 设置 stackView 的约束
        stackView.snp.makeConstraints { make in
            make.top.equalTo(cardView.snp.bottom).offset(16)
            make.left.equalTo(view).offset(32)
            make.right.equalTo(view).offset(-32)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }

        // 为每个按钮添加目标动作
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
        if viewModel.canMoveToPreviousQuestion() {
            viewModel.moveToPreviousQuestion()

            // 执行翻转动画以显示上一题
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

        // 禁用所有按钮
        for button in answerButtons {
            button.isEnabled = false
        }

        let isCorrect = viewModel.checkAnswer(selectedAnswer)

        if isCorrect {
            // 答对
            sender.backgroundColor = UIColor(named: "CorrectColor")
            updateAccurencyLabel()

            // 执行翻转动画
            flipCardAndShowNextQuestion()
        } else {
            // 答错
            sender.backgroundColor = UIColor(named: "FalseColor")
            alertLabel.isHidden = false
            highlightCorrectAnswer()
            updateAccurencyLabel()

            // 延迟一秒后执行翻转动画
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.flipCardAndShowNextQuestion()
            }
        }
    }

    // MARK: - Helper Methods

    private func updateAccurencyLabel() {
        let accuracy = viewModel.getAccuracy()
        accurencyLabel.text = "答對率: \(String(format: "%.0f%%", accuracy))"
    }

    private func highlightCorrectAnswer() {
        guard let currentWord = viewModel.getCurrentQuestion()?.word else { return }
        let correctAnswer = currentWord.chinese
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
        viewModel.moveToNextQuestion()
        hasSelectedAnswer = false

        if let _ = viewModel.getCurrentQuestion() {
            // 隐藏 alertLabel
            alertLabel.isHidden = true
            displayQuestion()
        } else {
            showCompletionAlert()
        }
    }

    private func displayQuestion() {
        guard let currentWord = viewModel.getCurrentQuestion()?.word else {
            showCompletionAlert()
            return
        }

        // 隐藏 alertLabel
        alertLabel.isHidden = true

        // 更新 UI 元素
        indexLabel.text = "當前題數: \(viewModel.currentQuestionIndex + 1)"
        englishLabel.text = currentWord.english
        propertyLabel.text = "(\(currentWord.property))"
        sentenceLabel.text = currentWord.sentence

        // 生成答案选项
        let answers = viewModel.getAnswerOptions()

        // 更新按钮标题并重置按钮颜色和启用状态
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
