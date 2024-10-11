//
//  SentenceFillGamePageModel.swift
//  RogueWord
//
//  Created by shachar on 2024/10/10.
//

import Foundation
import Firebase

class SentenceFillGamePageModel: LevelUpGamePageModel {
    
    // 用於存儲當前被挖空的單字
    var missingWord: String = ""
    override var titleLevel: String {
        get {
            return "fillLevelData"
        }
        set {
            
        }
    }
    
    override init() {
        super.init()
    }
    
    func getFillCurrentQuestion() -> String? {
        guard currentQuestionIndex < questions.count else { return nil }
        
        let currentWord = questions[currentQuestionIndex]
        missingWord = currentWord.english // 記錄被挖空的單字
        // 將句子中的單字挖空
        let sentenceWithBlank = currentWord.sentence.replacingOccurrences(of: currentWord.english, with: "____")
        return sentenceWithBlank
    }
    
    // 生成錯誤答案，選項改為單字
    override func generateWrongAnswers(for correctAnswer: String) -> [String] {
        var wrongAnswers = words.map { $0.english }.filter { $0 != missingWord }
        wrongAnswers.shuffle()
        return Array(wrongAnswers.prefix(3))
    }
    
    // 檢查答案是否正確
    override func checkAnswer(_ answer: String) -> Bool {
        return answer == missingWord
    }
    
    
}
