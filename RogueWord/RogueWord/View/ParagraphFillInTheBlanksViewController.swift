import UIKit
import SnapKit
import Firebase
class ParagraphFillInTheBlanksViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var questions: [ParagraphType]? = []
    private let tableView = UITableView()
    private var answerSelect: String = ""
    private let urlString = "https://api.openai.com/v1/chat/completions"
    // 添加一個自訂義的 headerView，用來包含 Back 和 Menu
    private lazy var headerView: UIView = {
        let header = UIView()
        header.backgroundColor = .lightGray
        
        // Back 按鈕
        let backButton = UIButton(type: .system)
        backButton.setTitle("Back", for: .normal)
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        backButton.frame = CGRect(x: 20, y: 10, width: 100, height: 40)
        header.addSubview(backButton)
        
        // Menu 按鈕
        let menuButton = UIButton(type: .system)
        menuButton.setTitle("Menu", for: .normal)
        menuButton.addTarget(self, action: #selector(didTapMenu), for: .touchUpInside)
        menuButton.frame = CGRect(x: view.frame.width - 120, y: 10, width: 100, height: 40)
        header.addSubview(menuButton)
        
        
        
        return header
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(headerView)  // 添加 headerView
        
        headerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(60)
            make.width.equalTo(view)
        }
        
        callChatGPTAPI()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ParagraphCell.self, forCellReuseIdentifier: "ParagraphCell")
        tableView.frame = CGRect(x: 0, y: 60, width: view.frame.width, height: view.frame.height - 60)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.left.equalTo(view).offset(16)
            make.right.equalTo(view).offset(-16)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
    }
    
    @objc private func didTapBack() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapMenu() {
        let menu = UIAlertController(title: "Options", message: nil, preferredStyle: .actionSheet)
        let action1 = UIAlertAction(title: "答案", style: .default) { [weak self] _ in
            for i in 0..<(self?.questions?[0].options.count ?? 0) {
                let selectedAnswer = self?.questions?[0].selectNumber[i]
                let correctAnswer = self?.questions?[0].answerOptions[i]
                let indexPath = IndexPath(row: i + 1, section: 0)  // 題目現在是第一個 cell，所以選項要加 1
                
                if let cell = self?.tableView.cellForRow(at: indexPath) as? ParagraphCell {
                    if selectedAnswer == correctAnswer {
                        cell.answerSelectLabel.textColor = .green
                    } else {
                        cell.answerSelectLabel.textColor = .red
                    }
                }
            }
            self?.tableView.reloadData()
        }
        let action2 = UIAlertAction(title: "解答", style: .default) { [weak self] _ in
            let alert = UIAlertController(title: "Answer Text", message: self?.questions?[0].answer, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self?.present(alert, animated: true, completion: nil)
        }
        let action3 = UIAlertAction(title: "收藏", style: .default) { [weak self] _ in
            guard let self = self, let question = self.questions?[0] else { return }
            self.saveQuestionToFirebase(paragraph: question)
               }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        menu.addAction(action1)
        menu.addAction(action2)
        menu.addAction(action3)
        menu.addAction(cancelAction)
        present(menu, animated: true, completion: nil)
    }
    
    // tableView DataSource 和 Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (questions?.first?.options.count ?? 0) + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {  // 第一個 cell 顯示問題的段落
                let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
                
                // 創建一個卡片樣式的 view
                let cardView = UIView()
                cardView.backgroundColor = .white
                cardView.layer.cornerRadius = 10
                cardView.layer.shadowColor = UIColor.black.cgColor
                cardView.layer.shadowOpacity = 0.1
                cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
                cardView.layer.shadowRadius = 4
                cell.contentView.addSubview(cardView)

                // 添加 label 到卡片內
                let questionLabel = UILabel()
            questionLabel.text = questions?.first?.question
                questionLabel.numberOfLines = 0
                cardView.addSubview(questionLabel)
                
                // 使用 SnapKit 設置卡片的 Auto Layout 約束
                cardView.snp.makeConstraints { make in
                    make.top.equalTo(cell.contentView.snp.top).offset(10)
                    make.leading.equalTo(cell.contentView.snp.leading).offset(10)
                    make.trailing.equalTo(cell.contentView.snp.trailing).offset(-10)
                    make.bottom.equalTo(cell.contentView.snp.bottom).offset(-10)
                }

                // 設置 label 的約束
                questionLabel.snp.makeConstraints { make in
                    make.top.equalTo(cardView.snp.top).offset(15)
                    make.leading.equalTo(cardView.snp.leading).offset(15)
                    make.trailing.equalTo(cardView.snp.trailing).offset(-15)
                    make.bottom.equalTo(cardView.snp.bottom).offset(-15)
                }
                
                return cell
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ParagraphCell", for: indexPath) as? ParagraphCell {
                cell.answerSelectLabel.text = "(\(questions?[0].selectNumber[indexPath.row - 1] ?? "()"))"
                cell.optionLabel0.setTitle(questions?[0].options[indexPath.row - 1][0], for: .normal)
                cell.optionLabel1.setTitle(questions?[0].options[indexPath.row - 1][1], for: .normal)
                cell.optionLabel2.setTitle(questions?[0].options[indexPath.row - 1][2], for: .normal)
                cell.optionLabel3.setTitle(questions?[0].options[indexPath.row - 1][3], for: .normal)
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
    }
    
    
    func saveQuestionToFirebase(paragraph: ParagraphType) {
        // 创建一个可变副本
        var mutableParagraph = paragraph

        // 创建一个 UIAlertController 让用户输入名称
        let alert = UIAlertController(title: "輸入錯題名稱", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "輸入名稱"
        }

        // 添加确认按钮
        let confirmAction = UIAlertAction(title: "確認", style: .default) { [weak self] _ in
            if let documentName = alert.textFields?.first?.text, !documentName.isEmpty {
                let db = Firestore.firestore()
                mutableParagraph.title = documentName
                let paragraphData = mutableParagraph.toDictionary()

                db.collection("PersonAccount")
                    .document(account)
                    .collection("CollectionFolderWrongQuestions")
                    .document()
                    .setData(paragraphData) { error in
                        if let error = error {
                            print("Error adding document: \(error)")
                        } else {
                            print("Document added successfully to CollectionFolderWrongQuestions")
                            
                            // 收藏成功后显示提示
                            let successAlert = UIAlertController(title: "收藏成功", message: "問題已成功被收藏！", preferredStyle: .alert)
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

        // 添加取消按钮
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)

        alert.addAction(confirmAction)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }


    
    
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
                You are a TOEIC question creator. Please create a TOEIC paragraph fill-in-the-blank question with multiple-choice answers using the following format. Ensure the questions cover various aspects such as verb tenses, vocabulary, and collocations, and that they are suitable for TOEIC 700-level test takers.
                
                The format should be as follows:
                [
                {
                  "question": "The marketing department has been working on a new advertising campaign to ______ (1) the company’s visibility in global markets. The team believes that by ______ (2) innovative strategies, they can ______ (3) a broader customer base. Additionally, the department is considering ______ (4) social media as the primary platform for reaching out to younger audiences, who are known for ______ (5) technology and online communication.",
                  "options": [
                    ["(A) decrease", "(B) increase", "(C) dismiss", "(D) avoid"],
                    ["(A) implementing", "(B) avoiding", "(C) deterring", "(D) undermining"],
                    ["(A) capture", "(B) diminish", "(C) ignore", "(D) remove"],
                    ["(A) utilize", "(B) reject", "(C) halt", "(D) omit"],
                    ["(A) avoiding", "(B) adopting", "(C) simplifying", "(D) distrusting"]
                  ],
                  "AnswerOption": ["B", "A", "A", "A", "B"],
                  "Answer": "1. 'increase' 是正確答案，因為根據語境，行銷部門旨在提高公司的全球市場能見度。2. 'implementing' 意味著採用創新策略，與前述語境吻合。3. 'capture' 指的是獲取更廣泛的客戶群，是根據上下文得出的正確答案。4. 'utilize' 是正確答案，因為這裡指的是利用社交媒體平台來接觸年輕的受眾。5. 'adopting' 是正確答案，因為年輕人以擁抱科技和線上溝通著稱。"
                }
                ]
                
                Ensure that the questions are of appropriate difficulty for TOEIC 700, including vocabulary, grammar comprehension, and appropriate context. The "AnswerOption" must always be in uppercase letters (A, B, C, D), and explanations should be provided in Chinese to explain why each answer is correct.
                
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
                        
                        let cleanedContent = content.replacingOccurrences(of: "\\n", with: "")
                                                    .replacingOccurrences(of: "\\", with: "")
                                                    .replacingOccurrences(of: "```", with: "" )
                                                    .replacingOccurrences(of: "json", with: "")
                        
                        if let contentData = cleanedContent.data(using: .utf8) {
                            do {
                                if let jsonArray = try JSONSerialization.jsonObject(with: contentData, options: []) as? [[String: Any]] {
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
                    self?.callChatGPTAPI()
                }
            }.resume()
        }
        
        private func parseResponse(jsonArray: [[String: Any]]) -> [ParagraphType] {
            var questionsArray: [ParagraphType] = []
            
            for jsonObject in jsonArray {
                if let question = jsonObject["question"] as? String,
                   let options = jsonObject["options"] as? [[String]],
                   let answerOption = jsonObject["AnswerOption"] as? [String],
                   let answerExplanation = jsonObject["Answer"] as? String {
                   let selectNumber = Array(repeating: "", count: options.count)

                    let paragraphType = ParagraphType(
                        question: question,
                        options: options,
                        answerOptions: answerOption,
                        answer: answerExplanation,
                        selectNumber: selectNumber
                    )
                    
                    questionsArray.append(paragraphType)
                }
            }
            print("========")
            print(questionsArray)
            print("========")
            return questionsArray
        }
    
    // 處理選項選擇
    @objc func tapOptions(_ sender: UIButton) {
        guard let cell = sender.superview?.superview as? ParagraphCell else { return }
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        switch sender.tag {
        case 0:
            answerSelect = "A"
            questions?[0].selectNumber[indexPath.row - 1] = answerSelect  // 現在 indexPath.row - 1，因為第一個 row 是問題段落
        case 1:
            answerSelect = "B"
            questions?[0].selectNumber[indexPath.row - 1] = answerSelect
        case 2:
            answerSelect = "C"
            questions?[0].selectNumber[indexPath.row - 1] = answerSelect
        case 3:
            answerSelect = "D"
            questions?[0].selectNumber[indexPath.row - 1] = answerSelect
        default:
            print("answer error")
        }
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}

struct ParagraphType: Decodable {
    var question: String
    var options: [[String]]
    var answerOptions: [String]
    var answer: String
    
    var selectNumber: [String?]
    var title: String?
    var tag: String?
}


extension ParagraphType {
    func toDictionary() -> [String: Any] {
        // 將 options 轉換為字典，每組選項用 key 表示
        var optionsDict: [String: [String]] = [:]
        for (index, optionSet) in options.enumerated() {
            optionsDict["option_set_\(index)"] = optionSet
        }
        
        return [
            "questions": self.question,
            "options": optionsDict,  // 使用字典來取代二維陣列
            "answerOptions": self.answerOptions,
            "answer": self.answer,
            "title": self.title,
            "tag": "段落填空"
        ]
    }
}

