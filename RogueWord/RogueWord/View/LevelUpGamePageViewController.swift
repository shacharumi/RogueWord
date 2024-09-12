//
//  LevelUpGamePageViewController.swift
//  RogueWord
//
//  Created by shachar on 2024/9/12.
//

import UIKit

class LevelUpGamePageViewController: UIViewController {
    
    private let viewModel = LevelUpGamePageModel()
    
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
        
        displayQuestion()
        
        let favoriteButton = UIBarButtonItem(title: "收藏", style: .plain, target: self, action: #selector(addToFavorites))
        navigationItem.rightBarButtonItem = favoriteButton
    }
    
    private func setupUI() {
        view.addSubview(englishLabel)
        NSLayoutConstraint.activate([
            englishLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            englishLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        let stackView = UIStackView(arrangedSubviews: answerButtons)
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: englishLabel.bottomAnchor, constant: 50)
        ])
        
        for button in answerButtons {
            button.addTarget(self, action: #selector(answerTapped(_:)), for: .touchUpInside)
        }
    }
    
    private func displayQuestion() {
        guard let question = viewModel.getCurrentQuestion() else {
            showCompletionAlert()
            return
        }
        
        englishLabel.text = question.english
        
        // 準備正確答案和錯誤答案
        var answers = [question.chinese]
        answers.append(contentsOf: viewModel.generateWrongAnswers(for: question.chinese))
        answers.shuffle()  // 隨機排列選項
        
        // 將答案分配到按鈕
        for (index, button) in answerButtons.enumerated() {
            if index < answers.count {
                button.setTitle(answers[index], for: .normal)
                button.backgroundColor = .lightGray  // 重設按鈕顏色
            }
        }
    }
    
    @objc private func answerTapped(_ sender: UIButton) {
        guard let answer = sender.currentTitle else { return }
        
        if viewModel.checkAnswer(answer) {
            if viewModel.moveToNextQuestion() {
                displayQuestion()
            } else {
                showCompletionAlert()
            }
        } else {
            sender.backgroundColor = .red  // 點擊錯誤答案時，按鈕變紅
        }
    }
    
    private func showCompletionAlert() {
        let alert = UIAlertController(title: "完成", message: "你已經完成所有問題", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "確定", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func addToFavorites() {
        viewModel.addToFavorites()
    }
}


struct Word: Decodable {
    let english: String
    let chinese: String
    let property: String
    let sentence: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(english)
        hasher.combine(chinese)
    }
}

struct WordFile: Decodable {
    let wordType: [String: Word]
}
