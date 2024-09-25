//
//  LevelUpGamePageViewController.swift
//  RogueWord
//
//  Created by shachar on 2024/9/12.
//

import UIKit
import SnapKit

class LevelUpGamePageViewController: UIViewController {

    private let viewModel = LevelUpGamePageModel()
    private var cardView: UIView!
    var levelNumber = 0
    
    private let englishLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        return label
    }()

    private let propertyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
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
            button.layer.cornerRadius = 25
            buttons.append(button)
        }
        return buttons
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "PlayViewColor")
        viewModel.currentQuestionIndex = levelNumber
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

        cardView.addSubview(englishLabel)
        cardView.addSubview(propertyLabel)
        cardView.addSubview(sentenceLabel)

        cardView.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.centerY.equalTo(view).offset(-100)
            make.left.equalTo(view).offset(32)
            make.right.equalTo(view).offset(-32)
            make.height.equalTo(400)
        }

        englishLabel.snp.makeConstraints { make in
            make.top.equalTo(cardView).offset(100)
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

        let stackView = UIStackView(arrangedSubviews: answerButtons)
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.top.equalTo(cardView.snp.bottom).offset(16)
            make.left.equalTo(view).offset(32)
            make.right.equalTo(view).offset(-32)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }

        for button in answerButtons {
            button.snp.makeConstraints { make in
                make.height.equalTo(50)
            }

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
        backButton.setImage(UIImage(systemName: "arrowshape.turn.up.backward.2.fill"), for: .normal)
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        customNavBar.addSubview(backButton)

        backButton.snp.makeConstraints { make in
            make.left.equalTo(customNavBar).offset(16)
            make.centerY.equalTo(customNavBar)
        }

        let previousButton = UIButton(type: .system)
        previousButton.setTitle("上一題", for: .normal)
        previousButton.addTarget(self, action: #selector(goToPreviousQuestion), for: .touchUpInside)
        customNavBar.addSubview(previousButton)

        previousButton.snp.makeConstraints { make in
            make.right.equalTo(customNavBar).offset(-16)
            make.centerY.equalTo(customNavBar)
        }
        
        let titleLabel = UILabel()
        titleLabel.text = "英翻中選擇題"
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
        self.dismiss(animated: true, completion: nil)
    }

    @objc private func answerTapped(_ sender: UIButton) {
        guard let answer = sender.currentTitle else { return }

        for button in answerButtons {
            button.isEnabled = false
        }

        if viewModel.checkAnswer(answer) {
            sender.backgroundColor = UIColor(named: "CorrectColor")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.animateCardOffScreen(direction: .right)
            }
        } else {
            sender.backgroundColor = UIColor(named: "FalseColor")
            highlightCorrectAnswer()
            viewModel.addToFavorites()
        }
    }

    private func highlightCorrectAnswer() {
        guard let question = viewModel.getCurrentQuestion() else { return }

        for button in answerButtons {
            if button.currentTitle == question.chinese {
                button.backgroundColor = UIColor(named: "CorrectColor")
                break
            }
        }
    }

    private enum SlideDirection {
        case left, right
    }

    private func animateCardOffScreen(direction: SlideDirection) {
        let offScreenX: CGFloat = direction == .right ? UIScreen.main.bounds.width * 1.5 : -UIScreen.main.bounds.width * 1.5

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
    }

    private func displayQuestion() {
        guard let question = viewModel.getCurrentQuestion() else {
            showCompletionAlert()
            return
        }
        self.viewModel.updateLevelNumber()
        englishLabel.text = question.english
        propertyLabel.text = "(\(question.property))"
        sentenceLabel.text = question.sentence

        var answers = [question.chinese]
        answers.append(contentsOf: viewModel.generateWrongAnswers(for: question.chinese))
        answers.shuffle()

        for (index, button) in answerButtons.enumerated() {
            if index < answers.count {
                button.setTitle(answers[index], for: .normal)
                button.backgroundColor = UIColor(named: "ButtonColor")
                button.isEnabled = true // 重新启用按钮
            }
        }
    }

    @objc private func goToPreviousQuestion() {
        if viewModel.currentQuestionIndex > 0 {
            viewModel.currentQuestionIndex -= 1
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
}
