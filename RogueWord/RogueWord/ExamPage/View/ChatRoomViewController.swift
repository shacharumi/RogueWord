//
//  ChatRoomViewController.swift
//  RogueWord
//
//  Created by shachar on 2024/10/16.
//

import UIKit
import SnapKit

class ChatRoomViewController: UIViewController {

    let tableView = UITableView()
    let messageTextField = UITextField()
    let sendButton = UIButton(type: .system)
    let initLabel = UILabel()
    private var customNavBar: UIView!

    let viewModel = ChatViewModel()
    
    override func viewDidLoad() {
            super.viewDidLoad()
            setupUI()
            setupCustomNavBar()
            setupConstraints()
            setupBindings()
            setupNotifications()
            addDoneButtonOnKeyboard() 
        }
    
    private func setupCustomNavBar() {
        customNavBar = UIView()
        customNavBar.backgroundColor = .clear
        
        view.addSubview(customNavBar)
        
        customNavBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.right.equalTo(view)
            make.height.equalTo(60)
        }
        
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(systemName: "arrowshape.turn.up.backward.2.fill"), for: .normal)
        backButton.tintColor = UIColor(named: "TextColor")
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        customNavBar.addSubview(backButton)
        
        backButton.snp.makeConstraints { make in
            make.leading.equalTo(customNavBar).offset(16)
            make.centerY.equalTo(customNavBar)
        }
        
        let titleLabel = UILabel()
        titleLabel.text = "解答室"
        titleLabel.textColor = UIColor(named: "TextColor")
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)

        customNavBar.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerY.centerX.equalTo(customNavBar)
        }

    }
    
    @objc func backButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setupUI() {
        view.backgroundColor = UIColor(named: "CollectionBackGround")

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ChatTableViewCell.self, forCellReuseIdentifier: "ChatCell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(named: "CollectionBackGround")
        tableView.allowsSelection = false
        
        messageTextField.placeholder = "輸入訊息..."
        messageTextField.borderStyle = .roundedRect
        messageTextField.delegate = self
        
        sendButton.setTitle("發送", for: .normal)
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        sendButton.tintColor = .white
        sendButton.layer.cornerRadius = 10
        sendButton.layer.masksToBounds = false
        sendButton.backgroundColor = .systemBlue
        
        initLabel.text = "目前沒有任何對話，說點什麼吧"
        initLabel.textColor = UIColor(named: "TextColor")
        initLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        view.addSubview(tableView)
        view.addSubview(messageTextField)
        view.addSubview(sendButton)
        view.addSubview(initLabel)
    }
    
    func setupConstraints() {
        tableView.snp.makeConstraints { make in
            make.top.equalTo(customNavBar.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(messageTextField.snp.top).offset(-10)
        }
        
        messageTextField.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(32)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-10)
            make.right.equalTo(sendButton.snp.left).offset(-10)
            make.height.equalTo(40)
        }
        
        sendButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalTo(messageTextField)
            make.width.equalTo(60)
            make.height.equalTo(40)
        }
        initLabel.snp.makeConstraints { make in
            make.centerX.centerY.equalTo(view)
        }
    }
    
    func setupBindings() {
        viewModel.reloadTableViewClosure = { [weak self] in
            self?.tableView.reloadData()
        }
        
        viewModel.scrollToBottomClosure = { [weak self] in
            self?.scrollToBottom()
        }
        
        viewModel.showErrorClosure = { [weak self] errorMessage in
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "錯誤", message: errorMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "確定", style: .default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @objc func sendMessage() {
        initLabel.isHidden = true
        guard let text = messageTextField.text, !text.isEmpty else { return }
        messageTextField.text = ""
        viewModel.sendMessage(text)
    }
    
    func scrollToBottom() {
        if viewModel.messages.count > 0 {
            let indexPath = IndexPath(row: viewModel.messages.count - 1, section: 0)
            DispatchQueue.main.async {
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }
    
    
    func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = keyboardFrame.height
            messageTextField.snp.updateConstraints { make in
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-keyboardHeight + 10)
            }
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
            scrollToBottom()
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        messageTextField.snp.updateConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-10)
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func addDoneButtonOnKeyboard() {
           let toolbar = UIToolbar()
           toolbar.sizeToFit()
           
           let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
           let doneButton = UIBarButtonItem(title: "完成", style: .done, target: self, action: #selector(doneButtonAction))
           
           toolbar.items = [flexSpace, doneButton]
           messageTextField.inputAccessoryView = toolbar
       }

       @objc func doneButtonAction() {
           messageTextField.resignFirstResponder()
       }
    
}


extension ChatRoomViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return viewModel.messages.count
   }

   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

       let message = viewModel.messages[indexPath.row]
       let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as! ChatTableViewCell
       cell.messageLabel.text = message.content
       cell.backgroundColor =  UIColor(named: "CollectionBackGround")
       if message.role == "user" {
           cell.messageLabel.textAlignment = .right
           cell.messageLabel.textColor = .white
           cell.bubbleView.backgroundColor = .systemBlue
       } else {
           cell.messageLabel.textAlignment = .left
           cell.messageLabel.textColor = .black
           cell.bubbleView.backgroundColor = UIColor.systemGray5
       }

       return cell
   }

   func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       return UITableView.automaticDimension
   }

   func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
       return 60
   }
}


extension ChatRoomViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessage()
        return true
    }
}


class ChatTableViewCell: UITableViewCell {

    let messageLabel = UILabel()
    let bubbleView = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupConstraints()
    }

    func setupUI() {
        selectionStyle = .none

        messageLabel.numberOfLines = 0

        bubbleView.layer.cornerRadius = 15
        bubbleView.clipsToBounds = true

        contentView.addSubview(bubbleView)
        bubbleView.addSubview(messageLabel)
    }

    func setupConstraints() {
        bubbleView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(10)
            make.width.lessThanOrEqualToSuperview().multipliedBy(0.75)
        }

        messageLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if messageLabel.textAlignment == .right {
            bubbleView.snp.remakeConstraints { make in
                make.top.bottom.equalToSuperview().inset(10)
                make.right.equalToSuperview().offset(-10)
                make.width.lessThanOrEqualToSuperview().multipliedBy(0.75)
            }
        } else {
            bubbleView.snp.remakeConstraints { make in
                make.top.bottom.equalToSuperview().inset(10)
                make.left.equalToSuperview().offset(10)
                make.width.lessThanOrEqualToSuperview().multipliedBy(0.75)
            }
        }
    }
}


struct ChatMessage {
    let role: String
    let content: String
}
