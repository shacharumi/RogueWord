import UIKit
import SnapKit
import Firebase
import Lottie

class ParagraphFillInTheBlanksViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var questions: [ParagraphType]? = []
    private let tableView = UITableView()
    let animateLabel = UILabel()
    private var answerSelect: String = ""
    private let urlString = "https://api.openai.com/v1/chat/completions"
    private var customNavBar: UIView!
    private let menuButton = UIButton(type: .system)
    private let animationView = LottieAnimationView(name: "LoadingImage")
    private var answerArray: [String]?
    var wordDatas: Accurency?
    var datadismiss: ((Accurency?) -> Void)? // 定義 closure，用來傳遞資料
    let cardView = UIView()
    let questionLabel = UILabel()
    private var isTapCheck: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "CollectionBackGround")
        cardView.isHidden = true
        setupCustomNavBar()
        setupTableView()
        callChatGPTAPI()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.register(ParagraphCell.self, forCellReuseIdentifier: "ParagraphCell")
        tableView.backgroundColor = UIColor(named: "CollectionBackGround")
        tableView.frame = CGRect(x: 0, y: 60, width: view.frame.width, height: view.frame.height - 60)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(customNavBar.snp.bottom)
            make.left.equalTo(view).offset(16)
            make.right.equalTo(view).offset(-16)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        animationView.frame = CGRect(x: 0, y: 0, width: 400, height: 400)
        animationView.center = self.view.center
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.play()
        tableView.addSubview(animationView)
        
        animateLabel.text = "正在Loading，請稍等"
        animateLabel.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        animateLabel.textColor = .black
        animateLabel.textAlignment = .center
        tableView.addSubview(animateLabel)
        animateLabel.snp.makeConstraints { make in
            make.bottom.equalTo(animationView.snp.top).offset(16)
            make.centerX.equalTo(view)
        }
        DispatchQueue.main.async {
            
            self.startFlashingLabel(self.animateLabel)
        }
    }
    
    private func setupCustomNavBar() {
        customNavBar = UIView()
        customNavBar.backgroundColor = UIColor(named: "CollectionBackGround")
        
        view.addSubview(customNavBar)
        
        customNavBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.right.equalTo(view)
            make.height.equalTo(60)
        }
        let navLabel = UILabel()
        navLabel.text = "段落填空"
        navLabel.textColor = UIColor(named: "TextColor")
        navLabel.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
        customNavBar.addSubview(navLabel)
        navLabel.snp.makeConstraints { make in
            make.centerY.centerX.equalTo(customNavBar)
        }
        
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(systemName: "arrowshape.turn.up.backward.2.fill"), for: .normal)
        backButton.setTitleColor(.white, for: .normal)
        backButton.tintColor = UIColor(named: "TextColor")
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
        menuButton.setTitleColor(UIColor(named: "TextColor"), for: .normal)
        menuButton.addTarget(self, action: #selector(didTapMenu), for: .touchUpInside)
        customNavBar.addSubview(menuButton)
        
        menuButton.snp.makeConstraints { make in
            make.right.equalTo(customNavBar).offset(-16)
            make.centerY.equalTo(customNavBar).offset(-5)
        }
        
    }
    
    @objc func backButtonTapped() {
        self.dismiss(animated: true) {
            self.datadismiss?(self.wordDatas)
        }
    }
    
    @objc private func didTapMenu() {
        let menu = UIAlertController(title: "功能", message: nil, preferredStyle: .actionSheet)
        let action1 = UIAlertAction(title: "對答案", style: .default) { [weak self] _ in
            self?.isTapCheck = true
            
            self?.tableView.reloadData()
        }
        let action2 = UIAlertAction(title: "收藏", style: .default) { [weak self] _ in
            guard let self = self, let question = self.questions?[0] else { return }
            self.saveQuestionToFirebase(paragraph: question)
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        menu.addAction(action1)
        menu.addAction(action2)
        menu.addAction(cancelAction)
        present(menu, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (questions?.first?.options.count ?? 0) + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {  
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.backgroundColor = UIColor(named: "CollectionBackGround")
            cardView.backgroundColor = .white
            cardView.layer.cornerRadius = 10
            cardView.layer.shadowColor = UIColor.black.cgColor
            cardView.layer.shadowOpacity = 0.1
            cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
            cardView.layer.shadowRadius = 4
            cell.contentView.addSubview(cardView)
            
            questionLabel.text = questions?.first?.question
            questionLabel.numberOfLines = 0
            questionLabel.font = UIFont.systemFont(ofSize: 20)
            cardView.addSubview(questionLabel)
            
            cardView.snp.makeConstraints { make in
                make.top.equalTo(cell.contentView.snp.top).offset(10)
                make.leading.equalTo(cell.contentView.snp.leading).offset(10)
                make.trailing.equalTo(cell.contentView.snp.trailing).offset(-10)
                make.bottom.equalTo(cell.contentView.snp.bottom).offset(-10)
            }
            
            questionLabel.snp.makeConstraints { make in
                make.top.equalTo(cardView.snp.top).offset(15)
                make.leading.equalTo(cardView.snp.leading).offset(15)
                make.trailing.equalTo(cardView.snp.trailing).offset(-15)
                make.bottom.equalTo(cardView.snp.bottom).offset(-15)
            }
            
            return cell
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ParagraphCell", for: indexPath) as? ParagraphCell {
                cell.answerSelectLabel.text = "(\(questions?[0].selectNumber[indexPath.row - 1] ?? "\(indexPath.row)()"))"
                cell.selectionStyle = .none
                cell.backgroundColor = UIColor(named: "CollectionBackGround")
                cell.optionLabel0.setTitle(questions?[0].options[indexPath.row - 1][0], for: .normal)
                cell.optionLabel1.setTitle(questions?[0].options[indexPath.row - 1][1], for: .normal)
                cell.optionLabel2.setTitle(questions?[0].options[indexPath.row - 1][2], for: .normal)
                cell.optionLabel3.setTitle(questions?[0].options[indexPath.row - 1][3], for: .normal)
                cell.isUserInteractionEnabled = true
                cell.optionLabel0.addTarget(self, action: #selector(tapOptions(_:)), for: .touchUpInside)
                cell.optionLabel1.addTarget(self, action: #selector(tapOptions(_:)), for: .touchUpInside)
                cell.optionLabel2.addTarget(self, action: #selector(tapOptions(_:)), for: .touchUpInside)
                cell.optionLabel3.addTarget(self, action: #selector(tapOptions(_:)), for: .touchUpInside)
                cell.translateButton.tag = indexPath.row
                cell.translateButton.addTarget(self, action: #selector(translateText), for: .touchUpInside)
                if isTapCheck {
                    let selectedAnswer = self.questions?[0].selectNumber[indexPath.row - 1]
                    let correctAnswer = self.questions?[0].answerOptions[indexPath.row - 1]
                    cell.translateButton.isHidden = false
                    cell.optionLabel0.isUserInteractionEnabled = false
                    cell.optionLabel1.isUserInteractionEnabled = false
                    cell.optionLabel2.isUserInteractionEnabled = false
                    cell.optionLabel3.isUserInteractionEnabled = false
                    //cell.translateButton.isUserInteractionEnabled

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
    }
    
    
    func saveQuestionToFirebase(paragraph: ParagraphType) {
        var mutableParagraph = paragraph
        
        let alert = UIAlertController(title: "輸入錯題名稱", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "輸入名稱"
        }
        
        let confirmAction = UIAlertAction(title: "確認", style: .default) { [weak self] _ in
            if let documentName = alert.textFields?.first?.text, !documentName.isEmpty {
                let db = Firestore.firestore()
                mutableParagraph.title = documentName
                let paragraphData = mutableParagraph.toDictionary()
                guard let userID = UserDefaults.standard.string(forKey: "userID") else {return}
                
                db.collection("PersonAccount")
                    .document(userID)
                    .collection("CollectionFolderWrongQuestions")
                    .document()
                    .setData(paragraphData) { error in
                        if let error = error {
                            print("Error adding document: \(error)")
                        } else {
                            print("Document added successfully to CollectionFolderWrongQuestions")
                            
                            let successAlert = UIAlertController(title: "收藏成功", message: "問題已成功被收藏！", preferredStyle: .alert)
                            successAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self?.present(successAlert, animated: true, completion: nil)
                        }
                    }
            } else {
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
        let query = FirestoreEndpoint.fetchAccurencyRecords.ref.document("Paragraph")
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
    
    
    @objc private func translateText(_ sender: UIButton) {
        print("aa")
        let alert = UIAlertController(title: "Answer Text", message: answerArray?[sender.tag - 1], preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
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
    
    func startFlashingLabel(_ label: UILabel) {
        label.alpha = 1.0
        UIView.animate(withDuration: 1,
                       delay: 0.0,
                       options: [.repeat, .autoreverse],
                       animations: {
                           label.alpha = 0.0
                       }, completion: nil)
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
        var optionsDict: [String: [String]] = [:]
        for (index, optionSet) in options.enumerated() {
            optionsDict["option_set_\(index)"] = optionSet
        }
        
        return [
            "questions": self.question,
            "options": optionsDict,
            "answerOptions": self.answerOptions,
            "answer": self.answer,
            "title": self.title,
            "tag": "段落填空",
            "timestamp": Timestamp()
        ]
    }
}



extension ParagraphFillInTheBlanksViewController {
    
    private func callChatGPTAPI() {
        guard let url = URL(string: urlString) else { return }
        var request = URLRequest(url: url)
        guard let version = UserDefaults.standard.string(forKey: "version") else { return }
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(ChatGPTAPIKey.key)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        
        let openAIBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "system", "content": "You are a helpful assistant."],
                ["role": "user", "content": """
                請幫我生成一題\(version)段落測驗題，內容難度為\(version)高分的題目，著重於單字跟文法，我要的內容跟範例不相干，不用理會範例題目內容，請出全新的題目，但請嚴格遵循我以下的Json格式，並且在最後回傳給我Json格式就好，不要有多餘的字，請每次都給出不同問題。
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
                  "Answer": "1. (A) 減少 (B) 增加 (C) 解散 (D) 避免, 'increase' 是正確答案，因為根據語境，行銷部門旨在提高公司的全球市場能見度。2. (A) 實行 (B) 避免 (C) 威懾 (D) 破壞, 'implementing' 意味著採用創新策略，與前述語境吻合。3. (A) 捕捉 (B) 避免 (C) 忽視 (D) 移除, 'capture' 指的是獲取更廣泛的客戶群，是根據上下文得出的正確答案。4. (A) 使用 (B) 拒絕 (C) 停止 (D) 忽略, 'utilize' 是正確答案，因為這裡指的是利用社交媒體平台來接觸年輕的受眾。5. (A) 避免 (B) 採用 (C) 簡化 (D) 懷疑, 'adopting' 是正確答案，因為年輕人以擁抱科技和線上溝通著稱。"
                }
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
                                    self?.animateLabel.isHidden = true
                                    self?.animationView.isHidden = true
                                    self?.questions = parsedQuestions
                                    self?.answerArray = self?.questions?[0].answer.components(separatedBy: "。")
                                    self?.setupTableView()
                                    self?.tableView.reloadData()
                                    self?.cardView.isHidden = false
                                    self?.questionLabel.isHidden = false
                                }
                            }
                        } catch {
                            print("解析 content JSON 時發生錯誤: \(error)")
                        }
                    }
                }
            } catch {
                print("JSON解析錯誤: \(error)")
                //self?.callChatGPTAPI()
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
}
