//
//  ParagraphFillInTheBlanksViewController.swift
//  RogueWord
//
//  Created by shachar on 2024/9/15.
//

import Foundation
import UIKit

class ParagraphFillInTheBlanksViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let urlString = "https://api.openai.com/v1/chat/completions"
    private var questions: [ParagraphQuestion] = [] // 解析後的問題列表
    private let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        callChatGPTAPI() // 呼叫API
    }

    // MARK: - 設置 UITableView
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ParagraphCell.self, forCellReuseIdentifier: "ParagraphCell")
        tableView.frame = view.bounds
    }

    // MARK: - TableView DataSource Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return questions.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions[section].options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ParagraphCell", for: indexPath) as? ParagraphCell {
            let question = questions[indexPath.section]
            cell.optionLabel.text = question.options[indexPath.row]
            cell.answerLabel.text = question.answer[indexPath.row]
            return cell
        } else {
            return UITableViewCell()
        }
    }

    // MARK: - TableView Header Methods
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .lightGray
        
        let headerLabel = UILabel()
        headerLabel.text = questions[section].questionText
        headerLabel.numberOfLines = 0
        headerLabel.frame = CGRect(x: 20, y: 5, width: tableView.frame.width - 40, height: 0)
        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)
        
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let questionText = questions[section].questionText
        let label = UILabel()
        label.numberOfLines = 0
        label.text = questionText
        label.frame = CGRect(x: 20, y: 5, width: tableView.frame.width - 40, height: 0)
        label.sizeToFit()
        return label.frame.height + 10 // 加上一點間隔
    }

    // MARK: - 呼叫 ChatGPT API
    private func callChatGPTAPI() {

        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(ChatGPTAPIKey.key)", forHTTPHeaderField: "Authorization")
        
        let openAIBody = OpenAIBody(model: AIModel.model, messages: [
            Message(role: "system", content: "You are a TOEIC question creator."),
            Message(role: "user", content: """
            You are a TOEIC question creator. Please create a TOEIC paragraph fill-in-the-blank question with multiple-choice answers using the following format. Ensure the questions cover various aspects such as verb tenses, vocabulary, and collocations:

            - Write a brief paragraph (about 5 sentences) describing a work-related scenario.
            - Include 5 blanks in the paragraph where key words are missing, which will test grammar, vocabulary, or idiomatic usage.
            - Provide four multiple-choice options (A, B, C, D) for each blank, with only one correct answer.
            - The correct answers should be clear based on the context of the paragraph.

            For example:

            Emily recently joined a large tech company as a project manager. Her role primarily involves coordinating various teams to ensure that all projects are ______ (1) on schedule. Every week, she ______ (2) reports to upper management detailing the progress of ongoing tasks. Emily understands the importance of clear communication, so she always ______ (3) feedback from her team members. This approach helps her ______ (4) any potential issues before they become major problems. In addition to her managerial duties, Emily is also responsible for ______ (5) training sessions for new employees.

            1. (A) completed (B) delayed (C) overlooked (D) started
            2. (A) submits (B) cancels (C) hides (D) avoids
            3. (A) ignores (B) requests (C) dismisses (D) argues
            4. (A) predict (B) cause (C) prevent (D) increase
            5. (A) ignoring (B) leading (C) skipping (D) organizing

            Answer: 1. (A), 2. (A), 3. (B), 4. (C), 5. (D)

            Now, please generate a new question in this format.

            """)
        ])

        request.httpBody = try? JSONEncoder().encode(openAIBody)
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let choices = json["choices"] as? [[String: Any]],
               let firstChoice = choices.first,
               let message = firstChoice["message"] as? [String: Any],
               let content = message["content"] as? String {
                // 只解析 content
                let parsedQuestions = self?.parseResponse(content: content) ?? []
                print(json)

                // 更新數據源並刷新 tableView
                DispatchQueue.main.async {
                    self?.questions = parsedQuestions
                    self?.setupTableView()
                    self?.tableView.reloadData()
                }
            }
        }.resume()
    }


    // MARK: - 解析 ChatGPT 回應的問題
    private func parseResponse(content: String) -> [ParagraphQuestion] {
        var questions: [ParagraphQuestion] = []
        
        // 分割問題、選項和答案塊
        let questionBlocks = content.components(separatedBy: "\n\n")
        
        // 確保有三個部分：問題段落，選項，答案
        if questionBlocks.count == 3 {
            // 第1塊是題目段落
            let questionText = questionBlocks[0].trimmingCharacters(in: .whitespacesAndNewlines)
            
            // 第2塊是選項，逐行拆分選項
            let optionsBlock = questionBlocks[1].components(separatedBy: "\n").filter { !$0.isEmpty }
            var options: [String] = []
            
            // 處理選項的行
            for optionLine in optionsBlock {
                let trimmedOption = optionLine.trimmingCharacters(in: .whitespacesAndNewlines)
                options.append(trimmedOption)
            }
            
            // 第3塊是答案，解析格式如：Answer: 1. (A), 2. (A), 3. (B), 4. (A), 5. (A)
            let answerBlock = questionBlocks[2].trimmingCharacters(in: .whitespacesAndNewlines)
            var answers: [String] = []
            if let answerLine = answerBlock.components(separatedBy: ":").last {
                // 解析每個答案，格式假設如：1. (A), 2. (A), 3. (B), 4. (A), 5. (A)
                let answerComponents = answerLine.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                answers.append(contentsOf: answerComponents)
            }
            
            // 將問題、選項和答案組成一個 ParagraphQuestion 物件
            let paragraphQuestion = ParagraphQuestion(questionText: questionText, options: options, answer: answers)
            questions.append(paragraphQuestion)
        }
        
        return questions
    }

}

// MARK: - Question 模型
struct ParagraphQuestion {
    let questionText: String
    let options: [String]
    let answer: [String]
}
