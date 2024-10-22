//
//  LevelUpGamePageModelTests.swift
//  RogueWord
//
//  Created by shachar on 2024/10/22.
//

// LevelUpGamePageModelTests.swift
import XCTest
@testable import RogueWord

class LevelUpGamePageModelTests: XCTestCase {
    
    var model: LevelUpGamePageModel!
    
    override func setUp() {
        super.setUp()
        model = LevelUpGamePageModel()
        model.words = [
            JsonWord(
                levelNumber: 900,
                english: "ambivalent",
                chinese: "矛盾的",
                property: "adj.",
                sentence: "He felt ambivalent about the promotion, excited yet apprehensive."
            ),
            JsonWord(
                levelNumber: 901,
                english: "benevolent",
                chinese: "仁慈的",
                property: "adj.",
                sentence: "She was a benevolent old woman who always helped her neighbors."
            ),
            JsonWord(
                levelNumber: 902,
                english: "candid",
                chinese: "坦率的",
                property: "adj.",
                sentence: "She gave a candid interview about her career."
            ),
            JsonWord(
                levelNumber: 903,
                english: "diligent",
                chinese: "勤勉的",
                property: "adj.",
                sentence: "He is a diligent student who always does his homework."
            )
        ]
        model.questions = model.words
    }
    
    override func tearDown() {
        model = nil
        super.tearDown()
    }
    
    func testGetCurrentQuestion() {
        model.currentQuestionIndex = 0
        let question = model.getCurrentQuestion()
        print("========================================")
        print(question)
        print("========================================")
        XCTAssertNotNil(question)
        XCTAssertEqual(question?.english, "ambivalent")

        model.currentQuestionIndex = model.questions.count
        let nilQuestion = model.getCurrentQuestion()
        XCTAssertNil(nilQuestion)
        print("testGetCurrentQuestion - 問題超出範圍測試通過")
    }
    
    func testGenerateWrongAnswers() {
        let correctAnswer = "矛盾的"
        let wrongAnswers = model.generateWrongAnswers(for: correctAnswer)
        
        XCTAssertFalse(wrongAnswers.contains(correctAnswer))
        XCTAssertLessThanOrEqual(wrongAnswers.count, 3)
        for answer in wrongAnswers {
            XCTAssertTrue(model.words.contains { $0.chinese == answer })
        }
        print("testGenerateWrongAnswers 通過測試，生成的錯誤答案: \(wrongAnswers)")
    }
    
    func testCheckAnswer() {
        model.currentQuestionIndex = 0
        let isCorrect = model.checkAnswer("矛盾的")
        XCTAssertTrue(isCorrect)
        print("testCheckAnswer - 正確答案測試通過")

        let isIncorrect = model.checkAnswer("仁慈的")
        XCTAssertFalse(isIncorrect)
        print("testCheckAnswer - 錯誤答案測試通過")
    }
    
    func testMoveToNextQuestion() {
        model.currentQuestionIndex = 0
        
        let hasNext = model.moveToNextQuestion()
        XCTAssertTrue(hasNext)
        XCTAssertEqual(model.currentQuestionIndex, 1)
        print("testMoveToNextQuestion - 成功移動到下一個問題，當前問題索引: \(model.currentQuestionIndex)")

        model.currentQuestionIndex = model.questions.count - 1
        let noNext = model.moveToNextQuestion()
        XCTAssertFalse(noNext)
        XCTAssertEqual(model.currentQuestionIndex, model.questions.count - 1)
        print("testMoveToNextQuestion - 最後一個問題測試通過，無法再移動，當前問題索引: \(model.currentQuestionIndex)")
    }
}
