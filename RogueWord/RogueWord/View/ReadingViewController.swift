//
//  ReadingViewController.swift
//  RogueWord
//
//  Created by shachar on 2024/9/15.
//

import Foundation
import UIKit
class ReadingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let urlString = "https://api.openai.com/v1/chat/completions"
    private var questions: [ReadingType] = []
    private let tableView = UITableView()
    private var answerSelect: String = ""
    
    private lazy var rightButton: UIBarButtonItem = {
        let barButton = UIBarButtonItem(title: "Options", style: .plain, target: nil, action: nil)
        
        let action1 = UIAction(title: "答案", image: UIImage(systemName: "star"), handler: { [weak self] _ in
            
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
        })
        
        let action2 = UIAction(title: "解答", image: UIImage(systemName: "star"), handler: { _ in
            let alert = UIAlertController(title: "Answer Text", message: "\(self.questions[0].answer[0])\n \(self.questions[0].answer[1])\n \(self.questions[0].answer[2])\n \(self.questions[0].answer[3])\n \(self.questions[0].answer[4])\n ", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        })
        let action3 = UIAction(title: "收藏", image: UIImage(systemName: "star"), handler: { _ in
            //?? 寫入資料庫
        })
        let menu = UIMenu(title: "", children: [action1, action2, action3])
        barButton.menu = menu
        
        return barButton
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = rightButton
        callChatGPTAPI()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ReadingTestCell.self, forCellReuseIdentifier: "ReadingTestCell")
        tableView.frame = view.bounds
        
    }
    
    
    
    // 根據問題的選項數量來決定行數
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    
    // 配置每個 row 的內容，顯示選項和對應的答案
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ReadingTestCell", for: indexPath) as? ReadingTestCell {
            cell.answerSelectLabel.text = "(\(questions[0].selectNumber[indexPath.row]))"
            cell.questionLabel.text = questions[0].question[indexPath.row]
            cell.optionLabel0.setTitle(questions[0].options[indexPath.row][0], for: .normal)
            cell.optionLabel1.setTitle(questions[0].options[indexPath.row][1], for: .normal)
            cell.optionLabel2.setTitle(questions[0].options[indexPath.row][2], for: .normal)
            cell.optionLabel3.setTitle(questions[0].options[indexPath.row][3], for: .normal)
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
    
    // 設置 header，顯示問題段落
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .lightGray
        
        let headerLabel = UILabel()
        headerLabel.numberOfLines = 0
        
        // 顯示問題的段落，因為只需顯示第一個問題
        if let question = questions.first?.readingMessage {
            headerLabel.text = question
        }
        
        headerLabel.frame = CGRect(x: 20, y: 5, width: tableView.frame.width - 40, height: 0)
        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)
        
        return headerView
    }
    
    // 設置 header 的高度
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let questionText = questions.first?.readingMessage ?? ""
        let label = UILabel()
        label.numberOfLines = 0
        label.text = questionText
        label.frame = CGRect(x: 20, y: 5, width: tableView.frame.width - 40, height: 0)
        label.sizeToFit()
        return label.frame.height + 10
    }
    
    // 呼叫 OpenAI API
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
                    let cleanedContent = content.replacingOccurrences(of: "\\n", with: "").replacingOccurrences(of: "\\", with: "")

                    
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
extension ReadingViewController {
    
    @objc func tapOptions(_ sender: UIButton) {
        guard let cell = sender.superview?.superview as? ReadingTestCell else { return }
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        switch sender.tag {
        case 0:
            answerSelect = "A"
            questions[0].selectNumber[indexPath.row] = answerSelect

        case 1:
            answerSelect = "B"
            questions[0].selectNumber[indexPath.row] = answerSelect

        case 2:
            answerSelect = "C"
            questions[0].selectNumber[indexPath.row] = answerSelect

        case 3:
            answerSelect = "D"
            questions[0].selectNumber[indexPath.row] = answerSelect

        default:
            print("answer error")
        }
        
        tableView.reloadRows(at: [indexPath], with: .none)
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
