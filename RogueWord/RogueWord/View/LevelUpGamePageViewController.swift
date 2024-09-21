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
    
    private let englishLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private let answerButtons: [UIButton] = {
        var buttons = [UIButton]()
        for _ in 0..<4 {
            let button = UIButton(type: .system)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle("Answer", for: .normal)
            button.backgroundColor = .lightGray
            button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            button.layer.cornerRadius = 8
            buttons.append(button)
        }
        return buttons
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupNavigationBar()
        displayQuestion()
    }
    
    private func setupUI() {
        // 建立卡片視圖
        cardView = UIView()
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 12
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.2
        cardView.layer.shadowOffset = CGSize(width: 0, height: 5)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cardView)
        
        // 將英文標籤加入卡片內
        cardView.addSubview(englishLabel)
        
        cardView.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.centerY.equalTo(view).offset(-100)
            make.width.equalTo(300)
            make.height.equalTo(400)
        }
        
        englishLabel.snp.makeConstraints { make in
            make.top.equalTo(cardView).offset(-100)
            make.centerX.equalTo(cardView)
        }
        
        
        // 建立選項按鈕的堆疊視圖
        let stackView = UIStackView(arrangedSubviews: answerButtons)
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 50)
        ])
        
        for button in answerButtons {
            button.addTarget(self, action: #selector(answerTapped(_:)), for: .touchUpInside)
        }
    }
    
    private func setupNavigationBar() {
        // 添加 "上一張卡片" 的按鈕到右上角
        let previousButton = UIBarButtonItem(title: "上一張", style: .plain, target: self, action: #selector(goToPreviousQuestion))
        self.navigationItem.rightBarButtonItem = previousButton
    }
    
    private func displayQuestion() {
        guard let question = viewModel.getCurrentQuestion() else {
            showCompletionAlert()
            return
        }
        
        englishLabel.text = question.english
        
        var answers = [question.chinese]
        answers.append(contentsOf: viewModel.generateWrongAnswers(for: question.chinese))
        answers.shuffle()
        
        for (index, button) in answerButtons.enumerated() {
            if index < answers.count {
                button.setTitle(answers[index], for: .normal)
                button.backgroundColor = .lightGray
            }
        }
    }
    
    @objc private func answerTapped(_ sender: UIButton) {
        guard let answer = sender.currentTitle else { return }
        
        if viewModel.checkAnswer(answer) {
            // 選對，向右滑動
            animateCardSlide(direction: .right)
        } else {
            // 選錯，向左滑動並加入收藏
            viewModel.addToFavorites()
            animateCardSlide(direction: .left)
        }
    }
    
    private enum SlideDirection {
        case left, right
    }
    
    private func animateCardSlide(direction: SlideDirection) {
        let offScreenX: CGFloat = direction == .right ? UIScreen.main.bounds.width : -UIScreen.main.bounds.width
        
        UIView.animate(withDuration: 0.5, animations: {
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
        cardView.center = view.center
        cardView.alpha = 1
    }
    
    private func showCompletionAlert() {
        let alert = UIAlertController(title: "完成", message: "你已經完成所有問題", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "確定", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // 回到上一張卡片，使用淡出淡入動畫
    @objc private func goToPreviousQuestion() {
        if viewModel.currentQuestionIndex > 0 {
            viewModel.currentQuestionIndex -= 1
            // 卡片淡出並淡入恢復
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
}
