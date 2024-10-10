
//
//  WrongQuestionWordVC.swift
//  RogueWord
//
//  Created by shachar on 2024/9/23.
//
import UIKit
import SnapKit

class WrongQuestionWordVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var questions: [GetWordFillType] = []  // 這裡存放傳遞過來的問題數據
    var selectAnswer: [String]?
    var questionsTitle: String?
    private let tableView = UITableView()
    private var customNavBar: UIView!  
    private let menuButton = UIButton(type: .system)
    private var isTapCheck: Bool = false
    var datadismiss: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCustomNavBar()
        setupTableView()
    }
    
    // 設置自定義導航欄
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
        backButton.setTitleColor(.white, for: .normal)
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
    
    // 返回按鈕功能
    @objc func backButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // 菜單按鈕功能：顯示答案和解釋
    @objc func menuButtonTapped() {
        let alert = UIAlertController(title: "選項", message: nil, preferredStyle: .actionSheet)
        
        // 解答選項
        let answerAction = UIAlertAction(title: "解答", style: .default) { [weak self] _ in
            guard let self = self else { return }
            isTapCheck = true
            self.tableView.reloadData()
        }
        
        let cancelCollection = UIAlertAction(title: "取消收藏", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            // 获取 fetchWrongQuestion 的集合引用
            let query = FirestoreEndpoint.fetchWrongQuestion.ref
                .whereField("title", isEqualTo: self.questionsTitle)
            
            // 执行查询
            query.getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error fetching documents: \(error)")
                } else if let snapshot = snapshot {
                    if snapshot.documents.isEmpty {
                        let noDocumentAlert = UIAlertController(title: "提示", message: "没有找到符合条件的文档", preferredStyle: .alert)
                        noDocumentAlert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
                        self.present(noDocumentAlert, animated: true, completion: nil)
                        return
                    }

                    for document in snapshot.documents {
                        document.reference.delete { error in
                            if let error = error {
                                print("Error removing document: \(error)")
                            } else {
                                print("Document successfully removed!")
                                
                                let successAlert = UIAlertController(title: "取消收藏", message: "取消收藏成功", preferredStyle: .alert)
                                successAlert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
                                self.present(successAlert, animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
            self.dismiss(animated: true) {
                self.datadismiss!()
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
        tableView.register(QuestionPageCell.self, forCellReuseIdentifier: "QuestionPageCell")
        tableView.backgroundColor = UIColor(named: "CollectionBackGround")
        tableView.separatorStyle = .none
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(customNavBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        selectAnswer = Array(repeating: "", count: questions.count)
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionPageCell", for: indexPath) as? QuestionPageCell {
            let question = questions[indexPath.row]
            guard let selectAnswer = self.selectAnswer else { return UITableViewCell() }
            cell.selectionStyle = .none
            cell.backgroundColor = UIColor(named: "CollectionBackGround")

            cell.answerSelectLabel.text = "(\(selectAnswer[indexPath.row]))"
            
            cell.questionLabel.text = question.question
            cell.optionLabel0.setTitle(question.options[0], for: .normal)
            cell.optionLabel1.setTitle(question.options[1], for: .normal)
            cell.optionLabel2.setTitle(question.options[2], for: .normal)
            cell.optionLabel3.setTitle(question.options[3], for: .normal)
            cell.optionLabel0.addTarget(self, action: #selector(tapOption(_:)), for: .touchUpInside)
            cell.optionLabel1.addTarget(self, action: #selector(tapOption(_:)), for: .touchUpInside)
            cell.optionLabel2.addTarget(self, action: #selector(tapOption(_:)), for: .touchUpInside)
            cell.optionLabel3.addTarget(self, action: #selector(tapOption(_:)), for: .touchUpInside)
            cell.answerLabel.text = "Answer: \(question.answer)"
            cell.translateButton.addTarget(self, action: #selector(translateText), for: .touchUpInside)
            cell.translateButton.isHidden = true

            if isTapCheck {
                cell.translateButton.tag = indexPath.row
                cell.optionLabel0.isUserInteractionEnabled = false
                cell.optionLabel1.isUserInteractionEnabled = false
                cell.optionLabel2.isUserInteractionEnabled = false
                cell.optionLabel3.isUserInteractionEnabled = false

                let selectedAnswer = selectAnswer[indexPath.row]
                let correctAnswer = questions[indexPath.row].answerOptions
                
                cell.translateButton.isHidden = false
                if selectedAnswer == correctAnswer {
                    cell.answerSelectLabel.textColor = .green
                    cell.answerSelectLabel.text = "( \(selectedAnswer ?? "") )"

                } else {
                    cell.answerSelectLabel.textColor = .red
                    cell.answerSelectLabel.text = "( \(selectedAnswer ?? "") )"
                }
            }
            
            
            return cell
        }
        return UITableViewCell()
    }
    
    @objc func tapOption(_ sender: UIButton) {
        guard let cell = sender.superview?.superview as? QuestionPageCell else { return }
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        switch sender.tag {
        case 0 :
            selectAnswer?[indexPath.row] = "A"
        case 1 :
            selectAnswer?[indexPath.row] = "B"
        case 2 :
            selectAnswer?[indexPath.row] = "C"
        case 3 :
            selectAnswer?[indexPath.row] = "D"
        default:
            print("Option error")
        }
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    @objc private func translateText(_ sender: UIButton) {
        let alert = UIAlertController(title: "Answer Text", message: questions[sender.tag].answer, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
