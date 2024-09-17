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
