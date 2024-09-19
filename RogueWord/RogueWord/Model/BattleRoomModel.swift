//
//  BattleRoomModel.swift
//  RogueWord
//
//  Created by shachar on 2024/9/16.
//

struct Room {
    var roomId: String
    var player1Name: String
    var player2Name: String
    var player1Score: Int
    var player2Score: Int
    var currentQuestionIndex: Int
    var playCounting: Int
    var player1Select: Int
    var player2Select: Int
    var player1Prepare: Bool
    var player2Prepare: Bool
}

struct FireBaseWord {
    let levelNumber: Int
    var tag: String
    let word: JsonWord
}

struct JsonWord: Decodable {
    let levelNumber: Int
    let english: String
    let chinese: String
    let property: String
    let sentence: String
}

struct Question {
    let questionText: String
    let options: [String]
    let answer: String
}

struct ChatGPTAPIKey {
    static let key = ""
}

struct AIModel {
    static let model = "gpt-3.5-turbo"
}

struct Message: Encodable {
    let role: String
    let content: String
}

struct OpenAIBody: Encodable {
    let model: String
    let messages: [Message]
    let temperature = 0.0
    let max_tokens = 512
    let top_p = 1.0
    let frequency_penalty = 0.0
    let presence_penalty = 0.0
}

struct ParagraphQuestion {
    let questionText: String
    let options: [String]
    let answer: [String]
}
