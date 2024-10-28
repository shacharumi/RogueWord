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
        XCTAssertNotNil(question)
        XCTAssertEqual(question?.english, "ambivalent")

        model.currentQuestionIndex = model.questions.count
        let nilQuestion = model.getCurrentQuestion()
        XCTAssertNil(nilQuestion)
    }

    func testGenerateWrongAnswers() {
        let correctAnswer = "矛盾的"
        let wrongAnswers = model.generateWrongAnswers(for: correctAnswer)

        XCTAssertFalse(wrongAnswers.contains(correctAnswer))
        XCTAssertLessThanOrEqual(wrongAnswers.count, 3)
        for answer in wrongAnswers {
            XCTAssertTrue(model.words.contains { $0.chinese == answer })
        }
    }

    func testCheckAnswer() {
        model.currentQuestionIndex = 0
        let isCorrect = model.checkAnswer("矛盾的")
        XCTAssertTrue(isCorrect)

        let isIncorrect = model.checkAnswer("仁慈的")
        XCTAssertFalse(isIncorrect)
    }

    func testMoveToNextQuestion() {
        model.currentQuestionIndex = 0

        let hasNext = model.moveToNextQuestion()
        XCTAssertTrue(hasNext)
        XCTAssertEqual(model.currentQuestionIndex, 1)

        model.currentQuestionIndex = model.questions.count - 1
        let noNext = model.moveToNextQuestion()
        XCTAssertFalse(noNext)
        XCTAssertEqual(model.currentQuestionIndex, model.questions.count - 1)
    }
}
