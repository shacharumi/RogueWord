//
//  SentenceFillGamePageViewController.swift
//  RogueWord
//
//  Created by shachar on 2024/10/10.
//

import UIKit
import SnapKit

class SentenceFillGamePageViewController: UIViewController {

    private let viewModel = SentenceFillGamePageModel()
    private var cardView: UIView!
    var levelNumber = 0
    var correctCount: Int = 0
    var wrongCount: Int = 0
    var isCorrect: [Bool] = []

    var returnLevelNumber: ((Int) -> Void)?
    var hasSelectedAnswer: Bool = false

    private let accurencyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        return label
    }()

    private let indexLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        return label
    }()

    private let sentenceLabel: UILabel = {
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
        label.text = "左滑收藏單字，右滑進入下一題"
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
        viewModel.currentQuestionIndex = levelNumber
        viewModel.currentCorrect = correctCount
        viewModel.currentWrong = wrongCount
        viewModel.currentIsCorrect = isCorrect
        setupUI()
        setupCustomNavigationBar()
        displayQuestion()
        addPanGestureToCard()
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
        cardView.addSubview(accurencyLabel)
        cardView.addSubview(sentenceLabel)
        cardView.addSubview(alertLabel)
        cardView.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.centerY.equalTo(view).offset(-100)
            make.left.equalTo(view).offset(32)
            make.right.equalTo(view).offset(-32)
            make.height.equalTo(400)
        }

        accurencyLabel.text = "\(String(format: "%.0f%%", (Float(viewModel.currentCorrect) / Float(viewModel.currentQuestionIndex)) * 100))"

        accurencyLabel.snp.makeConstraints { make in
            make.top.equalTo(cardView).offset(50)
            make.centerX.equalTo(cardView)
        }

        indexLabel.text = "當前題數: \(viewModel.currentQuestionIndex)"
        indexLabel.snp.makeConstraints { make in
            make.top.equalTo(cardView).offset(100)
            make.centerX.equalTo(cardView)
        }

        sentenceLabel.snp.makeConstraints { make in
            make.top.equalTo(indexLabel.snp.bottom).offset(32)
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
        titleLabel.text = "句子填空題"
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

    private func addPanGestureToCard() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleCardPan(_:)))
        cardView.addGestureRecognizer(panGesture)
    }

    @objc private func handleCardPan(_ gesture: UIPanGestureRecognizer) {
        guard hasSelectedAnswer else {
            return
        }

        let translation = gesture.translation(in: view)

        switch gesture.state {
        case .changed:
            cardView.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y - 100)
        case .ended:
            let velocity = gesture.velocity(in: view)
            if abs(velocity.x) > 500 || abs(translation.x) > 100 {
                let direction: SlideDirection = translation.x > 0 ? .right : .left
                animateCardOffScreen(direction: direction)
            } else {
                resetCardPosition()
            }
        default:
            break
        }
    }

    @objc private func goBack() {
        returnLevelNumber?(viewModel.currentQuestionIndex)
        self.dismiss(animated: true, completion: nil)
    }

    @objc private func answerTapped(_ sender: UIButton) {
        guard let answer = sender.currentTitle else { return }

        for button in answerButtons {
            button.isEnabled = false
        }

        hasSelectedAnswer = true

        if viewModel.checkAnswer(answer) {
            viewModel.currentCorrect += 1
            isCorrect.append(true)
            viewModel.currentIsCorrect = isCorrect
            sender.backgroundColor = UIColor(named: "CorrectColor")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.animateCardOffScreen(direction: .right)
            }
        } else {
            sender.backgroundColor = UIColor(named: "FalseColor")
            alertLabel.isHidden = false
            startFlashingAlertLabel()
            highlightCorrectAnswer()
            viewModel.currentWrong += 1
            isCorrect.append(false)
            viewModel.currentIsCorrect = isCorrect
        }
        viewModel.updateAccurency()
    }

    private func highlightCorrectAnswer() {
        for button in answerButtons where button.currentTitle == viewModel.missingWord {
            button.backgroundColor = UIColor(named: "CorrectColor")
            break
        }
    }

    private enum SlideDirection {
        case left, right
    }

    private func animateCardOffScreen(direction: SlideDirection) {
        let offScreenX: CGFloat = direction == .right ? UIScreen.main.bounds.width * 1.5 : -UIScreen.main.bounds.width * 1.5
        if direction == .left {
            self.viewModel.addToFavorites()
        }

        UIView.animate(withDuration: 0.3, animations: {
            self.cardView.center.x = offScreenX
            self.cardView.alpha = 0
        }) { _ in
            self.resetCardPosition()
            if self.viewModel.moveToNextQuestion() {
                self.displayQuestion()

            } else {
                self.showCompletionAlert()
            }
        }
    }

    private func resetCardPosition() {
        cardView.center = CGPoint(x: view.center.x, y: view.center.y - 100)
        cardView.alpha = 1
        alertLabel.isHidden = true
        alertLabel.layer.removeAllAnimations()
    }

    private func displayQuestion() {
        guard let question = viewModel.getFillCurrentQuestion() else {
            showCompletionAlert()
            return
        }

        hasSelectedAnswer = false
        viewModel.updateLevelNumber()
        accurencyLabel.text = "答對率: \(String(format: "%.0f%%", (Float(viewModel.currentCorrect) / Float(viewModel.currentQuestionIndex)) * 100))"
        sentenceLabel.text = question
        indexLabel.text = "當前題數: \(viewModel.currentQuestionIndex)"

        var answers = [viewModel.missingWord]
        answers.append(contentsOf: viewModel.generateWrongAnswers(for: viewModel.missingWord))
        answers.shuffle()

        for (index, button) in answerButtons.enumerated() where index < answers.count {
            button.setTitle(answers[index], for: .normal)
            button.backgroundColor = UIColor(named: "ButtonColor")
            button.isEnabled = true
        }
    }

    @objc private func goToPreviousQuestion() {
        if viewModel.currentQuestionIndex > 0 {
            viewModel.currentQuestionIndex -= 1

            if isCorrect[viewModel.currentQuestionIndex] {
                viewModel.currentCorrect -= 1
                isCorrect.remove(at: viewModel.currentQuestionIndex)
                viewModel.currentIsCorrect = isCorrect
            } else {
                viewModel.currentWrong -= 1
                isCorrect.remove(at: viewModel.currentQuestionIndex)
                viewModel.currentIsCorrect = isCorrect
            }
            UIView.animate(withDuration: 0.5, animations: {
                self.cardView.alpha = 0
            }) { _ in
                self.displayQuestion()
                UIView.animate(withDuration: 0.5) {
                    self.cardView.alpha = 1
                }
            }
        } else {
            let alert = UIAlertController(title: "提示", message: "這是第一張卡片，無法回退", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "確定", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }

    private func showCompletionAlert() {
        let alert = UIAlertController(title: "完成", message: "你已經完成所有問題", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "確定", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    private func startFlashingAlertLabel() {
        alertLabel.alpha = 1.0
        UIView.animate(withDuration: 1, delay: 0.0, options: [.repeat, .autoreverse], animations: {
            self.alertLabel.alpha = 0.0
        }, completion: nil)
    }
}
