//
//  WordFillInTheBlankPageViewController.swift
//  RogueWord
//
//  Created by shachar on 2024/9/12.
//

import UIKit

class WordFillInTheBlankPageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let urlString = "https://api.openai.com/v1/chat/completions"
    private var questions: [Question] = []
    private let tableView = UITableView()
    private var answerSelect: String = ""
    private var answerButton: UIBarButtonItem?
    override func viewDidLoad() {
        super.viewDidLoad()
        callChatGPTAPI()
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(QuestionPageCell.self, forCellReuseIdentifier: "QuestionPageCell")
        tableView.frame = view.bounds
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionPageCell", for: indexPath) as? QuestionPageCell {
            let question = questions[indexPath.row]
            cell.answerSelectLabel.text = "( \(answerSelect) )"
            cell.questionLabel.text = question.questionText
            cell.optionLabel0.setTitle(question.options[0], for: .normal)
            cell.optionLabel1.setTitle(question.options[1], for: .normal)
            cell.optionLabel2.setTitle(question.options[2], for: .normal)
            cell.optionLabel3.setTitle(question.options[3], for: .normal)
            cell.answerLabel.text = question.answer
            cell.optionLabel0.addTarget(self, action: #selector(tapOptions(_:)), for: .touchUpInside)
            cell.optionLabel1.addTarget(self, action: #selector(tapOptions(_:)), for: .touchUpInside)
            cell.optionLabel2.addTarget(self, action: #selector(tapOptions(_:)), for: .touchUpInside)
            cell.optionLabel3.addTarget(self, action: #selector(tapOptions(_:)), for: .touchUpInside)
            
            return cell
        } else {
            return UITableViewCell()
        }
       
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    private func callChatGPTAPI() {

        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(ChatGPTAPIKey.key)", forHTTPHeaderField: "Authorization")
        
        let openAIBody = OpenAIBody(model: AIModel.model, messages: [
            Message(role: "system", content: "You are a helpful assistant."),
            Message(role: "user", content: """
            Please generate Five Toeic English vocabulary fill-in-the-blank questions with multiple-choice answers in the following format:

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
                let parsedQuestions = self?.parseResponse(content: content) ?? []
                
                DispatchQueue.main.async {
                    self?.questions = parsedQuestions
                    self?.setupTableView()
                    self?.tableView.reloadData()
                }
            }
        }.resume()
    }

    private func parseResponse(content: String) -> [Question] {
        var questions: [Question] = []
        
        let questionBlocks = content.components(separatedBy: "\n\n")
        
        for block in questionBlocks {
            let lines = block.components(separatedBy: "\n")
            print(lines)
            if lines.count >= 3 {
                let questionText = lines[0].trimmingCharacters(in: .whitespacesAndNewlines)
                let optionsLine = lines[1].trimmingCharacters(in: .whitespacesAndNewlines)
                let components = optionsLine.components(separatedBy: " (")
                let options = components.enumerated().map { index, element in
                    index == 0 ? element : "(\(element)"
                }
                let answerLine = lines[2].trimmingCharacters(in: .whitespacesAndNewlines)
                let answer = answerLine.components(separatedBy: ":").last?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                let question = Question(questionText: questionText, options: options, answer: answer)
                questions.append(question)
            }
        }
        
        return questions
    }
    
    @objc func tapOptions(_ sender: UIButton) {
        guard let cell = sender.superview?.superview as? QuestionPageCell else { return } // 找到該按鈕所在的 Cell
        guard let indexPath = tableView.indexPath(for: cell) else { return } // 找到該 Cell 的 indexPath
        
        switch sender.tag {
        case 0:
            answerSelect = "A"
        case 1:
            answerSelect = "B"
        case 2:
            answerSelect = "C"
        case 3:
            answerSelect = "D"
        default:
            print("answer error")
        }

        // 更新選擇的答案，並重新載入該行
        questions[indexPath.row].selectedAnswer = answerSelect
        tableView.reloadRows(at: [indexPath], with: .none) // 重新載入這一行，顯示選擇的答案
    }
    @objc func tapAnswer() {
        
    }
}


extension WordFillInTheBlankPageViewController {
    func setupView() {
        answerButton?.title = "解答"
        self.navigationItem.rightBarButtonItem = answerButton
        
        
    }
}
