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
    
    private let favoriteButton: UIButton = {
        
        let button = UIButton(type: .system)
        button.setTitle("收藏", for: .normal)
        button.alpha = 0.5
        button.tag = 0
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        
        displayQuestion()

        let barButtonItem = UIBarButtonItem(customView: favoriteButton)
        self.navigationItem.rightBarButtonItem = barButtonItem
        
    }
    
    private func setupUI() {
        view.addSubview(englishLabel)
        view.addSubview(favoriteButton)
        favoriteButton.addTarget(self, action: #selector(addToFavorites(_:)), for: .touchUpInside)

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
            if viewModel.moveToNextQuestion() {
                displayQuestion()
                favoriteButton.tag = 0
            } else {
                showCompletionAlert()
            }
        } else {
            sender.backgroundColor = .red
        }
    }
    
    private func showCompletionAlert() {
        let alert = UIAlertController(title: "完成", message: "你已經完成所有問題", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "確定", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func addToFavorites(_ sender: UIButton) {
        if sender.tag == 0 {
            viewModel.addToFavorites()
            sender.alpha = 1
            sender.tag = 1
        } else {
            viewModel.removeToFavorites()
            sender.alpha = 0.5
            sender.tag = 0
        }
    }
}


