//
//  CollectionPageGameViewController.swift
//  RogueWord
//
//  Created by shachar on 2024/10/13.
//

import UIKit
import SnapKit

class CollectionPageGameViewController: UIViewController {


    var collectionData: [FireBaseWord] = []

    private var cardView: UIView!
    private var hasSelectedAnswer: Bool = false

    private var viewModel: CollectionGameViewModel!

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
        viewModel = CollectionGameViewModel(collectionData: collectionData)
        displayQuestion()
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


    @objc private func goBack() {
        self.dismiss(animated: true, completion: nil)
    }

    @objc private func goToPreviousQuestion() {
        if viewModel.canMoveToPreviousQuestion() {
            viewModel.moveToPreviousQuestion()

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

        for button in answerButtons {
            button.isEnabled = false
        }

        let isCorrect = viewModel.checkAnswer(selectedAnswer)

        if isCorrect {
            sender.backgroundColor = UIColor(named: "CorrectColor")
            updateAccurencyLabel()

            flipCardAndShowNextQuestion()
        } else {
            sender.backgroundColor = UIColor(named: "FalseColor")
            alertLabel.isHidden = false
            highlightCorrectAnswer()
            updateAccurencyLabel()

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.flipCardAndShowNextQuestion()
            }
        }
    }

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

        alertLabel.isHidden = true

        indexLabel.text = "當前題數: \(viewModel.currentQuestionIndex + 1)"
        englishLabel.text = currentWord.english
        propertyLabel.text = "(\(currentWord.property))"
        sentenceLabel.text = currentWord.sentence

        let answers = viewModel.getAnswerOptions()

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
