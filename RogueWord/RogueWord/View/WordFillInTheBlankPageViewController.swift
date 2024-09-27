//
//  WordFillInTheBlankPageViewController.swift
//  RogueWord
//
//  Created by shachar on 2024/9/12.
//
import UIKit
import Firebase
import SnapKit
import Lottie

class WordFillInTheBlankPageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let urlString = "https://api.openai.com/v1/chat/completions"
    private var questions: [WordFillType] = []
    private let tableView = UITableView()
    private var answerSelect: String = ""
    private var customNavBar: UIView!
    private let animationView = LottieAnimationView(name: "LoadingImage")
    private let menuButton = UIButton(type: .system)
    var wordDatas: Accurency?
    private var isTapCheck: Bool = false
    var datadismiss: ((Accurency?) -> Void)? 

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupCustomNavBar()
        setupTableView()
        callChatGPTAPI()
    }
    
    private func setupCustomNavBar() {
        customNavBar = UIView()
        customNavBar.backgroundColor = .white
        
        view.addSubview(customNavBar)
        
        customNavBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.right.equalTo(view)
            make.height.equalTo(60)
        }
        
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(systemName: "arrowshape.turn.up.backward.2.fill"), for: .normal)
        backButton.setTitleColor(.white, for: .normal)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        customNavBar.addSubview(backButton)
        
        backButton.snp.makeConstraints { make in
            make.leading.equalTo(customNavBar).offset(16)
            make.centerY.equalTo(customNavBar)
        }
        
        menuButton.isUserInteractionEnabled = false
        menuButton.alpha = 0.5
        menuButton.setTitle("...", for: .normal)
        menuButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        menuButton.setTitleColor(.blue, for: .normal)
        menuButton.addTarget(self, action: #selector(answerButtonTapped), for: .touchUpInside)
        customNavBar.addSubview(menuButton)
        
        menuButton.snp.makeConstraints { make in
            make.right.equalTo(customNavBar).offset(-16)
            make.centerY.equalTo(customNavBar)
        }
        
    }
    
    @objc func backButtonTapped() {
        self.dismiss(animated: true) {
            self.datadismiss?(self.wordDatas)
        }
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(QuestionPageCell.self, forCellReuseIdentifier: "QuestionPageCell")
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.snp.makeConstraints { make in
            make.top.equalTo(customNavBar.snp.bottom)
            make.left.equalTo(view).offset(16)
            make.right.equalTo(view).offset(-16)
            make.bottom.equalTo(view)
        }
        
        animationView.frame = CGRect(x: 0, y: 0, width: 400, height: 400)
        animationView.center = self.view.center
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.play()
        tableView.addSubview(animationView)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionPageCell", for: indexPath) as? QuestionPageCell {
            let question = questions[indexPath.row]
            cell.isUserInteractionEnabled = true
            cell.answerSelectLabel.text = "\(indexPath.row + 1). (\(question.selectNumber ?? ""))"
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
            cell.translateButton.isHidden = true

            if isTapCheck {
                let finalQuestion = questions[indexPath.row]
                let selectedAnswer = finalQuestion.selectNumber
                let correctAnswer = finalQuestion.answerOptions
                
                cell.translateButton.isHidden = false
                if selectedAnswer == correctAnswer {
                    cell.answerSelectLabel.textColor = .green
                    cell.answerSelectLabel.text = "( \(selectedAnswer ?? "") )"
                    self.wordDatas?.corrects += 1

                } else {
                    cell.answerSelectLabel.textColor = .red
                    cell.answerSelectLabel.text = "( \(selectedAnswer ?? "") )"
                    self.wordDatas?.wrongs += 1
                }
                self.wordDatas?.times += 1
                self.updateAccurency()

            }
            
            
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
    // MARK: -- Doing
    @objc func answerButtonTapped() {
        let menu = UIAlertController(title: "Options", message: nil, preferredStyle: .actionSheet)
        let action1 = UIAlertAction(title: "對答案", style: .default) { [weak self] _ in
            self?.isTapCheck = true
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
            
            self.saveQuestionToFirebase(allQuestionsData: allQuestionsData)
            
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


    
    func updateAccurency() {
        let query = FirestoreEndpoint.fetchAccurencyRecords.ref.document("Word")
        let fieldsToUpdate: [String: Any] = [
            "Corrects": wordDatas?.corrects,
            "Wrongs": wordDatas?.wrongs,
            "Times": wordDatas?.times,
            "Title": wordDatas?.title
        ]
        
        FirestoreService.shared.updateData(at: query, with: fieldsToUpdate) { error in
            if let error = error {
                print("DEBUG: Failed to update wordData -", error.localizedDescription)
            } else {
                print("DEBUG: Successfully updated wordData to \(self.wordDatas)")
            }
        }
    }
}




extension WordFillInTheBlankPageViewController {
    
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
                   請幫我生成五題多益單字填空，內容難度為多益700多分的題目，不用理會範例題目內容，但請嚴格遵循我以下的Json格式，並且在最後回傳給我Json格式就好，不要有多餘的字，請每次都給出不同問題。
                   
                   The format should be as follows:
                   [
                   {
                     "question": "The company has decided to ___ the launch of its new product due to unforeseen circumstances.",
                     "options": ["(A) proceed", "(B) postpone", "(C) expedite", "(D) cancel"],
                     "AnswerOption": "B",
                     "Answer": "(A) 過程 (B) 拖延 (C) 加速 (D) 取消,根據句中的語境，由於'未預見的情況'，公司應該是推遲產品發布，因此 'postpone' 是正確答案。"
                   },
                   {
                     "question": "The marketing team proposed a new strategy to ___ the company's brand image in the competitive market.",
                     "options": ["(A) enhance", "(B) diminish", "(C) maintain", "(D) neglect"],
                     "AnswerOption": "A",
                     "Answer": "(A) 提升 (B) 減少 (C) 維持 (D) 忽視,在競爭激烈的市場中，市場團隊提出了一個新策略來 '增強' 公司的品牌形象。"
                   },
                   ]
                   請確保有五題

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
                    
                    let cleanedContent = content.replacingOccurrences(of: "\\n", with: "")
                        .replacingOccurrences(of: "\\", with: "")
                        .replacingOccurrences(of: "```", with: "" )
                        .replacingOccurrences(of: "json", with: "")
                    if let contentData = cleanedContent.data(using: .utf8) {
                        do {
                            if let jsonArray = try JSONSerialization.jsonObject(with: contentData, options: []) as? [[String: Any]] {
                                let parsedQuestions = self?.parseResponse(jsonArray: jsonArray) ?? []
                                
                                DispatchQueue.main.async {
                                    self?.menuButton.isUserInteractionEnabled = true
                                    self?.menuButton.alpha = 1
                                    self?.animationView.stop()
                                    self?.animationView.isHidden = true
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

struct Accurency: Decodable {
    var corrects: Int
    var wrongs: Int
    var times: Int
    var title: Int
    
    enum CodingKeys: String, CodingKey {
        case corrects = "Corrects"
        case wrongs = "Wrongs"
        case times = "Times"
        case title = "Title"
    }
}
