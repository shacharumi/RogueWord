//
//  WordFillInTheBlankPageViewController.swift
//  RogueWord
//
//  Created by shachar on 2024/9/12.
//

import UIKit

class WordFillInTheBlankPageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let urlString = "https://api.openai.com/v1/chat/completions"
    private var questions: [Question] = [] // 解析後的問題列表
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
        tableView.register(QuestionPageCell.self, forCellReuseIdentifier: "QuestionPageCell")
        tableView.frame = view.bounds
    }

    // MARK: - TableView DataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionPageCell", for: indexPath) as? QuestionPageCell {
            let question = questions[indexPath.row]
            print(question.options)
            cell.questionLabel.text = question.questionText
            cell.optionLabel0.text = question.options[0]
            cell.optionLabel1.text = question.options[1]
            cell.optionLabel2.text = question.options[2]
            cell.optionLabel3.text = question.options[3]
            cell.answerLabel.text = question.answer
            return cell
        } else {
            return UITableViewCell()
        }
       
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    // MARK: - 呼叫 ChatGPT API
    private func callChatGPTAPI() {

        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(ChatGPTAPIKey.key)", forHTTPHeaderField: "Authorization")
        
        let openAIBody = OpenAIBody(model: AIModel.model, messages: [
            Message(role: "system", content: "You are a helpful assistant."),
            Message(role: "user", content: """
            Please generate three elementary school English vocabulary fill-in-the-blank questions with multiple-choice answers in the following format:

            Format:
            1. I like eat an ___ .
                (a) banana (b) apple (c) grava (d) watermelon
                Answer: (b)

            Provide another similar question using different vocabulary words and answer choices.
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
                print(content)
                // 只解析 content
                let parsedQuestions = self?.parseResponse(content: content) ?? []
                
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

    private func parseResponse(content: String) -> [Question] {
        var questions: [Question] = []
        
        // 分割每個問題塊（已經包含題目、選項、答案的整塊）
        let questionBlocks = content.components(separatedBy: "\n\n")
        
        for block in questionBlocks {
            // 分割每個問題塊中的部分（題目、選項和答案之間使用 \n 分割）
            let lines = block.components(separatedBy: "\n")
            print(lines)
            // 確保至少有三個部分：題目、選項和答案
            if lines.count >= 3 {
                // 提取問題文本
                let questionText = lines[0].trimmingCharacters(in: .whitespacesAndNewlines)
                
                // 解析選項行（第二行為包含所有選項的行）
                let optionsLine = lines[1].trimmingCharacters(in: .whitespacesAndNewlines)
                let components = optionsLine.components(separatedBy: " (")
                let options = components.enumerated().map { index, element in
                    index == 0 ? element : "(\(element)"
                }

                // 解析答案行（假設答案行是最後一行）
                let answerLine = lines[2].trimmingCharacters(in: .whitespacesAndNewlines)
                let answer = answerLine.components(separatedBy: ":").last?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                
                // 創建 Question 物件並添加到列表
                let question = Question(questionText: questionText, options: options, answer: answer)
                questions.append(question)
            }
        }
        
        return questions
    }


}

// MARK: - Question 模型
struct Question {
    let questionText: String
    let options: [String]
    let answer: String
}

// MARK: - API 相關設置
struct ChatGPTAPIKey {
    static let key = "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"
}

struct AIModel {
    static let model = "gpt-3.5-turbo"
}

struct Message: Encodable {
    let role: String
    let content: String
}

struct OpenAIBody: Encodable {
    let model: String
    let messages: [Message]
    let temperature = 0.0
    let max_tokens = 512
    let top_p = 1.0
    let frequency_penalty = 0.0
    let presence_penalty = 0.0
}
