//
//  ListeningViewController.swift
//  RogueWord
//
//  Created by shachar on 2024/9/15.
//

import Foundation
import UIKit
import AVFoundation


class ListeningViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private var speechSynthesizer = AVSpeechSynthesizer()
    
    private let urlString = "https://api.openai.com/v1/chat/completions"
    private var questions: [ReadingType] = [] // 解析後的問題列表
    private let tableView = UITableView()
    private var answerSelect: String = ""
    private lazy var rightButton: UIBarButtonItem = {
        let barButton = UIBarButtonItem(title: "Options", style: .plain, target: nil, action: nil)
        
        let action1 = UIAction(title: "答案", image: UIImage(systemName: "star"), handler: { [weak self] _ in
            
            for i in 0..<(self?.questions[0].options.count ?? 0) {
                
                let selectedAnswer = self?.questions[0].selectNumber[i]
                let correctAnswer = self?.questions[0].answerOptions[i]
                
                let indexPath = IndexPath(row: i, section: 0)
                
                if let cell = self?.tableView.cellForRow(at: indexPath) as? ListeningTestCell {
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
            let alert = UIAlertController(title: "Answer Text", message: "\(self.questions[0].answer[0])\n \(self.questions[0].answer[1])\n \(self.questions[0].answer[2])\n", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        })
        let action3 = UIAction(title: "收藏", image: UIImage(systemName: "star"), handler: { _ in
            print("Action 1 selected")
        })
        let menu = UIMenu(title: "", children: [action1, action2, action3])
        barButton.menu = menu
        
        return barButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = rightButton
        callChatGPTAPI() // 呼叫API
    }
    
    // MARK: - 設置 UITableView
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ListeningTestCell.self, forCellReuseIdentifier: "ListeningTestCell")
        tableView.frame = view.bounds
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ListeningTestCell", for: indexPath) as? ListeningTestCell {
            cell.answerSelectLabel.text = "(\(questions[0].selectNumber[indexPath.row]))"
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
            cell.voiceButton.addTarget(self, action: #selector(playCellText(_:)), for: .touchUpInside)
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    // MARK: - TableView Header Methods
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .lightGray
        
        //        let headerLabel = UILabel()
        //        headerLabel.text = questions[0].readingMessage
        //        headerLabel.numberOfLines = 0
        //        headerLabel.frame = CGRect(x: 20, y: 5, width: tableView.frame.width - 40, height: 0)
        //        headerLabel.sizeToFit()
        //        headerView.addSubview(headerLabel)
        
        // 添加語音播放按鈕
        let playButton = UIButton(type: .system)
        playButton.setTitle("Play", for: .normal)
        playButton.frame = CGRect(x: tableView.frame.width - 80, y: 5, width: 60, height: 30)
        playButton.addTarget(self, action: #selector(playText), for: .touchUpInside)
        headerView.addSubview(playButton)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let questionText = questions[0].readingMessage
        let label = UILabel()
        label.numberOfLines = 0
        label.text = questionText
        label.frame = CGRect(x: 20, y: 5, width: tableView.frame.width - 40, height: 0)
        label.sizeToFit()
        return label.frame.height + 10 // 加上一點間隔
    }
    @objc private func playText() {
        let questionText = questions[0].readingMessage
        
        let utterance = AVSpeechUtterance(string: questionText)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US") // 設置語音為美式英文
        speechSynthesizer.speak(utterance)
    }
    
    @objc private func playCellText(_ sender: UIButton) {
        let questionText = questions[0].question[sender.tag]
        
        let utterance = AVSpeechUtterance(string: questionText)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US") // 設置語音為美式英文
        speechSynthesizer.speak(utterance)
    }
    
    // MARK: - 呼叫 ChatGPT API
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
                You are a TOEIC question creator. Please create a TOEIC Listening test question with multiple-choice answers using the following format. Ensure the questions cover various aspects such as verb tenses, vocabulary, and collocations, and that they are suitable for TOEIC 700-level test takers.
                
                The format should be as follows:
                [
                {
                    "listeningMessage": "Man: Hi Sarah, have you finished reviewing the financial report for this quarter? Woman: Yes, I just finished going through it. There are some inconsistencies in the expense tracking section. Man: I thought the same. Do you think we should discuss this with the accounting team before presenting it to the directors? Woman: Absolutely. I also think we should revise the projections for the next quarter based on this data. Man: Good idea. Let’s set up a meeting with them later today to go over everything.",
                        
                        "questions": [
                            "What has the woman recently completed?",
                            "What issue did the woman notice in the financial report?",
                            "What do they plan to do next?"
                        ],
                        
                        "options": [
                            ["(A) Writing a project proposal", "(B) Reviewing a financial report", "(C) Preparing a presentation", "(D) Updating the budget"],
                            ["(A) A drop in revenue", "(B) Incorrect expense tracking", "(C) A rise in employee costs", "(D) Delays in payments"],
                            ["(A) Submit the report to the directors", "(B) Revise the quarterly projections", "(C) Meet with the accounting team", "(D) Discuss the budget with the directors"]
                        ],
                        
                        "AnswerOption": ["B", "B", "C"],
                        
                        "Answer": [
                            "1. 'Reviewing a financial report' 是正確答案，因為對話中女人提到她剛完成了財務報告的審查。",
                            "2. 'Incorrect expense tracking' 是正確答案，因為女人提到報告中有關開支追蹤的部分有不一致的地方。",
                            "3. 'Meet with the accounting team' 是正確答案，因為兩人討論要與會計團隊會面，進一步審查報告。"
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
                    
                    let cleanedContent = content.replacingOccurrences(of: "\\n", with: "").replacingOccurrences(of: "\\", with: "")
                    
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
            if let readingMessage = jsonObject["listeningMessage"] as? String,
               let question = jsonObject["questions"] as? [String],
               let options = jsonObject["options"] as? [[String]],
               let answerOption = jsonObject["AnswerOption"] as? [String],
               let answerExplanation = jsonObject["Answer"] as? [String] {
                
                let selectNumber = Array(repeating: "", count: options.count)
                
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

extension ListeningViewController {
    
    @objc func tapOptions(_ sender: UIButton) {
        guard let cell = sender.superview?.superview as? ListeningTestCell else { return }
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
