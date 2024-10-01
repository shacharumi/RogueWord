//
//  LoginModel.swift
//  RogueWord
//
//  Created by shachar on 2024/10/1.
//

import Foundation

struct LevelData: Codable {
    var correct: Int
    var levelNumber: Int
    var wrong: Int
    var isCorrect: [Bool]
    
    enum CodingKeys: String, CodingKey {
        case correct = "Correct"
        case levelNumber = "LevelNumber"
        case wrong = "Wrong"
        case isCorrect = "isCorrect"
    }
}

struct Rank: Codable {
    var correct: Float
    var playTimes: Float
    var winRate: Float
    var rankScore: Float
}

struct UserData: Codable {
    let userID: String
    let fullName: String?
    var userName: String?
    let email: String?
    let realUserStatus: Int?
    var tag: [String]?
    var levelData: LevelData?
    var rank: Rank?
    var image: String?
    
    enum CodingKeys: String, CodingKey {
        case userID
        case fullName = "fullName"
        case userName
        case email
        case realUserStatus
        case tag = "Tag"
        case levelData = "LevelData"
        case rank
        case image
    }
}

