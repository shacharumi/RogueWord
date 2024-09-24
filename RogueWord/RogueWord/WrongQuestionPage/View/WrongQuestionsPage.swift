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
    
    private let buttonStackView = UIStackView()  // 新增一個 UIStackView 來容納按鈕
    private var currentQuestionType: QuestionType = .paragraph  // 默認為段落填空

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 設置視圖背景顏色
        view.backgroundColor = .white
        
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
        
        // 計算每個單元格的寬度，保證兩個單元格一行
        let itemWidth = (view.bounds.width - totalSpacing) / itemsPerRow
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)  // 設置正方形的單元格
        
        // 初始化 UICollectionView
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(QuestionCell.self, forCellWithReuseIdentifier: "QuestionCell")
        collectionView.backgroundColor = .white
        view.addSubview(collectionView)
        
        // 使用 SnapKit 設置 UICollectionView 的約束
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(buttonStackView.snp.bottom).offset(10)  // 確保 UICollectionView 在 stackView 之下
            make.left.right.bottom.equalToSuperview()
        }
        
    }
    
    // 設置 StackView 和按鈕
    private func setupButtons() {
        // 配置 StackView
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 10
        
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
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(44)  // 設置 StackView 的高度
        }
    }
    
    // 工具函數來創建按鈕
    private func createButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
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

        switch currentQuestionType {
        case .wordQuiz:
            let word = wordQuestions[indexPath.item]
            cell.configure(with: word.title ?? "No Title")
        case .paragraph:
            let paragraph = paragraphQuestions[indexPath.item]
            cell.configure(with: paragraph.title ?? "No Title")
        case .reading:
            let reading = readingQuestions[indexPath.item]
            cell.configure(with: reading.title ?? "No Title")
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
            // 获取选择的单字测验问题
            let selectedWordQuestion = wordQuestions[indexPath.item]
            selectedQuestion = selectedWordQuestion.questions
            let wordFillVC = WrongQuestionWordVC()
            wordFillVC.questions = selectedWordQuestion.questions
            wordFillVC.questionsTitle = selectedWordQuestion.title
            viewControllerToPresent = wordFillVC
            
        case .paragraph:
            // 获取选择的段落填空问题
            let selectedParagraphQuestion = paragraphQuestions[indexPath.item]
            selectedQuestion = selectedParagraphQuestion.questions
            let paragraphVC = WrongQuestionParagraphVC() // 你需要创建相应的段落填空的 ViewController
            paragraphVC.questions = selectedParagraphQuestion
            paragraphVC.questionsTitle = selectedParagraphQuestion.title
            viewControllerToPresent = paragraphVC
            
        case .reading:
            // 获取选择的阅读理解问题
            let selectedReadingQuestion = readingQuestions[indexPath.item]
            selectedQuestion = selectedReadingQuestion.questions
            let readingVC = WrongQuestionReadingVC() // 你需要创建相应的阅读理解的 ViewController
            readingVC.questions = selectedReadingQuestion
            readingVC.questionsTitle = selectedReadingQuestion.title
            viewControllerToPresent = readingVC
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(documentIDLabel)
        
        documentIDLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
        
        contentView.layer.borderWidth = 1.0
        contentView.layer.borderColor = UIColor.lightGray.cgColor
        contentView.layer.cornerRadius = 8
        contentView.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with documentID: String) {
        documentIDLabel.text = documentID
    }
}


enum QuestionType {
    case wordQuiz
    case paragraph
    case reading
}
