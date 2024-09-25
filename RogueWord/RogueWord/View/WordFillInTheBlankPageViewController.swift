//
//  WordFillInTheBlankPageViewController.swift
//  RogueWord
//
//  Created by shachar on 2024/9/12.
//
import UIKit
import Firebase

class WordFillInTheBlankPageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let urlString = "https://api.openai.com/v1/chat/completions"
    private var questions: [WordFillType] = []
    private let tableView = UITableView()
    private var answerSelect: String = ""
    private var customNavBar: UIView! // 自定義導航欄
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCustomNavBar() // 設置自定義導航欄
        setupTableView()
        callChatGPTAPI()
    }
    
    // 設置自定義導航欄
    private func setupCustomNavBar() {
        // 創建自定義的導航欄視圖
        customNavBar = UIView()
        customNavBar.backgroundColor = .systemBlue // 設置背景顏色
        view.addSubview(customNavBar)
        
        // 設置自定義導航欄的約束
        customNavBar.translatesAutoresizingMaskIntoConstraints = false
        customNavBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        customNavBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        customNavBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        customNavBar.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        // 創建返回按鈕
        let backButton = UIButton(type: .system)
        backButton.setTitle("Back", for: .normal)
        backButton.setTitleColor(.white, for: .normal)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        customNavBar.addSubview(backButton)
        
        // 返回按鈕約束
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.leadingAnchor.constraint(equalTo: customNavBar.leadingAnchor, constant: 16).isActive = true
        backButton.centerYAnchor.constraint(equalTo: customNavBar.centerYAnchor).isActive = true
        
        // 創建菜單按鈕
        let menuButton = UIButton(type: .system)
        menuButton.setTitle("Menu", for: .normal)
        menuButton.setTitleColor(.white, for: .normal)
        menuButton.addTarget(self, action: #selector(answerButtonTapped), for: .touchUpInside) // 將原來的菜單功能綁定到這裡
        customNavBar.addSubview(menuButton)
        
        // 菜單按鈕約束
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        menuButton.trailingAnchor.constraint(equalTo: customNavBar.trailingAnchor, constant: -16).isActive = true
        menuButton.centerYAnchor.constraint(equalTo: customNavBar.centerYAnchor).isActive = true
    }
    
    // 返回按鈕功能
    @objc func backButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(QuestionPageCell.self, forCellReuseIdentifier: "QuestionPageCell")
        
        // 設置 TableView 的約束，考慮到導航欄的高度
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: customNavBar.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionPageCell", for: indexPath) as? QuestionPageCell {
            let question = questions[indexPath.row]
            cell.isUserInteractionEnabled = true
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
    
    @objc private func translateText(_ sender: UIButton) {
        let alert = UIAlertController(title: "Answer Text", message: questions[sender.tag].answer, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func answerButtonTapped() {
        let menu = UIAlertController(title: "Options", message: nil, preferredStyle: .actionSheet)
        let action1 = UIAlertAction(title: "答案", style: .default) { [weak self] _ in
            for i in 0..<(self?.questions.count ?? 0) {
                
                let selectedAnswer = self?.questions[i].selectNumber // 使用使用者選擇的答案
                let correctAnswer = self?.questions[i].answerOptions // 正確答案
                
                let indexPath = IndexPath(row: i, section: 0)
                
                if let cell = self?.tableView.cellForRow(at: indexPath) as? QuestionPageCell {
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
            
            self?.tableView.reloadData()
        }
        let action2 = UIAlertAction(title: "收藏", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            // 創建一個包含所有問題的數據結構
            var allQuestionsData: [[String: Any]] = []
            
            for question in self.questions {
                let questionData: [String: Any] = [
                    "question": question.question,
                    "options": question.options,
                    "answerOptions": question.answerOptions,
                    "answer": question.answer,
                ]
                allQuestionsData.append(questionData)
            }
            
            // 保存到 Firebase，作為一個整體寫入
            self.saveQuestionToFirebase(allQuestionsData: allQuestionsData)
            
            // 顯示收藏完成的提示
            let successAlert = UIAlertController(title: "收藏成功", message: "所有問題已成功被收藏為一個整體！", preferredStyle: .alert)
            successAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(successAlert, animated: true, completion: nil)
        }

        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        menu.addAction(action1)
        menu.addAction(action2)
        menu.addAction(cancelAction)
        present(menu, animated: true, completion: nil)
    }
    
    func saveQuestionToFirebase(allQuestionsData: [[String: Any]]) {
        let alert = UIAlertController(title: "輸入收藏名稱", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "輸入名稱"
        }

        let confirmAction = UIAlertAction(title: "確認", style: .default) { [weak self] _ in
            if let documentName = alert.textFields?.first?.text, !documentName.isEmpty {
                let db = Firestore.firestore()

                // 创建集合数据字典
                let combinedData: [String: Any] = [
                    "questions": allQuestionsData,
                    "title": documentName,
                    "tag": "單字測驗"
                ]
                guard let userID = UserDefaults.standard.string(forKey: "userID") else {return}

                // 保存到 Firebase
                db.collection("PersonAccount")
                    .document(userID)
                    .collection("CollectionFolderWrongQuestions")
                    .document(documentName)  // 用戶輸入的名稱作為 documentID
                    .setData(combinedData) { error in
                        if let error = error {
                            print("Error adding document: \(error)")
                            
                            // 显示错误提示
                            let errorAlert = UIAlertController(title: "錯誤", message: "問題收藏失敗，請重試！", preferredStyle: .alert)
                            errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self?.present(errorAlert, animated: true, completion: nil)
                        } else {
                            print("Document added successfully to CollectionFolderWrongQuestions")
                            
                            // 收藏成功后显示提示
                            let successAlert = UIAlertController(title: "收藏成功", message: "所有問題已成功被收藏！", preferredStyle: .alert)
                            successAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self?.present(successAlert, animated: true, completion: nil)
                        }
                    }
            } else {
                // 如果用户未输入名称，则显示错误提示
                let errorAlert = UIAlertController(title: "錯誤", message: "請輸入有效名稱！", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self?.present(errorAlert, animated: true, completion: nil)
            }
        }

        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)

        alert.addAction(confirmAction)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
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
                        .replacingOccurrences(of: "```", with: "" )
                        .replacingOccurrences(of: "json", with: "")
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
}

struct WordFillType {
    var question: String
    var options: [String]
    var answerOptions: String
    var answer: String
    var selectNumber: String?
}
