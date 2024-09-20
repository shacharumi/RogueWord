import Foundation
import UIKit

class ParagraphFillInTheBlanksViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let urlString = "https://api.openai.com/v1/chat/completions"
    private var questions: [ParagraphType] = []
    private let tableView = UITableView()
    private var answerSelect: String = ""
    
    private lazy var rightButton: UIBarButtonItem = {
            let barButton = UIBarButtonItem(title: "Options", style: .plain, target: nil, action: nil)

            let action1 = UIAction(title: "答案", image: UIImage(systemName: "star"), handler: { [weak self] _ in
                                
                for i in 0..<(self?.questions[0].options.count ?? 0) {
                    
                    let selectedAnswer = self?.questions[0].selectNumber[i]
                    let correctAnswer = self?.questions[0].answerOptions[i]
                    
                    let indexPath = IndexPath(row: i, section: 0)
                    
                    if let cell = self?.tableView.cellForRow(at: indexPath) as? ParagraphCell {
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
            let alert = UIAlertController(title: "Answer Text", message: self.questions[0].answer, preferredStyle: .alert)
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
        callChatGPTAPI()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ParagraphCell.self, forCellReuseIdentifier: "ParagraphCell")
        tableView.frame = view.bounds
        
    }
    
    
    
    // 根據問題的選項數量來決定行數
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    
    // 配置每個 row 的內容，顯示選項和對應的答案
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ParagraphCell", for: indexPath) as? ParagraphCell {
            cell.answerSelectLabel.text = "(\(questions[0].selectNumber[indexPath.row] ?? "()"))"
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
            return cell
        } else {
            return UITableViewCell()
        }
    }

    
    // 設置 header，顯示問題段落
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .lightGray
        
        let headerLabel = UILabel()
        headerLabel.numberOfLines = 0
        
        // 顯示問題的段落，因為只需顯示第一個問題
        if let question = questions.first?.question {
            headerLabel.text = question
        }
        
        headerLabel.frame = CGRect(x: 20, y: 5, width: tableView.frame.width - 40, height: 0)
        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)
        
        return headerView
    }
    
    // 設置 header 的高度
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let questionText = questions.first?.question ?? ""
        let label = UILabel()
        label.numberOfLines = 0
        label.text = questionText
        label.frame = CGRect(x: 20, y: 5, width: tableView.frame.width - 40, height: 0)
        label.sizeToFit()
        return label.frame.height + 10
    }
    
    // 呼叫 OpenAI API
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
                    
                    // 處理 content 中的換行符號和特殊字符
                    let cleanedContent = content.replacingOccurrences(of: "\\n", with: "")
                        .replacingOccurrences(of: "\\", with: "")
                    
                    // 將處理過的字串再轉換成 JSON 數據
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
}

extension ParagraphFillInTheBlanksViewController {
    @objc func tapRightItem() {
        
    }
    
    @objc func tapOptions(_ sender: UIButton) {
        guard let cell = sender.superview?.superview as? ParagraphCell else { return }
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

struct ParagraphType {
    var question: String
    var options: [[String]]
    var answerOptions: [String]
    var answer: String
    
    var selectNumber: [String]
}


