//
//  SentenceFillGamePageModel.swift
//  RogueWord
//
//  Created by shachar on 2024/10/10.
//

import Foundation
import Firebase

class SentenceFillGamePageModel: LevelUpGamePageModel {

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
        missingWord = currentWord.english
        let sentenceWithBlank = currentWord.sentence.replacingOccurrences(of: currentWord.english, with: "____")
        return sentenceWithBlank
    }

    override func generateWrongAnswers(for correctAnswer: String) -> [String] {
        var wrongAnswers = words.map { $0.english }.filter { $0 != missingWord }
        wrongAnswers.shuffle()
        return Array(wrongAnswers.prefix(3))
    }

    override func checkAnswer(_ answer: String) -> Bool {
        return answer == missingWord
    }
}
