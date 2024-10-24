//
//  WrongQuestionReadingVC.swift
//  RogueWord
//
//  Created by shachar on 2024/9/24.
//

// WrongQuestionReadingVC.swift
import UIKit
import SnapKit

class WrongQuestionReadingVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var readingData: GetReadingType?
    var questionsTitle: String?
    var dataDismiss: (() -> Void)?
    var viewModel: WrongQuestionReadingViewModel!
    
    private let tableView = UITableView()
    private var customNavBar: UIView!
    private let menuButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "CollectionBackGround")
        setupCustomNavBar()
        setupTableView()
        
        if let readingData = readingData {
            viewModel = WrongQuestionReadingViewModel(readingData: readingData, questionsTitle: questionsTitle)
        } else {
            print("Reading data is nil")
        }
    }
    
    private func setupCustomNavBar() {
        customNavBar = UIView()
        customNavBar.backgroundColor = UIColor(named: "CollectionBackGround")
        
        view.addSubview(customNavBar)
        
        customNavBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.right.equalTo(view)
            make.height.equalTo(60)
        }
        
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(systemName: "arrowshape.turn.up.backward.2.fill"), for: .normal)
        backButton.tintColor = UIColor(named: "TextColor")
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        customNavBar.addSubview(backButton)
        
        backButton.snp.makeConstraints { make in
            make.leading.equalTo(customNavBar).offset(16)
            make.centerY.equalTo(customNavBar)
        }
        
        menuButton.setTitle("...", for: .normal)
        menuButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        menuButton.setTitleColor(UIColor(named: "TextColor"), for: .normal)
        menuButton.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
        customNavBar.addSubview(menuButton)
        
        menuButton.snp.makeConstraints { make in
            make.right.equalTo(customNavBar).offset(-16)
            make.centerY.equalTo(customNavBar)
        }
    }
    
    @objc func backButtonTapped() {
        self.dismiss(animated: true)
    }
    
    @objc func menuButtonTapped() {
        let alert = UIAlertController(title: "选项", message: nil, preferredStyle: .actionSheet)
        
        let answerAction = UIAlertAction(title: "解答", style: .default) { [weak self] _ in
            self?.viewModel.showAnswers()
            self?.tableView.reloadData()
        }
        
        let cancelCollection = UIAlertAction(title: "取消收藏", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.viewModel.cancelCollection { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success():
                        let successAlert = UIAlertController(title: "取消收藏", message: "取消收藏成功", preferredStyle: .alert)
                        successAlert.addAction(UIAlertAction(title: "确定", style: .default, handler: { _ in
                            self.dismiss(animated: true) {
                                self.dataDismiss?()
                            }
                        }))
                        self.present(successAlert, animated: true, completion: nil)
                    case .failure(let error):
                        let errorAlert = UIAlertController(title: "错误", message: error.localizedDescription, preferredStyle: .alert)
                        errorAlert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
                        self.present(errorAlert, animated: true, completion: nil)
                    }
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alert.addAction(answerAction)
        alert.addAction(cancelCollection)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ReadingTestCell.self, forCellReuseIdentifier: "ReadingTestCell")
        tableView.backgroundColor = UIColor(named: "CollectionBackGround")
        tableView.separatorStyle = .none
        tableView.snp.makeConstraints { make in
            make.top.equalTo(customNavBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (viewModel?.readingData.questions.count ?? 0) + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.row == 0 {
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.backgroundColor = UIColor(named: "CollectionBackGround")

            let cardView = UIView()
            cardView.backgroundColor = .white
            cardView.layer.cornerRadius = 10
            cardView.layer.shadowColor = UIColor.black.cgColor
            cardView.layer.shadowOpacity = 0.1
            cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
            cardView.layer.shadowRadius = 4
            cell.contentView.addSubview(cardView)

            let messageLabel = UILabel()
            messageLabel.text = viewModel.getReadingMessage()
            messageLabel.numberOfLines = 0
            cardView.addSubview(messageLabel)

            cardView.snp.makeConstraints { make in
                make.edges.equalTo(cell.contentView).inset(10)
            }

            messageLabel.snp.makeConstraints { make in
                make.edges.equalTo(cardView).inset(10)
            }

            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReadingTestCell", for: indexPath) as? ReadingTestCell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            cell.backgroundColor = UIColor(named: "CollectionBackGround")

            let questionIndex = indexPath.row - 1
            let selectedAnswer = viewModel.getSelectedAnswer(for: questionIndex)
            let options = viewModel.getOptions(for: questionIndex)
            let questionText = viewModel.getQuestion(at: questionIndex)

            cell.answerSelectLabel.text = "(\(selectedAnswer))"
            cell.questionLabel.text = questionText
            cell.optionLabel0.setTitle(options[0], for: .normal)
            cell.optionLabel1.setTitle(options[1], for: .normal)
            cell.optionLabel2.setTitle(options[2], for: .normal)
            cell.optionLabel3.setTitle(options[3], for: .normal)

            cell.optionLabel0.tag = questionIndex * 10 + 0
            cell.optionLabel1.tag = questionIndex * 10 + 1
            cell.optionLabel2.tag = questionIndex * 10 + 2
            cell.optionLabel3.tag = questionIndex * 10 + 3

            cell.optionLabel0.addTarget(self, action: #selector(tapOptions(_:)), for: .touchUpInside)
            cell.optionLabel1.addTarget(self, action: #selector(tapOptions(_:)), for: .touchUpInside)
            cell.optionLabel2.addTarget(self, action: #selector(tapOptions(_:)), for: .touchUpInside)
            cell.optionLabel3.addTarget(self, action: #selector(tapOptions(_:)), for: .touchUpInside)

            cell.translateButton.tag = questionIndex
            cell.translateButton.addTarget(self, action: #selector(translateText(_:)), for: .touchUpInside)
            cell.translateButton.isHidden = true

            if viewModel.isTapCheck {
                cell.translateButton.isHidden = false
                cell.optionLabel0.isUserInteractionEnabled = false
                cell.optionLabel1.isUserInteractionEnabled = false
                cell.optionLabel2.isUserInteractionEnabled = false
                cell.optionLabel3.isUserInteractionEnabled = false

                let correctAnswer = viewModel.getCorrectAnswer(for: questionIndex)

                if selectedAnswer == correctAnswer {
                    cell.answerSelectLabel.textColor = .green
                    cell.answerSelectLabel.text = "( \(selectedAnswer) )"
                } else {
                    cell.answerSelectLabel.textColor = .red
                    cell.answerSelectLabel.text = "( \(selectedAnswer) )"
                }
            } else {
                cell.answerSelectLabel.textColor = .black
                cell.optionLabel0.isUserInteractionEnabled = true
                cell.optionLabel1.isUserInteractionEnabled = true
                cell.optionLabel2.isUserInteractionEnabled = true
                cell.optionLabel3.isUserInteractionEnabled = true
            }

            return cell
        }
    }


    @objc func tapOptions(_ sender: UIButton) {
        let questionIndex = sender.tag / 10
        let optionTag = sender.tag % 10

        var answer = ""
        switch optionTag {
        case 0:
            answer = "A"
        case 1:
            answer = "B"
        case 2:
            answer = "C"
        case 3:
            answer = "D"
        default:
            print("Option error")
            return
        }

        viewModel.setSelectedAnswer(answer, for: questionIndex)

        let indexPath = IndexPath(row: questionIndex + 1, section: 0)
        tableView.reloadRows(at: [indexPath], with: .none)
    }

    @objc private func translateText(_ sender: UIButton) {
        let answerText = viewModel.getAnswerText(for: sender.tag)
        let alert = UIAlertController(title: "Answer Text", message: answerText, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
