
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
    private var customNavBar: UIView!  // 自定義導航欄
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white  // 設置背景色
        setupCustomNavBar()  // 設置自定義導航欄
        setupTableView()     // 設置表格視圖
    }
    
    // 設置自定義導航欄
    private func setupCustomNavBar() {
        customNavBar = UIView()
        customNavBar.backgroundColor = .systemBlue
        view.addSubview(customNavBar)
        
        // 使用 SnapKit 設置 customNavBar 的約束
        customNavBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(60)
        }
        
        // 創建返回按鈕
        let backButton = UIButton(type: .system)
        backButton.setTitle("Back", for: .normal)
        backButton.setTitleColor(.white, for: .normal)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        customNavBar.addSubview(backButton)
        
        // 設置返回按鈕的約束
        backButton.snp.makeConstraints { make in
            make.leading.equalTo(customNavBar.snp.leading).offset(16)
            make.centerY.equalTo(customNavBar.snp.centerY)
        }
        
        // 創建菜單按鈕
        let menuButton = UIButton(type: .system)
        menuButton.setTitle("Menu", for: .normal)
        menuButton.setTitleColor(.white, for: .normal)
        menuButton.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
        customNavBar.addSubview(menuButton)
        
        // 設置菜單按鈕的約束
        menuButton.snp.makeConstraints { make in
            make.trailing.equalTo(customNavBar.snp.trailing).offset(-16)
            make.centerY.equalTo(customNavBar.snp.centerY)
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
            
            for i in 0..<self.questions.count {
                let indexPath = IndexPath(row: i, section: 0)
                if let cell = self.tableView.cellForRow(at: indexPath) as? QuestionPageCell {
                    if let selectAnswer = self.selectAnswer?[i], selectAnswer == self.questions[i].answerOptions {
                        cell.answerSelectLabel.textColor = .green
                    } else {
                        cell.answerSelectLabel.textColor = .red
                        print(self.questions[i].answer)
                    }
                }
            }
            
            var allAnswers = ""
            for (index, question) in self.questions.enumerated() {
                allAnswers += "問題 \(index + 1): \(question.answer)\n"
            }
            
            let answerAlert = UIAlertController(title: "所有解答", message: allAnswers, preferredStyle: .alert)
            answerAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(answerAlert, animated: true, completion: nil)
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
}
