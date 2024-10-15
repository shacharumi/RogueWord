//
//  HomeGameSceneModel.swift
//  RogueWord
//
//  Created by shachar on 2024/10/14.
//

import Foundation
import SpriteKit

class HomeGameSceneViewModel {

    var characters: [GameCharacter] = []
    var personData: UserData?

    var onCharactersUpdated: (() -> Void)?

    init(personData: UserData?) {
        self.personData = personData
        createCharacters()
    }


    func createCharacters() {
           characters.removeAll()

           let enchantress = GameCharacter(
               name: "Enchantress",
               displayName: "單字英翻中",
               fontName: "Arial-BoldMT",
               actionSet: ["Idle", "Run", "Walk", "Jump", "Attack", "Dead"],
               position: CGPoint(x: -150, y: 0),
               levelRequired: 0,
               characterID: 0
           )

           let knight = GameCharacter(
               name: "Knight",
               displayName: "句子填空",
               fontName: "HelveticaNeue-Bold",
               actionSet: ["Idle", "Run", "Walk", "Jump", "Attack", "Dead"],
               position: CGPoint(x: 0, y: 0),
               levelRequired: 99,
               characterID: 99
           )

           let musketeer = GameCharacter(
               name: "Musketeer",
               displayName: "文法測試",
               fontName: "Courier-Bold",
               actionSet: ["Idle", "Run", "Walk", "Jump", "Attack", "Dead"],
               position: CGPoint(x: 150, y: 0),
               levelRequired: 199,
               characterID: 199
           )

           characters.append(contentsOf: [enchantress, knight, musketeer])

           onCharactersUpdated?()
       }


    func getRandomAction(for character: GameCharacter) -> CharacterAction {
        let randomIndex = Int.random(in: 0..<character.actionSet.count)
        let actionName = character.actionSet[randomIndex]
        return CharacterAction(actionName: actionName)
    }

    func handleCharacterTap(characterID: Int, completion: @escaping (GameAction) -> Void) {
        guard let personData = self.personData else { return }

        let playerLevel = personData.levelData?.levelNumber ?? 0

        if let character = characters.first(where: { $0.characterID == characterID }) {
            if playerLevel < character.levelRequired {
                completion(.showWarning(message: "請先通關前面關卡\n再進到下一階段"))
            } else {
                switch character.characterID {
                case 0:
                    completion(.navigateToLevelUpGame)
                case 99:
                    completion(.navigateToSentenceFillGame)
                default:
                    break
                }
            }
        }
    }
}



struct GameCharacter {
    let name: String
    let displayName: String
    let fontName: String
    let actionSet: [String]
    let position: CGPoint
    let levelRequired: Int
    let characterID: Int
}


struct CharacterAction {
    let actionName: String
}

enum GameAction {
    case showWarning(message: String)
    case navigateToLevelUpGame
    case navigateToSentenceFillGame
}
