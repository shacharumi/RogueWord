//
//  CollectionPageViewModel.swift
//  RogueWord
//
//  Created by shachar on 2024/9/12.
//

import Firebase

class CollectionPageViewModel {
    
    // 定義詞彙資料的變更回調
    var onDataChange: (() -> Void)?
    var onTagChange: (() -> Void)?

    // 儲存詞彙資料
    private(set) var words: [FireBaseWord] = [] {
        didSet {
            onDataChange?()
        }
    }
    
    private(set) var tags: [String] = [] {
        didSet {
            onTagChange?()
        }
    }
    
    // 從 Firebase 獲取資料
    func fetchDataFromFirebase() {
        let db = Firestore.firestore()
        let collectionRef = db.collection("PersonAccount").document(account).collection("CollectionFolderWord")
        
        collectionRef.getDocuments { [weak self] (snapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error)")
                return
            }
            
            guard let snapshot = snapshot else { return }
            
            self?.words = snapshot.documents.compactMap { document -> FireBaseWord? in
                let data = document.data()
                guard let levelNumber = data["LevelNumber"] as? Int,
                      let tag = data["Tag"] as? String,
                      let english = data["English"] as? String,
                      let chinese = data["Chinese"] as? String,
                      let property = data["Property"] as? String,
                      let sentence = data["Sentence"] as? String else {
                    return nil
                }
                return FireBaseWord(levelNumber: levelNumber, english: english, chinese: chinese, property: property, sentence: sentence, tag: tag)
            }
        }
    }
    
    func fetchTagFromFirebase() {
        let db = Firestore.firestore()
        let collectionRef = db.collection("PersonAccount")
        
        collectionRef.getDocuments { [weak self] (snapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error)")
                return
            }
            
            guard let snapshot = snapshot else { return }
            
            // 確保 tags 是 [String] 類型的屬性
            self?.tags = snapshot.documents.compactMap { document -> [String]? in
                let data = document.data()
                guard let tagArray = data["Tag"] as? [String] else {
                    return nil
                }
                return tagArray
            }.flatMap { $0 } // 展平成單一 [String] 陣列
        }
    }

    func updateWordTag(_ tag: String, _ levelNumber: Int) {
        let db = Firestore.firestore()
        let collectionRef = db.collection("PersonAccount").document(account).collection("CollectionFolderWord")
        
        collectionRef.document("\(levelNumber)").updateData([
                "Tag": tag  // 將 Tag 字段更新為 "1"
            ]) { error in
                if let error = error {
                    print("Error updating document: \(error)")
                } else {
                    print("Document successfully updated!")
                }
            }    }
    
    // 從 Firebase 和本地資料中移除詞彙
    func removeWord(at index: Int) {
        let wordToRemove = words[index]
        
        // 刪除本地資料
        words.remove(at: index)
        
        // 刪除 Firebase 中的資料
        let db = Firestore.firestore()
        let collectionRef = db.collection("PersonAccount").document("CollectionFolder")
        
        collectionRef.updateData([
            "\(wordToRemove.levelNumber)": FieldValue.delete()  // 使用 levelNumber 來刪除該項
        ]) { error in
            if let error = error {
                print("Error removing document: \(error)")
            } else {
                print("Document successfully removed!")
            }
        }
    }
    
    
}
