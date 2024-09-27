//import UIKit
//import SnapKit
//import Firebase
//import Lottie
//
//class ReadingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
//    
//    private var questions: [ReadingType]? = []
//    private let tableView = UITableView()
//    private var answerSelect: String = ""
//    private let urlString = "https://api.openai.com/v1/chat/completions"
//    private var customNavBar: UIView!
//    private let menuButton = UIButton(type: .system)
//    private let animationView = LottieAnimationView(name: "LoadingImage")
//    private var answerArray: [String]?
//    var wordDatas: Accurency?
//    var datadismiss: ((Accurency?) -> Void)? // 定義 closure，用來傳遞資料
//    let cardView = UIView()
//    let questionLabel = UILabel()
//    private var isTapCheck: Bool = false
//    
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .white
//        cardView.isHidden = true
//        setupCustomNavBar()
//        setupTableView()
//        callChatGPTAPI()
//    }
//    
//    private func setupTableView() {
//        view.addSubview(tableView)
//        tableView.dataSource = self
//        tableView.delegate = self
//        tableView.separatorStyle = .none
//        tableView.register(ReadingTestCell.self, forCellReuseIdentifier: "ReadingTestCell")
//        tableView.frame = CGRect(x: 0, y: 60, width: view.frame.width, height: view.frame.height - 60)
//        tableView.snp.makeConstraints { make in
//            make.top.equalTo(customNavBar.snp.bottom)
//            make.left.equalTo(view).offset(16)
//            make.right.equalTo(view).offset(-16)
//            make.bottom.equalTo(view.safeAreaLayoutGuide)
//        }
//        
//        animationView.frame = CGRect(x: 0, y: 0, width: 400, height: 400)
//        animationView.center = self.view.center
//        animationView.contentMode = .scaleAspectFit
//        animationView.loopMode = .loop
//        animationView.play()
//        tableView.addSubview(animationView)
//    }
//    
//    private func setupCustomNavBar() {
//        customNavBar = UIView()
//        customNavBar.backgroundColor = .white
//        
//        view.addSubview(customNavBar)
//        
//        customNavBar.snp.makeConstraints { make in
//            make.top.equalTo(view.safeAreaLayoutGuide)
//            make.left.right.equalTo(view)
//            make.height.equalTo(60)
//        }
//        
//        let backButton = UIButton(type: .system)
//        backButton.setImage(UIImage(systemName: "arrowshape.turn.up.backward.2.fill"), for: .normal)
//        backButton.setTitleColor(.white, for: .normal)
//        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
//        customNavBar.addSubview(backButton)
//        
//        backButton.snp.makeConstraints { make in
//            make.leading.equalTo(customNavBar).offset(16)
//            make.centerY.equalTo(customNavBar)
//        }
//        
//        menuButton.isUserInteractionEnabled = false
//        menuButton.alpha = 0.5
//        menuButton.setTitle("...", for: .normal)
//        menuButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .medium)
//        menuButton.setTitleColor(.blue, for: .normal)
//        menuButton.addTarget(self, action: #selector(didTapMenu), for: .touchUpInside)
//        customNavBar.addSubview(menuButton)
//        
//        menuButton.snp.makeConstraints { make in
//            make.right.equalTo(customNavBar).offset(-16)
//            make.centerY.equalTo(customNavBar)
//        }
//        
//    }
//    
//    @objc func backButtonTapped() {
//        self.dismiss(animated: true) {
//            self.datadismiss?(self.wordDatas)
//        }
//    }
//    
//    // MARK: -- doing
//    @objc private func didTapMenu() {
//        let menu = UIAlertController(title: "Options", message: nil, preferredStyle: .actionSheet)
//        let action1 = UIAlertAction(title: "對答案", style: .default) { [weak self] _ in
//            self?.isTapCheck = true
//            
//            self?.tableView.reloadData()
//        }
//        let action2 = UIAlertAction(title: "收藏", style: .default) { [weak self] _ in
//            guard let self = self, let question = self.questions?[0] else { return }
//            self.saveQuestionToFirebase(paragraph: question)
//        }
//        
//        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
//        
//        menu.addAction(action1)
//        menu.addAction(action2)
//        menu.addAction(cancelAction)
//        present(menu, animated: true, completion: nil)
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return (questions?.first?.options.count ?? 0) + 1
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if indexPath.row == 0 {  // 第一個 cell 顯示問題的段落
//            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
//            
//            // 創建一個卡片樣式的 view
//            cardView.backgroundColor = .white
//            cardView.layer.cornerRadius = 10
//            cardView.layer.shadowColor = UIColor.black.cgColor
//            cardView.layer.shadowOpacity = 0.1
//            cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
//            cardView.layer.shadowRadius = 4
//            cell.contentView.addSubview(cardView)
//            
//            // 添加 label 到卡片內
//            questionLabel.text = questions?.first?.readingMessage
//            questionLabel.numberOfLines = 0
//            cardView.addSubview(questionLabel)
//            
//            // 使用 SnapKit 設置卡片的 Auto Layout 約束
//            cardView.snp.makeConstraints { make in
//                make.top.equalTo(cell.contentView.snp.top).offset(10)
//                make.leading.equalTo(cell.contentView.snp.leading).offset(10)
//                make.trailing.equalTo(cell.contentView.snp.trailing).offset(-10)
//                make.bottom.equalTo(cell.contentView.snp.bottom).offset(-10)
//            }
//            
//            // 設置 label 的約束
//            questionLabel.snp.makeConstraints { make in
//                make.top.equalTo(cardView.snp.top).offset(15)
//                make.leading.equalTo(cardView.snp.leading).offset(15)
//                make.trailing.equalTo(cardView.snp.trailing).offset(-15)
//                make.bottom.equalTo(cardView.snp.bottom).offset(-15)
//            }
//            
//            return cell
//        } else {
//            if let cell = tableView.dequeueReusableCell(withIdentifier: "ReadingTestCell", for: indexPath) as? ReadingTestCell {
//                cell.answerSelectLabel.text = "(\(questions?[0].selectNumber[indexPath.row - 1] ?? "()"))"
//                cell.questionLabel.text = questions[0].questions[indexPath.row - 1]
//                cell.optionLabel0.setTitle(questions?[0].options[indexPath.row - 1][0], for: .normal)
//                cell.optionLabel1.setTitle(questions?[0].options[indexPath.row - 1][1], for: .normal)
//                cell.optionLabel2.setTitle(questions?[0].options[indexPath.row - 1][2], for: .normal)
//                cell.optionLabel3.setTitle(questions?[0].options[indexPath.row - 1][3], for: .normal)
//                cell.isUserInteractionEnabled = true
//                cell.optionLabel0.addTarget(self, action: #selector(tapOptions(_:)), for: .touchUpInside)
//                cell.optionLabel1.addTarget(self, action: #selector(tapOptions(_:)), for: .touchUpInside)
//                cell.optionLabel2.addTarget(self, action: #selector(tapOptions(_:)), for: .touchUpInside)
//                cell.optionLabel3.addTarget(self, action: #selector(tapOptions(_:)), for: .touchUpInside)
//                cell.translateButton.tag = indexPath.row
//                cell.translateButton.addTarget(self, action: #selector(translateText), for: .touchUpInside)
//                if isTapCheck {
//                    let selectedAnswer = self.questions?[0].selectNumber[indexPath.row - 1]
//                    let correctAnswer = self.questions?[0].answerOptions[indexPath.row - 1]
//                    cell.translateButton.isHidden = false
//                    cell.optionLabel0.isUserInteractionEnabled = false
//                    cell.optionLabel1.isUserInteractionEnabled = false
//                    cell.optionLabel2.isUserInteractionEnabled = false
//                    cell.optionLabel3.isUserInteractionEnabled = false
//                    //cell.translateButton.isUserInteractionEnabled
//
//                    if selectedAnswer == correctAnswer {
//                        cell.answerSelectLabel.textColor = .green
//                        cell.answerSelectLabel.text = "( \(selectedAnswer ?? "") )"
//                        self.wordDatas?.corrects += 1
//                        
//                    } else {
//                        cell.answerSelectLabel.textColor = .red
//                        cell.answerSelectLabel.text = "( \(selectedAnswer ?? "") )"
//                        self.wordDatas?.wrongs += 1
//                    }
//                    self.wordDatas?.times += 1
//                    self.updateAccurency()
//                    
//                }
//                
//                
//                return cell
//            } else {
//                return UITableViewCell()
//            }
//        }
//    }
//    
//    
//    func saveQuestionToFirebase(paragraph: ReadingType) {
//        // 创建一个可变副本
//        var mutableParagraph = paragraph
//        
//        // 创建一个 UIAlertController 让用户输入名称
//        let alert = UIAlertController(title: "輸入錯題名稱", message: nil, preferredStyle: .alert)
//        alert.addTextField { textField in
//            textField.placeholder = "輸入名稱"
//        }
//        
//        // 添加确认按钮
//        let confirmAction = UIAlertAction(title: "確認", style: .default) { [weak self] _ in
//            if let documentName = alert.textFields?.first?.text, !documentName.isEmpty {
//                let db = Firestore.firestore()
//                mutableParagraph.title = documentName
//                let paragraphData = mutableParagraph.toDictionary()
//                guard let userID = UserDefaults.standard.string(forKey: "userID") else {return}
//                
//                db.collection("PersonAccount")
//                    .document(userID)
//                    .collection("CollectionFolderWrongQuestions")
//                    .document()
//                    .setData(paragraphData) { error in
//                        if let error = error {
//                            print("Error adding document: \(error)")
//                        } else {
//                            print("Document added successfully to CollectionFolderWrongQuestions")
//                            
//                            // 收藏成功后显示提示
//                            let successAlert = UIAlertController(title: "收藏成功", message: "問題已成功被收藏！", preferredStyle: .alert)
//                            successAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//                            self?.present(successAlert, animated: true, completion: nil)
//                        }
//                    }
//            } else {
//                // 如果用户未输入名称，则显示错误提示
//                let errorAlert = UIAlertController(title: "錯誤", message: "請輸入有效名稱！", preferredStyle: .alert)
//                errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//                self?.present(errorAlert, animated: true, completion: nil)
//            }
//        }
//        
//        // 添加取消按钮
//        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
//        
//        alert.addAction(confirmAction)
//        alert.addAction(cancelAction)
//        
//        present(alert, animated: true, completion: nil)
//    }
//    
//    
//    func updateAccurency() {
//        let query = FirestoreEndpoint.fetchAccurencyRecords.ref.document("Paragraph")
//        let fieldsToUpdate: [String: Any] = [
//            "Corrects": wordDatas?.corrects,
//            "Wrongs": wordDatas?.wrongs,
//            "Times": wordDatas?.times,
//            "Title": wordDatas?.title
//        ]
//        
//        FirestoreService.shared.updateData(at: query, with: fieldsToUpdate) { error in
//            if let error = error {
//                print("DEBUG: Failed to update wordData -", error.localizedDescription)
//            } else {
//                print("DEBUG: Successfully updated wordData to \(self.wordDatas)")
//            }
//        }
//    }
//    
//    
//    @objc private func translateText(_ sender: UIButton) {
//        print("aa")
//        let alert = UIAlertController(title: "Answer Text", message: answerArray?[sender.tag - 1], preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//        self.present(alert, animated: true, completion: nil)
//    }
//    
//    // 處理選項選擇
//    @objc func tapOptions(_ sender: UIButton) {
//        guard let cell = sender.superview?.superview as? ParagraphCell else { return }
//        guard let indexPath = tableView.indexPath(for: cell) else { return }
//        switch sender.tag {
//        case 0:
//            answerSelect = "A"
//            questions?[0].selectNumber[indexPath.row - 1] = answerSelect  // 現在 indexPath.row - 1，因為第一個 row 是問題段落
//        case 1:
//            answerSelect = "B"
//            questions?[0].selectNumber[indexPath.row - 1] = answerSelect
//        case 2:
//            answerSelect = "C"
//            questions?[0].selectNumber[indexPath.row - 1] = answerSelect
//        case 3:
//            answerSelect = "D"
//            questions?[0].selectNumber[indexPath.row - 1] = answerSelect
//        default:
//            print("answer error")
//        }
//        tableView.reloadRows(at: [indexPath], with: .none)
//    }
//}
//
//
//
//extension ReadingViewController {
//    private func callChatGPTAPI() {
//        guard let url = URL(string: urlString) else { return }
//        var request = URLRequest(url: url)
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue("Bearer \(ChatGPTAPIKey.key)", forHTTPHeaderField: "Authorization")
//        request.httpMethod = "POST"
//        
//        // 定義 API 請求的 body
//        let openAIBody: [String: Any] = [
//            "model": "gpt-3.5-turbo",
//            "messages": [
//                ["role": "system", "content": "You are a helpful assistant."],
//                ["role": "user", "content": """
//                You are a TOEIC question creator. Please create a TOEIC Reading test question with multiple-choice answers using the following format. Ensure the questions cover various aspects such as verb tenses, vocabulary, and collocations, and that they are suitable for TOEIC 700-level test takers.
//                
//                The format should be as follows:
//                [
//                {
//                    "readingMessage": "The finance team recently completed a comprehensive review of the company’s budget. The goal of this review was to identify any discrepancies and to ensure that the company’s financial statements were accurate and up-to-date. As part of the review, the team analyzed various reports and made several key recommendations for improving the company’s financial performance. One of the major recommendations was to reduce unnecessary expenses in order to increase profitability. Additionally, the team suggested introducing a new accounting software program to streamline financial reporting and improve accuracy. The finance team also emphasized the importance of maintaining organized financial records for future audits, stating that accurate and timely data would be crucial for ensuring compliance with regulations.",
//                    
//                    "questions": [
//                        "What was the primary purpose of the finance team's review of the company’s budget?",
//                        "Which of the following was one of the finance team’s key recommendations?",
//                        "What new software did the finance team suggest introducing?",
//                        "Why did the finance team emphasize maintaining organized financial records?",
//                        "What is one of the expected benefits of introducing the new accounting software?"
//                    ],
//                    
//                    "options": [
//                        ["(A) To suggest new marketing strategies", "(B) To identify any financial discrepancies", "(C) To increase employee productivity", "(D) To propose a new hiring plan"],
//                        ["(A) Increase marketing expenses", "(B) Introduce new management training", "(C) Reduce unnecessary expenses", "(D) Expand the company's global presence"],
//                        ["(A) Customer relationship management software", "(B) Project management software", "(C) Accounting software", "(D) Employee training software"],
//                        ["(A) To avoid paying taxes", "(B) To improve employee efficiency", "(C) To ensure compliance with regulations", "(D) To attract new investors"],
//                        ["(A) Lower employee turnover", "(B) Increased accuracy in financial reporting", "(C) Higher marketing reach", "(D) Improved customer satisfaction"]
//                    ],
//                    
//                    "AnswerOption": ["B", "C", "C", "C", "B"],
//                    
//                    "Answer": [
//                        "1. 'identify any financial discrepancies' 是正確答案，因為文章中提到財務團隊的目的是確保財務報表的準確性。",
//                        "2. 'reduce unnecessary expenses' 是正確答案，因為財務團隊建議減少不必要的開支來提高盈利。",
//                        "3. 'accounting software' 是正確答案，因為文章提到財務團隊建議引入會計軟體以改善報告的準確性。",
//                        "4. 'ensure compliance with regulations' 是正確答案，因為文章中強調了組織化的財務記錄對未來審計和符合法規的重要性。",
//                        "5. 'increased accuracy in financial reporting' 是正確答案，因為引入新會計軟體的目的是提高財務報告的準確性。"
//                    ]
//                }
//                ]
//                Ensure that the questions are of appropriate difficulty for TOEIC 700, including vocabulary, grammar comprehension, and appropriate context. The "AnswerOption" must always be in uppercase letters (A, B, C, D), and explanations should be provided in Chinese to explain why each answer is correct.
//                Return the result in valid JSON format.
//                """]
//            ]
//        ]
//        
//        
//        request.httpBody = try? JSONSerialization.data(withJSONObject: openAIBody)
//        
//        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
//            if let error = error {
//                print("API請求錯誤: \(error)")
//                return
//            }
//            
//            guard let data = data else {
//                print("無效的數據")
//                return
//            }
//            
//            do {
//                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
//                   let choices = json["choices"] as? [[String: Any]],
//                   let firstChoice = choices.first,
//                   let message = firstChoice["message"] as? [String: Any],
//                   let content = message["content"] as? String {
//                    
//                    // 處理 content 中的換行符號和特殊字符
//                    let cleanedContent = content.replacingOccurrences(of: "\\n", with: "")
//                                                .replacingOccurrences(of: "\\", with: "")
//                                                .replacingOccurrences(of: "```", with: "" )
//                                                .replacingOccurrences(of: "json", with: "")
//
//                    
//                    // 將處理過的字串再轉換成 JSON 數據
//                    if let contentData = cleanedContent.data(using: .utf8) {
//                        do {
//                            if let jsonArray = try JSONSerialization.jsonObject(with: contentData, options: []) as? [[String: Any]] {
//                                print(jsonArray)
//                                let parsedQuestions = self?.parseResponse(jsonArray: jsonArray) ?? []
//                                
//                                DispatchQueue.main.async {
//                                    self?.questions = parsedQuestions
//                                    self?.setupTableView()
//                                    self?.tableView.reloadData()
//                                }
//                            }
//                        } catch {
//                            print("解析 content JSON 時發生錯誤: \(error)")
//                        }
//                    }
//                }
//            } catch {
//                print("JSON解析錯誤: \(error)")
//            }
//        }.resume()
//    }
//    
//    private func parseResponse(jsonArray: [[String: Any]]) -> [ReadingType] {
//        var questionsArray: [ReadingType] = []
//        
//        for jsonObject in jsonArray {
//            if let readingMessage = jsonObject["readingMessage"] as? String,
//               let question = jsonObject["questions"] as? [String],
//               let options = jsonObject["options"] as? [[String]],
//               let answerOption = jsonObject["AnswerOption"] as? [String],
//               let answerExplanation = jsonObject["Answer"] as? [String] {
//                
//                // 初始化選擇數組，根據選項的數量來設置
//                let selectNumber = Array(repeating: "", count: options.count)
//                
//                // 創建 ReadingType 物件
//                let readingType = ReadingType(
//                    readingMessage: readingMessage,
//                    questions: question,
//                    options: options,
//                    answerOptions: answerOption,
//                    answer: answerExplanation,
//                    selectNumber: selectNumber
//                )
//                
//                questionsArray.append(readingType)
//            }
//        }
//        print("========")
//        print(questionsArray)
//        print("========")
//        return questionsArray
//    }
//    
//}
//   
//
//struct ReadingType {
//    var readingMessage: String
//    var questions: [String]
//    var options: [[String]]
//    var answerOptions: [String]
//    var answer: [String]
//    var selectNumber: [String]
//    var title: String?
//}
//
//extension ReadingType {
//    func toDictionary() -> [String: Any] {
//        var optionsDict: [String: [String]] = [:]
//        for (index, optionSet) in options.enumerated() {
//            optionsDict["option_set_\(index)"] = optionSet
//        }
//        return [
//            "readingMessage": self.readingMessage,
//            "questions": self.questions,
//            "options": optionsDict,
//            "answerOptions": self.answerOptions,
//            "answer": self.answer,
//            "title": self.title,
//            "tag": "閱讀理解"
//        ]
//    }
//}
