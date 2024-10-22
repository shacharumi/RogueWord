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
    
    init(collectionData: [FireBaseWord]) {
        self.collectionData = collectionData
    }
    
    func getCurrentQuestion() -> FireBaseWord? {
        if currentQuestionIndex < collectionData.count {
            return collectionData[currentQuestionIndex]
        } else {
            return nil
        }
    }
    
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
    
    func moveToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func canMoveToPreviousQuestion() -> Bool {
        return currentQuestionIndex > 0
    }
    
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
    
    func getAccuracy() -> Float {
        let total = correctCount + wrongCount
        return total > 0 ? (Float(correctCount) / Float(total)) * 100 : 0
    }
    
    func getAnswerOptions() -> [String] {
        guard let currentWord = getCurrentQuestion() else {
            return []
        }
        var answers = [currentWord.word.chinese]
        
        var wrongAnswers = collectionData.filter { $0.word.chinese != currentWord.word.chinese }.map { $0.word.chinese }
        wrongAnswers.shuffle()
        let numberOfWrongAnswers = min(3, wrongAnswers.count)
        answers.append(contentsOf: wrongAnswers.prefix(numberOfWrongAnswers))
        
        while answers.count < 4 {
            answers.append("錯誤答案")
        }
        answers.shuffle()
        return answers
    }
}
