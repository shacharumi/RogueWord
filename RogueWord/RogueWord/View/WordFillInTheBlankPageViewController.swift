//
//  WordFillInTheBlankPageViewController.swift
//  RogueWord
//
//  Created by shachar on 2024/9/12.
//

import UIKit

class WordFillInTheBlankPageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let urlString = "https://api.openai.com/v1/chat/completions"
    private var questions: [WordFillType] = []
    private let tableView = UITableView()
    private var answerSelect: String = ""
    private var answerButton: UIBarButtonItem?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
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
            cell.answerSelectLabel.text = "(\(question.selectNumber ?? ""))"
            cell.questionLabel.text = question.question
            cell.optionLabel0.setTitle(question.options[0], for: .normal)
            cell.optionLabel1.setTitle(question.options[1], for: .normal)
            cell.optionLabel2.setTitle(question.options[2], for: .normal)
            cell.optionLabel3.setTitle(question.options[3], for: .normal)
            cell.answerLabel.text = question.selectNumber
            cell.optionLabel0.addTarget(self, action: #selector(tapOptions(_:)), for: .touchUpInside)
            cell.optionLabel1.addTarget(self, action: #selector(tapOptions(_:)), for: .touchUpInside)
            cell.optionLabel2.addTarget(self, action: #selector(tapOptions(_:)), for: .touchUpInside)
            cell.optionLabel3.addTarget(self, action: #selector(tapOptions(_:)), for: .touchUpInside)
            cell.translateButton.addTarget(self, action: #selector(translateText), for: .touchUpInside)
            cell.translateButton.tag = indexPath.row
            return cell
        } else {
            return UITableViewCell()
        }
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    private func callChatGPTAPI() {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else { return }

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(ChatGPTAPIKey.key)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        
        let openAIBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "system", "content": "You are a helpful assistant."],
                ["role": "user", "content": """
                
                Please generate five TOEIC English vocabulary fill-in-the-blank questions with multiple-choice answers suitable for a TOEIC score of 700. The questions should be moderately challenging, using more advanced vocabulary and grammar structures.
                
                The format should be as follows:
                [
                {
                  "question": "The company has decided to ___ the launch of its new product due to unforeseen circumstances.",
                  "options": ["(A) proceed", "(B) postpone", "(C) expedite", "(D) cancel"],
                  "AnswerOption": "B",
                  "Answer": "根據句中的語境，由於'未預見的情況'，公司應該是推遲產品發布，因此 'postpone' 是正確答案。"
                },
                {
                  "question": "The marketing team proposed a new strategy to ___ the company's brand image in the competitive market.",
                  "options": ["(A) enhance", "(B) diminish", "(C) maintain", "(D) neglect"],
                  "AnswerOption": "A",
                  "Answer": "在競爭激烈的市場中，市場團隊提出了一個新策略來 '增強' 公司的品牌形象。"
                }
                ]
                
                Ensure that the questions are of appropriate difficulty for TOEIC 700, including context that challenges vocabulary and grammar comprehension. Please provide answers in Chinese explaining the reason for the correct answer. Also, ensure that the "AnswerOption" is always provided in uppercase letters (A, B, C, D).

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
                    
                    // 1. 先處理 content 中的換行符號和特殊字符
                    let cleanedContent = content.replacingOccurrences(of: "\\n", with: "")
                                                .replacingOccurrences(of: "\\", with: "")
                    
                    // 2. 將處理過的字串再轉換成 JSON 數據
                    if let contentData = cleanedContent.data(using: .utf8) {
                        do {
                            if let jsonArray = try JSONSerialization.jsonObject(with: contentData, options: []) as? [[String: Any]] {
                                // 解析得到問題列表
                                let parsedQuestions = self?.parseResponse(jsonArray: jsonArray) ?? []
                                
                                // 更新 UI
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
    
    private func parseResponse(jsonArray: [[String: Any]]) -> [WordFillType] {
        var questionsArray: [WordFillType] = []
        
        for jsonObject in jsonArray {
            if let question = jsonObject["question"] as? String,
               let options = jsonObject["options"] as? [String],
               let answerOption = jsonObject["AnswerOption"] as? String,
               let answerExplanation = jsonObject["Answer"] as? String {
                
                let wordFillType = WordFillType(
                    question: question,
                    options: options,
                    answerOptions: answerOption,
                    answer: answerExplanation
                )
                
                questionsArray.append(wordFillType)
            }
        }
        
        return questionsArray
    }

    
    
    @objc func tapOptions(_ sender: UIButton) {
        guard let cell = sender.superview?.superview as? QuestionPageCell else { return }
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        switch sender.tag {
        case 0:
            answerSelect = "A"
            questions[indexPath.row].selectNumber = answerSelect

        case 1:
            answerSelect = "B"
            questions[indexPath.row].selectNumber = answerSelect

        case 2:
            answerSelect = "C"
            questions[indexPath.row].selectNumber = answerSelect

        case 3:
            answerSelect = "D"
            questions[indexPath.row].selectNumber = answerSelect

        default:
            print("answer error")
        }
        
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
}

extension WordFillInTheBlankPageViewController {
    func setupView() {
        answerButton = UIBarButtonItem(title: "解答", style: .plain, target: self, action: #selector(answerButtonTapped))
        self.navigationItem.rightBarButtonItem = answerButton
        
    }
    
    @objc func answerButtonTapped() {
        for i in 0..<questions.count {
            
            let selectedAnswer = questions[i].selectNumber // 使用使用者選擇的答案
            let correctAnswer = questions[i].answerOptions // 正確答案
            
            let indexPath = IndexPath(row: i, section: 0)
            
            if let cell = tableView.cellForRow(at: indexPath) as? QuestionPageCell {
                // 判斷使用者選擇的答案是否正確
                if selectedAnswer == correctAnswer {
                    cell.answerSelectLabel.textColor = .green
                    cell.answerSelectLabel.text = "( \(selectedAnswer ?? "") )"
                } else {
                    cell.answerSelectLabel.textColor = .red
                    cell.answerSelectLabel.text = "( \(selectedAnswer ?? "") )"
                }
            }
        }
        
        tableView.reloadData()
    }

    
    
    @objc private func translateText(_ sender: UIButton) {
        let alert = UIAlertController(title: "Answer Text", message: questions[sender.tag].answer, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}



struct WordFillType {
    var question: String
    var options: [String]
    var answerOptions: String
    var answer: String
    var selectNumber: String?
}
