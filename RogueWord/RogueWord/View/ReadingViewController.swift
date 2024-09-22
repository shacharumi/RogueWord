//
//  ReadingViewController.swift
//  RogueWord
//
//  Created by shachar on 2024/9/15.
//
import UIKit
import SnapKit
import Firebase

class ReadingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let urlString = "https://api.openai.com/v1/chat/completions"
    private var questions: [ReadingType] = []
    private let tableView = UITableView()
    private var answerSelect: String = ""

    // 自定义的 headerView
    private lazy var headerView: UIView = {
        let header = UIView()
        header.backgroundColor = .lightGray
        
        // Back 按钮
        let backButton = UIButton(type: .system)
        backButton.setTitle("Back", for: .normal)
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        header.addSubview(backButton)
        
        // Options 按钮
        let optionsButton = UIButton(type: .system)
        optionsButton.setTitle("Options", for: .normal)
        optionsButton.addTarget(self, action: #selector(didTapOptions), for: .touchUpInside)
        header.addSubview(optionsButton)
        
        // 使用 SnapKit 布局
        backButton.snp.makeConstraints { make in
            make.leading.equalTo(header).offset(16)
            make.centerY.equalTo(header)
        }
        
        optionsButton.snp.makeConstraints { make in
            make.trailing.equalTo(header).offset(-16)
            make.centerY.equalTo(header)
        }

        return header
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 添加自定义 headerView
        view.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalTo(view)
            make.height.equalTo(60)
        }

        // 添加 tableView
        setupTableView()
        callChatGPTAPI()
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ReadingTestCell.self, forCellReuseIdentifier: "ReadingTestCell")
        
        // 设置 tableView 的约束，确保它位于 headerView 下面
        tableView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.trailing.bottom.equalTo(view)
        }
    }

    // 返回按钮
    @objc private func didTapBack() {
        dismiss(animated: true, completion: nil)
    }

    // Options 按钮的选项
    @objc private func didTapOptions() {
        let menu = UIAlertController(title: "Options", message: nil, preferredStyle: .actionSheet)

        let action1 = UIAlertAction(title: "答案", style: .default) { [weak self] _ in
            for i in 0..<(self?.questions[0].options.count ?? 0) {
                let selectedAnswer = self?.questions[0].selectNumber[i]
                let correctAnswer = self?.questions[0].answerOptions[i]
                let indexPath = IndexPath(row: i, section: 0)

                if let cell = self?.tableView.cellForRow(at: indexPath) as? ReadingTestCell {
                    if selectedAnswer == correctAnswer {
                        cell.answerSelectLabel.textColor = .green
                    } else {
                        cell.answerSelectLabel.textColor = .red
                    }
                }
            }
            self?.tableView.reloadData()
        }

        let action2 = UIAlertAction(title: "解答", style: .default) { [weak self] _ in
            let alert = UIAlertController(
                title: "Answer Text",
                message: "\(self?.questions[0].answer[0] ?? "")\n \(self?.questions[0].answer[1] ?? "")\n \(self?.questions[0].answer[2] ?? "")\n \(self?.questions[0].answer[3] ?? "")\n \(self?.questions[0].answer[4] ?? "")",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self?.present(alert, animated: true, completion: nil)
        }

        let action3 = UIAlertAction(title: "收藏", style: .default) { [weak self] _ in
            guard let self = self, let question = self.questions.first else { return }
            self.saveQuestionToFirebase(reading: question)
        }

        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        menu.addAction(action1)
        menu.addAction(action2)
        menu.addAction(action3)
        menu.addAction(cancelAction)

        present(menu, animated: true, completion: nil)
    }

    // 设置每个 section 的行数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions.first?.options.count ?? 0 + 1 // +1 是为了显示第一个 question 段落
    }

    // 设置 cell 的内容
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
            messageLabel.text = questions.first?.readingMessage
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
                cell.answerSelectLabel.text = "(\(questions[0].selectNumber[indexPath.row - 1]))"
                cell.questionLabel.text = questions[0].question[indexPath.row - 1]
                cell.optionLabel0.setTitle(questions[0].options[indexPath.row - 1][0], for: .normal)
                cell.optionLabel1.setTitle(questions[0].options[indexPath.row - 1][1], for: .normal)
                cell.optionLabel2.setTitle(questions[0].options[indexPath.row - 1][2], for: .normal)
                cell.optionLabel3.setTitle(questions[0].options[indexPath.row - 1][3], for: .normal)

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

    // 处理选项点击
    @objc func tapOptions(_ sender: UIButton) {
        guard let cell = sender.superview?.superview as? ReadingTestCell else { return }
        guard let indexPath = tableView.indexPath(for: cell) else { return }

        switch sender.tag {
        case 0: answerSelect = "A"
        case 1: answerSelect = "B"
        case 2: answerSelect = "C"
        case 3: answerSelect = "D"
        default: print("answer error")
        }

        questions[0].selectNumber[indexPath.row - 1] = answerSelect
        tableView.reloadRows(at: [indexPath], with: .none)
    }

    // 保存问题到 Firebase
    private func saveQuestionToFirebase(reading: ReadingType) {
        // 創建一個 UIAlertController 讓用戶輸入名稱
        let alert = UIAlertController(title: "輸入收藏名稱", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "輸入名稱"
        }
        
        // 添加確認按鈕
        let confirmAction = UIAlertAction(title: "確認", style: .default) { [weak self] _ in
            // 獲取用戶輸入的名稱
            if let documentName = alert.textFields?.first?.text, !documentName.isEmpty {
                let db = Firestore.firestore()
                
                let readingData = reading.toDictionary()

                // 使用用戶輸入的名稱作為 documentID
                db.collection("PersonAccount")
                    .document(account) 
                    .collection("CollectionFolderReadingQuestions")
                    .document(documentName)
                    .setData(readingData) { error in
                        if let error = error {
                            print("Error adding document: \(error)")
                        } else {
                            print("Document added successfully to CollectionFolderWrongQuestions")
                            
                            // 收藏成功後顯示提示
                            let successAlert = UIAlertController(title: "收藏成功", message: "問題已成功收藏！", preferredStyle: .alert)
                            successAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self?.present(successAlert, animated: true, completion: nil)
                        }
                    }
            } else {
                // 如果用戶未輸入名稱，則顯示錯誤提示
                let errorAlert = UIAlertController(title: "錯誤", message: "請輸入有效的名稱！", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self?.present(errorAlert, animated: true, completion: nil)
            }
        }
        
        // 添加取消按鈕
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        
        // 顯示 alert 給用戶
        present(alert, animated: true, completion: nil)
    }


    // 调用 OpenAI API
     private func callChatGPTAPI() {
         guard let url = URL(string: urlString) else { return }
         var request = URLRequest(url: url)
         request.setValue("application/json", forHTTPHeaderField: "Content-Type")
         request.setValue("Bearer \(ChatGPTAPIKey.key)", forHTTPHeaderField: "Authorization")
         request.httpMethod = "POST"
         
         // 定義 API 請求的 body
         let openAIBody: [String: Any] = [
             "model": "gpt-3.5-turbo",
             "messages": [
                 ["role": "system", "content": "You are a helpful assistant."],
                 ["role": "user", "content": """
                 You are a TOEIC question creator. Please create a TOEIC Reading test question with multiple-choice answers using the following format. Ensure the questions cover various aspects such as verb tenses, vocabulary, and collocations, and that they are suitable for TOEIC 700-level test takers.
                 
                 The format should be as follows:
                 [
                 {
                     "readingMessage": "The finance team recently completed a comprehensive review of the company’s budget. The goal of this review was to identify any discrepancies and to ensure that the company’s financial statements were accurate and up-to-date. As part of the review, the team analyzed various reports and made several key recommendations for improving the company’s financial performance. One of the major recommendations was to reduce unnecessary expenses in order to increase profitability. Additionally, the team suggested introducing a new accounting software program to streamline financial reporting and improve accuracy. The finance team also emphasized the importance of maintaining organized financial records for future audits, stating that accurate and timely data would be crucial for ensuring compliance with regulations.",
                     
                     "questions": [
                         "What was the primary purpose of the finance team's review of the company’s budget?",
                         "Which of the following was one of the finance team’s key recommendations?",
                         "What new software did the finance team suggest introducing?",
                         "Why did the finance team emphasize maintaining organized financial records?",
                         "What is one of the expected benefits of introducing the new accounting software?"
                     ],
                     
                     "options": [
                         ["(A) To suggest new marketing strategies", "(B) To identify any financial discrepancies", "(C) To increase employee productivity", "(D) To propose a new hiring plan"],
                         ["(A) Increase marketing expenses", "(B) Introduce new management training", "(C) Reduce unnecessary expenses", "(D) Expand the company's global presence"],
                         ["(A) Customer relationship management software", "(B) Project management software", "(C) Accounting software", "(D) Employee training software"],
                         ["(A) To avoid paying taxes", "(B) To improve employee efficiency", "(C) To ensure compliance with regulations", "(D) To attract new investors"],
                         ["(A) Lower employee turnover", "(B) Increased accuracy in financial reporting", "(C) Higher marketing reach", "(D) Improved customer satisfaction"]
                     ],
                     
                     "AnswerOption": ["B", "C", "C", "C", "B"],
                     
                     "Answer": [
                         "1. 'identify any financial discrepancies' 是正確答案，因為文章中提到財務團隊的目的是確保財務報表的準確性。",
                         "2. 'reduce unnecessary expenses' 是正確答案，因為財務團隊建議減少不必要的開支來提高盈利。",
                         "3. 'accounting software' 是正確答案，因為文章提到財務團隊建議引入會計軟體以改善報告的準確性。",
                         "4. 'ensure compliance with regulations' 是正確答案，因為文章中強調了組織化的財務記錄對未來審計和符合法規的重要性。",
                         "5. 'increased accuracy in financial reporting' 是正確答案，因為引入新會計軟體的目的是提高財務報告的準確性。"
                     ]
                 }
                 ]
                 Ensure that the questions are of appropriate difficulty for TOEIC 700, including vocabulary, grammar comprehension, and appropriate context. The "AnswerOption" must always be in uppercase letters (A, B, C, D), and explanations should be provided in Chinese to explain why each answer is correct.
                 Return the result in valid JSON format.
                 """]
             ]
         ]
         
         
         request.httpBody = try? JSONSerialization.data(withJSONObject: openAIBody)
         
         URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
             if let error = error {
                 print("API請求錯誤: \(error)")
                 return
             }
             
             guard let data = data else {
                 print("無效的數據")
                 return
             }
             
             do {
                 if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                    let choices = json["choices"] as? [[String: Any]],
                    let firstChoice = choices.first,
                    let message = firstChoice["message"] as? [String: Any],
                    let content = message["content"] as? String {
                     
                     // 處理 content 中的換行符號和特殊字符
                     let cleanedContent = content.replacingOccurrences(of: "\\n", with: "")
                                                 .replacingOccurrences(of: "\\", with: "")
                                                 .replacingOccurrences(of: "```", with: "" )
                                                 .replacingOccurrences(of: "json", with: "")

                     
                     // 將處理過的字串再轉換成 JSON 數據
                     if let contentData = cleanedContent.data(using: .utf8) {
                         do {
                             if let jsonArray = try JSONSerialization.jsonObject(with: contentData, options: []) as? [[String: Any]] {
                                 print(jsonArray)
                                 let parsedQuestions = self?.parseResponse(jsonArray: jsonArray) ?? []
                                 
                                 DispatchQueue.main.async {
                                     self?.questions = parsedQuestions
                                     self?.setupTableView()
                                     self?.tableView.reloadData()
                                 }
                             }
                         } catch {
                             print("解析 content JSON 時發生錯誤: \(error)")
                         }
                     }
                 }
             } catch {
                 print("JSON解析錯誤: \(error)")
             }
         }.resume()
     }
     
     private func parseResponse(jsonArray: [[String: Any]]) -> [ReadingType] {
         var questionsArray: [ReadingType] = []
         
         for jsonObject in jsonArray {
             if let readingMessage = jsonObject["readingMessage"] as? String,
                let question = jsonObject["questions"] as? [String],
                let options = jsonObject["options"] as? [[String]],
                let answerOption = jsonObject["AnswerOption"] as? [String],
                let answerExplanation = jsonObject["Answer"] as? [String] {
                 
                 // 初始化選擇數組，根據選項的數量來設置
                 let selectNumber = Array(repeating: "", count: options.count)
                 
                 // 創建 ReadingType 物件
                 let readingType = ReadingType(
                     readingMessage: readingMessage,
                     question: question,
                     options: options,
                     answerOptions: answerOption,
                     answer: answerExplanation,
                     selectNumber: selectNumber
                 )
                 
                 questionsArray.append(readingType)
             }
         }
         print("========")
         print(questionsArray)
         print("========")
         return questionsArray
     }
     
 }


extension ReadingType {
    func toDictionary() -> [String: Any] {
        var optionsDict: [String: [String]] = [:]
        for (index, optionSet) in options.enumerated() {
            optionsDict["option_set_\(index)"] = optionSet
        }
        return [
            "readingMessage": self.readingMessage,
            "questions": self.question,
            "options": optionsDict,
            "answerOptions": self.answerOptions,
            "answer": self.answer,
            "Tag": "閱讀理解"
        ]
    }
}

struct ReadingType {
    var readingMessage: String
    var question: [String]
    var options: [[String]]
    var answerOptions: [String]
    var answer: [String]
    var selectNumber: [String]
}




   
