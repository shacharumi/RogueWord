//
//  BattleGameSceneViewModel.swift
//  RogueWord
//
//  Created by shachar on 2024/10/15.
//

import Foundation
import FirebaseDatabase
import SpriteKit

class BattleGameSceneViewModel {

    var showAlert: ((String, String?) -> Void)?
    var navigateToBattle: ((Rank) -> Void)?
    var navigateToRoom: ((String) -> Void)?
    var presentQRScanner: (() -> Void)?

    var rank: Rank?
    var gameCharacters: [GameCharacter] = []

    init() {
        setupCharacters()
    }

    private func setupCharacters() {
        gameCharacters = [
            GameCharacter(
                name: "Enchantress",
                displayName: "積分對戰",
                fontName: "Arial-BoldMT",
                actionSet: ["Idle0", "Idle1", "Idle2", "Idle3", "Idle4", "Idle5", "Idle6", "Idle7"],
                position: CGPoint(x: -100, y: 30),
                levelRequired: 0,
                characterID: 1
            ),
            GameCharacter(
                name: "Knight",
                displayName: "未來可期",
                fontName: "HelveticaNeue-Bold",
                actionSet: ["Idle0", "Idle1", "Idle2", "Idle3", "Idle4", "Idle5"],
                position: CGPoint(x: -100, y: -170),
                levelRequired: 200,
                characterID: 2
            ),
            GameCharacter(
                name: "Musketeer",
                displayName: "未來可期",
                fontName: "Courier-Bold",
                actionSet: ["Idle0", "Idle1", "Idle2", "Idle3"],
                position: CGPoint(x: 100, y: -170),
                levelRequired: 500,
                characterID: 3
            ),
            GameCharacter(
                name: "Wizard",
                displayName: "多人對戰",
                fontName: "Courier-Bold",
                actionSet: ["Idle0", "Idle1", "Idle2", "Idle3"],
                position: CGPoint(x: 100, y: 30),
                levelRequired: 1000,
                characterID: 4
            )
        ]
    }

    func handleCharacterTap(characterID: Int, node: SKSpriteNode) {
        guard let character = gameCharacters.first(where: { $0.characterID == characterID }) else {
            return
        }

        if let isDisabled = node.userData?["disabled"] as? Bool, isDisabled {
            showAlert?("不可用", "此角色目前不可用。")
            return
        }

        guard let rank = self.rank else { return }
        _ = Int(rank.rankScore)

        if character.name == "Wizard" {
            showWizardOptions()
            return
        }

        navigateToBattle?(rank)
    }

    private func showWizardOptions() {
        showAlert?("多人連線", nil)
    }

    func createRoom(completion: @escaping (Result<String, Error>) -> Void) {
        let email = UserDefaults.standard.string(forKey: "email") ?? "unknownEmail"
        let roomID = encodeEmail(email)

        let ref = Database.database().reference()
        let playerName = UserDefaults.standard.string(forKey: "fullName") ?? "Unknown Player"
        let userEmail = email

        let roomData: [String: Any] = [
            "createdBy": playerName,
            "createdByEmail": userEmail,
            "score": 0,
            "isStart": false,
            "participants": [
                encodeEmail(userEmail): [
                    "name": playerName,
                    "accuracy": 0,
                    "time": 0
                ]
            ]
        ]

        ref.child("rooms").child(roomID).setValue(roomData) { error, _ in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(roomID))
            }
        }
    }

    func joinRoom(with roomID: String, completion: @escaping (Result<String, Error>) -> Void) {
        let ref = Database.database().reference()
        let email = UserDefaults.standard.string(forKey: "email") ?? "unknownEmail"
        let userEmail = email
        let playerName = UserDefaults.standard.string(forKey: "fullName") ?? "Unknown Player"

        ref.child("rooms").child(roomID).child("participants").child(encodeEmail(userEmail)).setValue([
            "name": playerName,
            "accuracy": 0,
            "time": 0
        ]) { error, _ in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(roomID))
            }
        }
    }

    private func encodeEmail(_ email: String) -> String {
        return email.replacingOccurrences(of: ".", with: ",")
    }

    private func decodeEmail(_ encodedEmail: String) -> String {
        return encodedEmail.replacingOccurrences(of: ",", with: ".")
    }
}
