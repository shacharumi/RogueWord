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
        
        // 添加語音播放按鈕
        let playButton = UIButton(type: .system)
        playButton.setTitle("Play", for: .normal)
        playButton.frame = CGRect(x: tableView.frame.width - 80, y: 5, width: 60, height: 30)
        playButton.tag = section // 設置按鈕的 tag 為 section 的索引
        playButton.addTarget(self, action: #selector(playText(_:)), for: .touchUpInside)
        headerView.addSubview(playButton)
        
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
    @objc private func playText(_ sender: UIButton) {
        let section = sender.tag
        let questionText = questions[section].questionText
        
        let utterance = AVSpeechUtterance(string: questionText)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US") // 設置語音為美式英文
        speechSynthesizer.speak(utterance)
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
            
            You are a TOEIC question creator. Please create a TOEIC reading comprehension question that follows the structure below:

            --Write a brief paragraph (about 5 sentences).
            After the paragraph, create 5 comprehension questions based on the content. The questions should test a range of skills such as understanding of vocabulary, verb tenses, collocations, and main ideas.
            Format each question and the multiple-choice answers as follows:
            Question: 1. What has contributed to the increasing popularity of online shopping? (A) Limited product options (B) Inconvenient payment methods (C) Accessibility and convenience (D) High shipping costs\n
            Ensure that all questions follow the same format, with one space between the question text and the answer options, and no newline after each option.
            --For each question, provide four multiple-choice options (A, B, C, D), with only one correct answer.
            --Ensure that the correct answers can be clearly identified based on the context of the paragraph.

            For example:
                        
            Starting next month, our company will implement a new remote work policy. Employees will be allowed to work from home up to two days a week, provided that they maintain regular communication with their team leaders. This change comes in response to the increasing demand for flexibility and the company's goal to improve employee satisfaction.To ensure that the transition is smooth, all team leaders will hold weekly virtual meetings to discuss progress and address any concerns. Employees are expected to attend these meetings and provide updates on their work. If you wish to work from home, please notify your supervisor at least one week in advance.Additionally, the IT department will offer technical support for those who need assistance with setting up their home offices. All employees working remotely must ensure they have a stable internet connection and access to necessary software.This new policy is designed to provide greater flexibility without sacrificing productivity. If you have any questions or concerns, feel free to contact the HR department.

            1. What is the main purpose of the new policy? (A) To allow employees to take longer vacations (B) To increase work hours for employees (C) To give employees more flexibility in their work schedules (D) To reduce the number of office meetings
            2. How many days a week can employees work from home? (A) One (B) Two (C) Three (D) Four
            3. What must employees do if they want to work from home? (A) Attend a meeting with HR (B) Ask their colleagues for permission (C) Notify their supervisor a week in advance (D) Submit a written report to their manager
            4. Who will provide technical support for remote work? (A) The HR department (B) The IT department (C) The team leaders (D) The company’s CEO
            5. What is required of employees working from home? (A) They must have a stable internet connection (B) They need to submit daily reports (C) They must work overtime (D) They need to travel to the office once a week

            Answer: 1. (C), 2. (B), 3. (C), 4. (B), 5. (A)


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


