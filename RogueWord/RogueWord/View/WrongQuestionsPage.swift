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
    private var documentIDs: [String] = []  // 用來存儲 Firebase 中抓取的 documentIDs
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 設置視圖背景顏色
        view.backgroundColor = .white
        
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
            make.edges.equalToSuperview()  // 將 UICollectionView 填滿整個視圖
        }
        
        // 從 Firebase 抓取資料
        fetchDocumentIDsFromFirebase()
    }
    
    // 從 Firebase 抓取 .collection("CollectionFolderWrongQuestions") 的資料，只顯示 documentID
    private func fetchDocumentIDsFromFirebase() {
        let db = Firestore.firestore()
        
        // 假設你已經有 account
        db.collection("PersonAccount")
            .document(account)
            .collection("CollectionFolderParagraphQuestions")
            .getDocuments { [weak self] (snapshot, error) in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    guard let documents = snapshot?.documents else {
                        print("No documents found")
                        return
                    }
                    
                    // 抓取每個 document 的 documentID
                    for document in documents {
                        self.documentIDs.append(document.documentID)
                    }
                    
                    // 更新 UICollectionView
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
            }
    }
    
    // MARK: - UICollectionViewDataSource Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return documentIDs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "QuestionCell", for: indexPath) as! QuestionCell
        let documentID = documentIDs[indexPath.item]
        
        // 設置每個 Cell 的顯示內容，這裡只顯示 documentID
        cell.configure(with: documentID)
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate Methods
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        // 當選中某個項目時的操作
    }
}

// 定義 UICollectionViewCell 的子類
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
        
        // 使用 SnapKit 設置 documentIDLabel 的約束
        documentIDLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
        
        // 設置 Cell 的外觀
        contentView.layer.borderWidth = 1.0
        contentView.layer.borderColor = UIColor.lightGray.cgColor
        contentView.layer.cornerRadius = 8
        contentView.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 設置 Cell 的數據，顯示 documentID
    func configure(with documentID: String) {
        documentIDLabel.text = documentID
    }
}
