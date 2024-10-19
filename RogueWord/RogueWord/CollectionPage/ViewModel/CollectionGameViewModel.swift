//
//  CollectionGameViewModel.swift
//  RogueWord
//
//  Created by shachar on 2024/10/16.
//

import Foundation

class CollectionGameViewModel {
    var collectionData: [FireBaseWord] = []
    private(set) var currentQuestionIndex: Int = 0
    private(set) var correctCount: Int = 0
    private(set) var wrongCount: Int = 0
    private(set) var isCorrect: [Bool] = []
    
    // 初始化
    init(collectionData: [FireBaseWord]) {
        self.collectionData = collectionData
    }
    
    // 获取当前问题
    func getCurrentQuestion() -> FireBaseWord? {
        if currentQuestionIndex < collectionData.count {
            return collectionData[currentQuestionIndex]
        } else {
            return nil
        }
    }
    
    // 检查答案
    func checkAnswer(_ selectedAnswer: String) -> Bool {
        guard let currentWord = getCurrentQuestion() else {
            return false
        }
        let isAnswerCorrect = selectedAnswer == currentWord.word.chinese
        if isAnswerCorrect {
            correctCount += 1
            isCorrect.append(true)
        } else {
            wrongCount += 1
            isCorrect.append(false)
        }
        return isAnswerCorrect
    }
    
    // 移动到下一个问题
    func moveToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    // 检查是否可以返回上一题
    func canMoveToPreviousQuestion() -> Bool {
        return currentQuestionIndex > 0
    }
    
    // 返回上一题
    func moveToPreviousQuestion() {
        if currentQuestionIndex > 0 {
            currentQuestionIndex -= 1
            // 更新计数
            if isCorrect[currentQuestionIndex] {
                correctCount -= 1
            } else {
                wrongCount -= 1
            }
            isCorrect.remove(at: currentQuestionIndex)
        }
    }
    
    // 获取正确率
    func getAccuracy() -> Float {
        let total = correctCount + wrongCount
        return total > 0 ? (Float(correctCount) / Float(total)) * 100 : 0
    }
    
    // 获取答案选项
    func getAnswerOptions() -> [String] {
        guard let currentWord = getCurrentQuestion() else {
            return []
        }
        var answers = [currentWord.word.chinese]
        
        // 收集错误答案，确保不重复且不包含正确答案
        var wrongAnswers = collectionData.filter { $0.word.chinese != currentWord.word.chinese }.map { $0.word.chinese }
        wrongAnswers.shuffle()
        let numberOfWrongAnswers = min(3, wrongAnswers.count)
        answers.append(contentsOf: wrongAnswers.prefix(numberOfWrongAnswers))
        
        // 如果错误答案不足3个，补充一些固定的错误答案
        while answers.count < 4 {
            answers.append("錯誤答案")
        }
        answers.shuffle()
        return answers
    }
}
