//
//  WrongQuestionsPage.swift
//  RogueWord
//
//  Created by shachar on 2024/9/23.
//

import UIKit
import FirebaseFirestore
import SnapKit

class WrongQuestionsPage: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    // MARK: - Properties
    private var collectionView: UICollectionView!
    private let buttonStackView = UIStackView()
    private let indicatorView = UIView()
    private let navView = UIView()
    private let navButton = UIButton()

    private let viewModel = WrongQuestionsViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupBindings()
        viewModel.fetchQuestions()
    }

    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = UIColor(named: "CollectionBackGround")
        setupButtons()
        setupCollectionView()
    }

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
            make.width.height.equalTo(30)
        }

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

    private func setupCollectionView() {
        // 設置 UICollectionViewFlowLayout 來實現兩列佈局
        let layout = UICollectionViewFlowLayout()
        let itemSpacing: CGFloat = 10
        let itemsPerRow: CGFloat = 2
        let padding: CGFloat = 16
        let totalSpacing = (itemsPerRow - 1) * itemSpacing + padding * 2

        layout.minimumInteritemSpacing = itemSpacing
        layout.minimumLineSpacing = itemSpacing

        let itemWidth = (view.bounds.width - totalSpacing) / itemsPerRow
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(QuestionCell.self, forCellWithReuseIdentifier: "QuestionCell")
        collectionView.backgroundColor = UIColor(named: "CollectionBackGround")
        view.addSubview(collectionView)

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(buttonStackView.snp.bottom).offset(16)
            make.left.equalTo(view).offset(16)
            make.right.equalTo(view).offset(-16)
            make.bottom.equalTo(view)
        }
    }

    private func setupBindings() {
        viewModel.onDataUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
    }

    @objc private func buttonTapped(_ sender: UIButton) {
        guard let title = sender.title(for: .normal) else { return }

        switch title {
        case "單字測驗":
            viewModel.currentQuestionType = .wordQuiz
        case "段落填空":
            viewModel.currentQuestionType = .paragraph
        case "閱讀理解":
            viewModel.currentQuestionType = .reading
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

    @objc func backTap() {
        self.dismiss(animated: true)
    }

    private func createButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(UIColor(named: "TextColor"), for: .normal)
        button.backgroundColor = UIColor(named: "CollectionBackGround")
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)

        return button
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch viewModel.currentQuestionType {
        case .wordQuiz:
            return viewModel.wordQuestions.count
        case .paragraph:
            return viewModel.paragraphQuestions.count
        case .reading:
            return viewModel.readingQuestions.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "QuestionCell", for: indexPath) as? QuestionCell {
            cell.backgroundColor = UIColor(named: "viewBackGround")

            switch viewModel.currentQuestionType {
            case .wordQuiz:
                let wordDocument = viewModel.wordQuestions[indexPath.item]
                cell.configure(with: wordDocument.title ?? "No Title", time: wordDocument.timestamp)
            case .paragraph:
                let paragraph = viewModel.paragraphQuestions[indexPath.item]
                cell.configure(with: paragraph.title ?? "No Title", time: paragraph.timestamp)
            case .reading:
                let reading = viewModel.readingQuestions[indexPath.item]
                cell.configure(with: reading.title ?? "No Title", time: reading.timestamp)
            }
            return cell
        }
            return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        var viewControllerToPresent: UIViewController?

        switch viewModel.currentQuestionType {
        case .wordQuiz:
            let selectedWordDocument = viewModel.wordQuestions[indexPath.item]
            let wordFillVC = WrongQuestionWordVC()
            wordFillVC.questions = selectedWordDocument.questions
            wordFillVC.questionsTitle = selectedWordDocument.title
            viewControllerToPresent = wordFillVC

            wordFillVC.dataDismiss = { [weak self] in
                self?.viewModel.fetchQuestions()
            }

        case .paragraph:
            let selectedParagraph = viewModel.paragraphQuestions[indexPath.item]
            let paragraphVC = WrongQuestionParagraphVC()
            paragraphVC.questionData = selectedParagraph
            paragraphVC.questionsTitle = selectedParagraph.title
            viewControllerToPresent = paragraphVC

            paragraphVC.dataDismiss = { [weak self] in
                self?.viewModel.fetchQuestions()
            }

        case .reading:
            let selectedReading = viewModel.readingQuestions[indexPath.item]
            let readingVC = WrongQuestionReadingVC()
            readingVC.readingData = selectedReading
            readingVC.questionsTitle = selectedReading.title
            viewControllerToPresent = readingVC

            readingVC.dataDismiss = { [weak self] in
                self?.viewModel.fetchQuestions()
            }
        }

        if let vc = viewControllerToPresent {
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true, completion: nil)
        }
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
    let timeLabel: UILabel = {
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
    // Updated the configure method to accept optional Timestamp
    func configure(with documentID: String, time timeStamp: Timestamp?) {
        documentIDLabel.text = documentID
        if let timeStamp = timeStamp {
            let date = timeStamp.dateValue()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let formattedDate = dateFormatter.string(from: date)
            timeLabel.text = formattedDate
        } else {
            timeLabel.text = "No Date"
        }
    }
}
