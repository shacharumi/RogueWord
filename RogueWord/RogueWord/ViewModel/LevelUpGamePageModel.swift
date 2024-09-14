//
//  LevelUpGamePageModel.swift
//  RogueWord
//
//  Created by shachar on 2024/9/12.
//

import Foundation
import Firebase

class LevelUpGamePageModel {
    
    private var words: [JsonWord] = []
    private var questions: [JsonWord] = []
    private(set) var currentQuestionIndex: Int = 0
    
    // Firebase 初始化
    init() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        loadWords()
    }
    
    // 載入詞彙
    private func loadWords() {
        words = loadWordsFromFile()
        questions = words
    }
    
    // 獲取當前的問題
    func getCurrentQuestion() -> JsonWord? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }
    
    // 產生錯誤答案
    func generateWrongAnswers(for correctAnswer: String) -> [String] {
        var wrongAnswers = words.map { $0.chinese }.filter { $0 != correctAnswer }
        wrongAnswers.shuffle()
        return Array(wrongAnswers.prefix(3))
    }
    
    // 檢查答案
    func checkAnswer(_ answer: String) -> Bool {
        guard let question = getCurrentQuestion() else { return false }
        return answer == question.chinese
    }
    
    // 更新到下一題
    func moveToNextQuestion() -> Bool {
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
            return true
        } else {
            return false
        }
    }
    
   
    
    // 將單字加入收藏
    func addToFavorites() {
        guard let word = getCurrentQuestion() else { return }
        
        let favoriteData: [String: Any] = [
            "LevelNumber": currentQuestionIndex,
            "Tag": "All"
        ]
        
        let db = Firestore.firestore()
        let userCollectionRef = db.collection("PersonAccount").document(account).collection("CollectionFolderWords").document("\(currentQuestionIndex)")
        
        userCollectionRef.setData(favoriteData, merge: true) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Document added with ID: \(self.currentQuestionIndex)")
            }
        }
    }
    
    func removeToFavorites() {
        guard let word = getCurrentQuestion() else {return}
        
        let db = Firestore.firestore()
        let userCollectionRef = db.collection("PersonAccount").document(account).collection("CollectionFolderWords").document("\(currentQuestionIndex)")
        
        userCollectionRef.delete() { error in
            if let error = error {
                print("Error remove document: \(error)")
            } else {
                print("Document removed with ID: \(self.currentQuestionIndex)")
            }
        }
    }
}

// MARK: --載入 JSON 檔案
func loadWordsFromFile() -> [JsonWord] {
    // 獲取 Documents 目錄路徑
    guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
        print("Error: Could not find the documents directory.")
        return []
    }

    // 組合出 words.json 文件的完整路徑
    let fileURL = documentDirectory.appendingPathComponent("words.json")

    // 檢查檔案是否存在
    guard FileManager.default.fileExists(atPath: fileURL.path) else {
        print("Error: words.json file not found in the documents directory.")
        return []
    }

    do {
        let data = try Data(contentsOf: fileURL)
        print("Successfully loaded data from words.json in documents directory.")

        let wordFile = try JSONDecoder().decode([String: JsonWord].self, from: data)
        print("Successfully decoded JSON data.")

        // 根據 key 的數字大小排序
        let sortedWords = wordFile.sorted { (firstPair, secondPair) -> Bool in
            if let firstKey = Int(firstPair.key), let secondKey = Int(secondPair.key) {
                return firstKey < secondKey
            }
            return false
        }

        // 返回排序後的 Word 對象
        print("aaaaaaaaa")
        print(sortedWords.map { $0.value })

        print("aaaaaaaaa")

        return sortedWords.map { $0.value }
    } catch {
        // 捕捉錯誤並打印錯誤信息
        print("Error during JSON loading or decoding: \(error.localizedDescription)")
        return []
    }
}
