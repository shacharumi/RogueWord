//
//  WrongQuestionParagraphVC.swift
//  RogueWord
//
//  Created by shachar on 2024/9/24.
//

import UIKit
import SnapKit

class WrongQuestionParagraphVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var questions: GetParagraphType?   // 這裡存放傳遞過來的問題數據
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
            
            for i in 0..<(self.questions?.options.count ?? 0) {
                let indexPath = IndexPath(row: i, section: 0)
                if let cell = self.tableView.cellForRow(at: indexPath) as? ParagraphCell {
                    if let selectAnswer = self.selectAnswer?[i], selectAnswer == self.questions?.answerOptions[i] {
                        cell.answerSelectLabel.textColor = .green
                    } else {
                        cell.answerSelectLabel.textColor = .red
                    }
                }
            }
            
            
            
            let answerAlert = UIAlertController(title: "所有解答", message: questions?.answer, preferredStyle: .alert)
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
        tableView.register(ParagraphCell.self, forCellReuseIdentifier: "ParagraphCell")
        
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
        if indexPath.row == 0 {
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            
            // 創建一個卡片樣式的 view
            let cardView = UIView()
            cardView.backgroundColor = .white
            cardView.layer.cornerRadius = 10
            cardView.layer.shadowColor = UIColor.black.cgColor
            cardView.layer.shadowOpacity = 0.1
            cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
            cardView.layer.shadowRadius = 4
            cell.contentView.addSubview(cardView)
            
            // 添加 label 到卡片內
            let questionLabel = UILabel()
            questionLabel.text = questions?.questions
            questionLabel.numberOfLines = 0
            cardView.addSubview(questionLabel)
            
            // 使用 SnapKit 設置卡片的 Auto Layout 約束
            cardView.snp.makeConstraints { make in
                make.top.equalTo(cell.contentView.snp.top).offset(10)
                make.leading.equalTo(cell.contentView.snp.leading).offset(10)
                make.trailing.equalTo(cell.contentView.snp.trailing).offset(-10)
                make.bottom.equalTo(cell.contentView.snp.bottom).offset(-10)
            }
            
            // 設置 label 的約束
            questionLabel.snp.makeConstraints { make in
                make.top.equalTo(cardView.snp.top).offset(15)
                make.leading.equalTo(cardView.snp.leading).offset(15)
                make.trailing.equalTo(cardView.snp.trailing).offset(-15)
                make.bottom.equalTo(cardView.snp.bottom).offset(-15)
            }
            
            return cell
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ParagraphCell", for: indexPath) as? ParagraphCell {
                guard let selectAnswer = self.selectAnswer else { return UITableViewCell() }
                cell.answerSelectLabel.text = "(\(selectAnswer[indexPath.row-1]))"
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
        guard let cell = sender.superview?.superview as? ParagraphCell else { return }
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

