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
    var question: String  // 單一問題
    var options: [String]  // 選項數組
    var answerOptions: String  // 正確答案
    var answer: String  // 答案解釋
}

struct WordFillDocument: Decodable {
    var title: String?  // 文檔的標題
    var tag: String  // 文檔的標籤
    var questions: [GetWordFillType]  // 包含的問題列表
    var timestamp: Timestamp
}
