//
//  RoomModel.swift
//  RogueWord
//
//  Created by shachar on 2024/10/15.
//

import Foundation

struct Participant {
    let name: String
    let accuracy: Float
    let time: TimeInterval

    init?(dictionary: [String: Any]) {
        guard let name = dictionary["name"] as? String,
              let accuracy = dictionary["accuracy"] as? Float,
              let time = dictionary["time"] as? TimeInterval else {
            return nil
        }
        self.name = name
        self.accuracy = accuracy
        self.time = time
    }
}
