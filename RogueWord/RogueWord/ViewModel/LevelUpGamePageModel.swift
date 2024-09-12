//
//  LevelUpGamePageModel.swift
//  RogueWord
//
//  Created by shachar on 2024/9/12.
//

import Foundation
import Firebase

class LevelUpGamePageModel {
    
    private var words: [Word] = []
    private var questions: [Word] = []
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
    func getCurrentQuestion() -> Word? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
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
    
    // 產生錯誤答案
    func generateWrongAnswers(for correctAnswer: String) -> [String] {
        var wrongAnswers = words.map { $0.chinese }.filter { $0 != correctAnswer }
        wrongAnswers.shuffle()
        return Array(wrongAnswers.prefix(3))
    }
    
    // 將單字加入收藏
    func addToFavorites() {
        guard let word = getCurrentQuestion() else { return }
        
        let favoriteData: [String: Any] = [
            "LevelNumber": currentQuestionIndex,
            "English": word.english,
            "Chinese": word.chinese,
            "Property": word.property,
            "Sentence": word.sentence,
            "Tag": "All"
        ]
        
        let db = Firestore.firestore()
        let userCollectionRef = db.collection("PersonAccount").document(account).collection("CollectionFolderWord").document("\(currentQuestionIndex)")
        
        userCollectionRef.setData(favoriteData, merge: true) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Document added with ID: \(self.currentQuestionIndex)")
            }
        }
    }
}

// 載入 JSON 檔案的功能
func loadWordsFromFile() -> [Word] {
    guard let url = Bundle.main.url(forResource: "words", withExtension: "json"),
          let data = try? Data(contentsOf: url),
          let wordFile = try? JSONDecoder().decode(WordFile.self, from: data) else {
        return []
    }
    return Array(wordFile.wordType.values)
}

