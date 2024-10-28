//
//  WrongQuestionModel.swift
//  RogueWord
//
//  Created by shachar on 2024/10/16.
//

import Foundation
import FirebaseCore

struct GetParagraphType: Decodable {
    var questions: String
    var options: [String: [String]]
    var answerOptions: [String]
    var answer: String
    var title: String?
    var timestamp: Timestamp

}

struct GetReadingType: Decodable {
    var readingMessage: String
    var questions: [String]
    var options: [String: [String]]
    var answerOptions: [String]
    var answer: [String]
    var title: String?
    var timestamp: Timestamp
}

struct GetWordFillType: Decodable {
    var question: String
    var options: [String]
    var answerOptions: String
    var answer: String
}

struct WordFillDocument: Decodable {
    var title: String?
    var tag: String
    var questions: [GetWordFillType]
    var timestamp: Timestamp
}
