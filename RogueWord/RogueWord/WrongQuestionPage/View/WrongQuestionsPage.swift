//
//  WrongQuestionsPage.swift
//  RogueWord
//
//  Created by shachar on 2024/9/23.
//

import Foundation
import UIKit
import FirebaseFirestore
import SnapKit

class WrongQuestionsPage: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    private var collectionView: UICollectionView!
    private var wordQuestions: [WordFillDocument] = []
    private var paragraphQuestions: [GetParagraphType] = []  // 用來存儲 Firebase 中抓取的 documentIDs
    private var readingQuestions: [GetReadingType] = []  // 用來存儲 Firebase 中抓取的 documentIDs
    
    private let buttonStackView = UIStackView()  // UIStackView 來容納按鈕
    private let indicatorView = UIView()  // 指示當前選中的指示器
    private var currentQuestionType: QuestionType = .paragraph  // 默認為段落填空
    private let navView = UIView()
    private let navButton = UIButton()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 設置視圖背景顏色
        view.backgroundColor = UIColor(named: "CollectionBackGround")
        
        // 設置按鈕並放入 stackView
        setupButtons()
        
        // 設置 UICollectionViewFlowLayout 來實現兩列佈局
        let layout = UICollectionViewFlowLayout()
        let itemSpacing: CGFloat = 10
        let itemsPerRow: CGFloat = 2
        let padding: CGFloat = 16
        let totalSpacing = (itemsPerRow - 1) * itemSpacing + padding * 2
        
        layout.minimumInteritemSpacing = itemSpacing
        layout.minimumLineSpacing = itemSpacing
        
        let itemWidth = (view.bounds.width - totalSpacing) / itemsPerRow
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)  // 設置正方形的單元格
        
        // 初始化 UICollectionView
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(QuestionCell.self, forCellWithReuseIdentifier: "QuestionCell")
        collectionView.backgroundColor = UIColor(named: "CollectionBackGround")
        view.addSubview(collectionView)
        
        // 使用 SnapKit 設置 UICollectionView 的約束
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(buttonStackView.snp.bottom).offset(16)  
            make.left.equalTo(view).offset(16)
            make.right.equalTo(view).offset(-16)
            make.bottom.equalTo(view)
        }
        currentQuestionType = .paragraph
           let query = FirestoreEndpoint.fetchWrongQuestion.ref.whereField("tag", isEqualTo: "段落填空")
           fetchQuestionsFromFirebase(query: query, type: .paragraph)
    }
    
    // 設置 StackView 和按鈕
    private func setupButtons() {
        navView.backgroundColor = .clear
        view.addSubview(navView)
        navView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.right.equalTo(view)
            make.height.equalTo(32)
        }
        
        navButton.setImage(UIImage(systemName: "arrowshape.turn.up.backward.2.fill"), for: .normal)
        navButton.tintColor = UIColor(named: "TextColor")
        navButton.addTarget(self, action: #selector(backTap), for: .touchUpInside)
        navView.addSubview(navButton)
        navButton.snp.makeConstraints { make in
            make.centerY.equalTo(navView)
            make.left.equalTo(navView).offset(16)
            make.width.height.equalTo(30)        }
        
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 0
        let navLabel = UILabel()
        navLabel.text = "錯題本"
        navLabel.textColor = UIColor(named: "TextColor")
        navLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        navView.addSubview(navLabel)
        navLabel.snp.makeConstraints { make in
            make.centerY.centerX.equalTo(navView)
            make.height.equalTo(30)
        }
        // 添加按鈕
        let wordQuizButton = createButton(title: "單字測驗")
        let paragraphButton = createButton(title: "段落填空")
        let readingButton = createButton(title: "閱讀理解")
        
        buttonStackView.addArrangedSubview(wordQuizButton)
        buttonStackView.addArrangedSubview(paragraphButton)
        buttonStackView.addArrangedSubview(readingButton)
        
        // 將 StackView 添加到 view 中
        view.addSubview(buttonStackView)
        
        // 使用 SnapKit 設置 StackView 的約束，位於 navigationBar 下方
        buttonStackView.snp.makeConstraints { make in
            make.top.equalTo(navView.snp.bottom)
            make.left.equalTo(view).offset(16)
            make.right.equalTo(view).offset(-16)
            make.height.equalTo(44)
        }

        // 添加指示器到 stackView 下方
        indicatorView.backgroundColor = UIColor(named: "TextColor")
        view.addSubview(indicatorView)
        
        // 設置指示器初始位置在段落填空按鈕下方
        indicatorView.snp.makeConstraints { make in
            make.top.equalTo(buttonStackView.snp.bottom)
            make.height.equalTo(3)
            make.width.equalTo(paragraphButton.snp.width)
            make.left.equalTo(paragraphButton.snp.left)
        }
    }
    @objc func backTap() {
        self.dismiss(animated: true)
    }
    
    // 工具函數來創建按鈕
    private func createButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(UIColor(named: "TextColor"), for: .normal)
        button.backgroundColor = UIColor(named: "CollectionBackGround")
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        
        return button
    }
    
    // 按鈕點擊事件
    @objc private func buttonTapped(_ sender: UIButton) {
        guard let title = sender.title(for: .normal) else { return }

        var query: Query?

        switch title {
        case "單字測驗":
            currentQuestionType = .wordQuiz
            query = FirestoreEndpoint.fetchWrongQuestion.ref.whereField("tag", isEqualTo: "單字測驗")
            fetchQuestionsFromFirebase(query: query, type: .wordQuiz)

        case "段落填空":
            currentQuestionType = .paragraph
            query = FirestoreEndpoint.fetchWrongQuestion.ref.whereField("tag", isEqualTo: "段落填空")
            fetchQuestionsFromFirebase(query: query, type: .paragraph)

        case "閱讀理解":
            currentQuestionType = .reading
            query = FirestoreEndpoint.fetchWrongQuestion.ref.whereField("tag", isEqualTo: "閱讀理解")
            fetchQuestionsFromFirebase(query: query, type: .reading)

        default:
            break
        }

        // 動畫移動指示器到點擊的按鈕下方
        UIView.animate(withDuration: 0.3) {
            self.indicatorView.snp.remakeConstraints { make in
                make.top.equalTo(self.buttonStackView.snp.bottom)
                make.height.equalTo(3)
                make.width.equalTo(sender.snp.width)
                make.left.equalTo(sender.snp.left)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    // 從 Firebase 抓取 .collection("CollectionFolderWrongQuestions") 的資料，只顯示 documentID
    private func fetchQuestionsFromFirebase(query: Query?, type: QuestionType) {
        guard let query = query else { return }

        switch type {
        case .wordQuiz:
            FirestoreService.shared.getDocuments(query) { [weak self] (questions: [WordFillDocument]) in
                guard let self = self else { return }
                self.wordQuestions = questions as! [WordFillDocument]  // 根據需要轉型
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        case .paragraph:
            FirestoreService.shared.getDocuments(query) { [weak self] (paragraphs: [GetParagraphType]) in
                guard let self = self else { return }
                self.paragraphQuestions = paragraphs
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        case .reading:
            FirestoreService.shared.getDocuments(query) { [weak self] (readings: [GetReadingType]) in
                guard let self = self else { return }
                self.readingQuestions = readings as! [GetReadingType]  // 根據需要轉型
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    // MARK: - UICollectionViewDataSource Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch currentQuestionType {
        case .wordQuiz:
            return wordQuestions.count
        case .paragraph:
            return paragraphQuestions.count
        case .reading:
            return readingQuestions.count
        }
    }

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "QuestionCell", for: indexPath) as! QuestionCell
        cell.backgroundColor = UIColor(named: "viewBackGround")
        switch currentQuestionType {
        case .wordQuiz:
            let word = wordQuestions[indexPath.item]
            cell.configure(with: word.title ?? "No Title", time: word.timestamp)
        case .paragraph:
            let paragraph = paragraphQuestions[indexPath.item]
            cell.configure(with: paragraph.title ?? "No Title", time: paragraph.timestamp)
        case .reading:
            let reading = readingQuestions[indexPath.item]
            cell.configure(with: reading.title ?? "No Title", time: reading.timestamp)
        }

        return cell
    }

    
    // MARK: - UICollectionViewDelegate Methods
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        var selectedQuestion: Any
        var viewControllerToPresent: UIViewController?
        
        switch currentQuestionType {
        case .wordQuiz:
            let selectedWordQuestion = wordQuestions[indexPath.item]
            selectedQuestion = selectedWordQuestion.questions
            let wordFillVC = WrongQuestionWordVC()
            wordFillVC.questions = selectedWordQuestion.questions
            wordFillVC.questionsTitle = selectedWordQuestion.title
            viewControllerToPresent = wordFillVC
            
            wordFillVC.datadismiss = {
                let query = FirestoreEndpoint.fetchWrongQuestion.ref.whereField("tag", isEqualTo: "單字測驗")
                self.fetchQuestionsFromFirebase(query: query, type: .wordQuiz)
            }
            
        case .paragraph:
            let selectedParagraphQuestion = paragraphQuestions[indexPath.item]
            selectedQuestion = selectedParagraphQuestion.questions
            let paragraphVC = WrongQuestionParagraphVC()
            paragraphVC.questions = selectedParagraphQuestion
            paragraphVC.questionsTitle = selectedParagraphQuestion.title
            viewControllerToPresent = paragraphVC
            
            paragraphVC.datadismiss = {
                let query = FirestoreEndpoint.fetchWrongQuestion.ref.whereField("tag", isEqualTo: "段落填空")
                self.fetchQuestionsFromFirebase(query: query, type: .paragraph)
            }
            
        case .reading:
            let selectedReadingQuestion = readingQuestions[indexPath.item]
            selectedQuestion = selectedReadingQuestion.questions
            let readingVC = WrongQuestionReadingVC()
            readingVC.questions = selectedReadingQuestion
            readingVC.questionsTitle = selectedReadingQuestion.title
            viewControllerToPresent = readingVC
            
            //重新抓資料
            readingVC.datadismiss = {
                self.currentQuestionType = .reading
                let query = FirestoreEndpoint.fetchWrongQuestion.ref.whereField("tag", isEqualTo: "閱讀理解")
                self.fetchQuestionsFromFirebase(query: query, type: .reading)
            }
        }
        
        // 以全屏模式展示相应的 ViewController
        viewControllerToPresent?.modalPresentationStyle = .fullScreen
        present(viewControllerToPresent!, animated: true, completion: nil)
    }

}



class QuestionCell: UICollectionViewCell {
    
    private let documentIDLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    let timeLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(documentIDLabel)
        contentView.addSubview(timeLabel)
        documentIDLabel.snp.makeConstraints { make in
            make.centerX.equalTo(contentView)
            make.centerY.equalTo(contentView).offset(-25)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.centerX.equalTo(contentView)
            make.centerY.equalTo(contentView).offset(25)
        }
        
        contentView.layer.borderWidth = 1.0
        contentView.layer.borderColor = UIColor.lightGray.cgColor
        contentView.layer.cornerRadius = 8
        contentView.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with documentID: String, time timeStamp: Timestamp) {
        documentIDLabel.text = documentID
        let date = timeStamp.dateValue()


           let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
           let formattedDate = dateFormatter.string(from: date)

           timeLabel.text = formattedDate
    }
}


enum QuestionType {
    case wordQuiz
    case paragraph
    case reading
}
