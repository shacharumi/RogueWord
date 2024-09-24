//
//  WrongQuestionReadingVC.swift
//  RogueWord
//
//  Created by shachar on 2024/9/24.
//

import UIKit
import SnapKit

class WrongQuestionReadingVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var questions: GetReadingType?   // 這裡存放傳遞過來的問題數據
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

            // 确保 `questions` 和 `selectAnswer` 是非空的
            guard let questions = self.questions, let selectAnswer = self.selectAnswer else {
                return
            }
            let answerOptions = questions.answerOptions
            // 遍历所有问题的选项
            for i in 0..<answerOptions.count {
                let indexPath = IndexPath(row: i+1, section: 0)  // +1 因为第一个 cell 是 readingMessage
                
                if let cell = self.tableView.cellForRow(at: indexPath) as? ReadingTestCell {
                    // 检查用户的选择是否正确，并设置颜色
                    if selectAnswer[i] == answerOptions[i] {
                        cell.answerSelectLabel.textColor = .green
                    } else {
                        cell.answerSelectLabel.textColor = .red
                    }
                }
            }

            let totalMessage = "\(questions.answer[0])\n \(questions.answer[1])\n \(questions.answer[2])\n \(questions.answer[3])\n \(questions.answer[4])\n"
            let answerAlert = UIAlertController(title: "所有解答", message: totalMessage, preferredStyle: .alert)
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
        tableView.register(ReadingTestCell.self, forCellReuseIdentifier: "ReadingTestCell")
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(customNavBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        if var answerOptionsCount = questions?.options.count {
            answerOptionsCount += 1
            selectAnswer = Array(repeating: "", count: answerOptionsCount)
        } else {
            print("questions or answerOptions is nil")
            // 可以选择处理nil的情况，或者初始化一个默认值
            selectAnswer = []
        }
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (questions?.options.count ?? 0) + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {  // 第一个 cell 显示 readingMessage，并带有卡片样式
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.selectionStyle = .none

            let cardView = UIView()
            cardView.backgroundColor = .white
            cardView.layer.cornerRadius = 10
            cardView.layer.shadowColor = UIColor.black.cgColor
            cardView.layer.shadowOpacity = 0.1
            cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
            cardView.layer.shadowRadius = 4
            cell.contentView.addSubview(cardView)

            let messageLabel = UILabel()
            messageLabel.text = questions?.readingMessage
            messageLabel.numberOfLines = 0
            cardView.addSubview(messageLabel)

            // 使用 SnapKit 设置卡片样式
            cardView.snp.makeConstraints { make in
                make.edges.equalTo(cell.contentView).inset(10)
            }

            messageLabel.snp.makeConstraints { make in
                make.edges.equalTo(cardView).inset(10)
            }

            return cell
        } else {  // 其他 cell 显示选项
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ReadingTestCell", for: indexPath) as? ReadingTestCell {
                guard let selectAnswer = self.selectAnswer else { return UITableViewCell() }
                cell.answerSelectLabel.text = "(\(selectAnswer[indexPath.row-1]))"
                cell.questionLabel.text = questions?.questions[indexPath.row-1]
                cell.optionLabel0.setTitle(questions?.options["option_set_\(indexPath.row-1)"]?[0], for: .normal)
                cell.optionLabel1.setTitle(questions?.options["option_set_\(indexPath.row-1)"]?[1], for: .normal)
                cell.optionLabel2.setTitle(questions?.options["option_set_\(indexPath.row-1)"]?[2], for: .normal)
                cell.optionLabel3.setTitle(questions?.options["option_set_\(indexPath.row-1)"]?[3], for: .normal)
                cell.backgroundColor = .yellow
                cell.isUserInteractionEnabled = true
                cell.optionLabel0.addTarget(self, action: #selector(tapOptions(_:)), for: .touchUpInside)
                cell.optionLabel1.addTarget(self, action: #selector(tapOptions(_:)), for: .touchUpInside)
                cell.optionLabel2.addTarget(self, action: #selector(tapOptions(_:)), for: .touchUpInside)
                cell.optionLabel3.addTarget(self, action: #selector(tapOptions(_:)), for: .touchUpInside)
                
                return cell
            } else {
                return UITableViewCell()
            }
        }
    }
    
    @objc func tapOptions(_ sender: UIButton) {
        guard let cell = sender.superview?.superview as? ReadingTestCell else { return }
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        switch sender.tag {
        case 0 :
            selectAnswer?[indexPath.row-1] = "A"
        case 1 :
            selectAnswer?[indexPath.row-1] = "B"
        case 2 :
            selectAnswer?[indexPath.row-1] = "C"
        case 3 :
            selectAnswer?[indexPath.row-1] = "D"
        default:
            print("Option error")
        }
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}

