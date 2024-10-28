//
//  BattleGameScene.swift
//  RogueWord
//
//  Created by shachar on 2024/10/6.
//

import SpriteKit
import UIKit
import FirebaseDatabase

class BattleGameScene: SKScene {

    var enchantress: SKSpriteNode!
    var knight: SKSpriteNode!
    var musketeer: SKSpriteNode!
    var wizard: SKSpriteNode!

    var rank: Rank?
    weak var viewController: UIViewController?

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        self.backgroundColor = .clear

        enchantress = createCharacter(named: "Enchantress", position: CGPoint(x: center.x - 100, y: center.y + 30))
        knight = createCharacter(named: "Knight", position: CGPoint(x: center.x - 100, y: center.y - 170))
        musketeer = createCharacter(named: "Musketeer", position: CGPoint(x: center.x + 100, y: center.y - 170))
        wizard = createCharacter(named: "Wizard", position: CGPoint(x: center.x + 100, y: center.y + 30))

        runRandomAction(for: enchantress, characterName: "Enchantress")
        runRandomAction(for: wizard, characterName: "Wizard")

        let disabledCharacters = [knight, musketeer]
        for character in disabledCharacters {
            disableCharacter(character!)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            let touchedNodes = nodes(at: location)
            for node in touchedNodes {
                if let characterNode = node as? SKSpriteNode, let characterName = characterNode.name {
                    handleCharacterTap(characterName, node: characterNode)
                    break
                }
            }
        }
    }

    func handleCharacterTap(_ characterName: String, node: SKSpriteNode) {
        if let isDisabled = node.userData?["disabled"] as? Bool, isDisabled {
            let alert = UIAlertController(title: "不可用", message: "此角色目前不可用。", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "確定", style: .default, handler: nil))
            self.viewController?.present(alert, animated: true, completion: nil)
            return
        }

        guard let rank = self.rank else { return }
        guard node.userData?["requiredLevel"] is Int else { return }
        _ = Int(rank.rankScore)

        if characterName == "Wizard" {
            let alert = UIAlertController(title: "多人連線", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "創建房間", style: .default, handler: { [weak self] _ in
                self?.createRoom()
            }))
            alert.addAction(UIAlertAction(title: "掃描Qrcode", style: .default, handler: { [weak self] _ in
                self?.scanQRCode()
            }))
            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            self.viewController?.present(alert, animated: true, completion: nil)
            return
        }

        let battlePage = BattleViewController()
        battlePage.rank = rank
        battlePage.modalPresentationStyle = .fullScreen
        self.viewController?.present(battlePage, animated: true, completion: nil)
    }

    func createRoom() {
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

        ref.child("rooms").child(roomID).setValue(roomData) { [weak self] (error, _) in
            if let error = error {
                print("Error creating room: \(error.localizedDescription)")
                let errorAlert = UIAlertController(title: "错误", message: error.localizedDescription, preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
                self?.viewController?.present(errorAlert, animated: true, completion: nil)
            } else {
                let roomVC = RoomViewController()
                roomVC.roomID = roomID
                roomVC.modalPresentationStyle = .fullScreen
                self?.viewController?.present(roomVC, animated: true, completion: nil)
            }
        }
    }

    func scanQRCode() {
        let scannerVC = QRCodeScannerViewController()
        scannerVC.delegate = self
        scannerVC.modalPresentationStyle = .fullScreen
        self.viewController?.present(scannerVC, animated: true, completion: nil)
    }

    func createCharacter(named characterName: String, position: CGPoint) -> SKSpriteNode {
        let character = SKSpriteNode(imageNamed: "\(characterName)Idle0")
        character.position = position
        character.name = characterName

        character.zPosition = 1
        addChild(character)

        let labelText: String
        let fontName: String
        var requiredLevel: Int = 0

        switch characterName {
        case "Enchantress":
            labelText = "積分對戰"
            fontName = "Arial-BoldMT"
            requiredLevel = 0

        case "Knight":
            labelText = "未來可期"
            fontName = "HelveticaNeue-Bold"
            requiredLevel = 200

        case "Musketeer":
            labelText = "未來可期"
            fontName = "Courier-Bold"
            requiredLevel = 500

        case "Wizard":
            labelText = "多人對戰"
            fontName = "Courier-Bold"
            requiredLevel = 1000

        default:
            labelText = "鐵牌"
            fontName = "Helvetica"
            requiredLevel = 0
        }

        character.userData = ["requiredLevel": requiredLevel]

        if !labelText.isEmpty {
            let label = SKLabelNode(text: labelText)
            label.fontName = fontName
            label.fontSize = 20
            label.fontColor = UIColor(named: "HomeTextColor")

            label.verticalAlignmentMode = .center
            label.horizontalAlignmentMode = .center
            label.position = CGPoint(x: 0, y: character.size.height / 2 + 10)
            label.name = "label"

            let backgroundSize = CGSize(width: label.frame.width + 15, height: label.frame.height + 5)

            let background = SKShapeNode(path: UIBezierPath(roundedRect: CGRect(origin: .zero, size: backgroundSize), cornerRadius: 10).cgPath)
            background.fillColor = UIColor(named: "HomeTextBackGround") ?? .white
            background.strokeColor = .clear
            background.alpha = 0.8

            background.position = CGPoint(x: label.position.x - backgroundSize.width / 2, y: label.position.y - backgroundSize.height / 2)

            character.addChild(background)
            character.addChild(label)
        }

        return character
    }

    func runRandomAction(for character: SKSpriteNode, characterName: String) {
        if characterName == "Enchantress" {
            stopAnimation(character, characterName: characterName, imageName: "Idle", imageCount: 7, timePerFrame: 0.4)
        } else if characterName == "Knight" {
            stopAnimation(character, characterName: characterName, imageName: "Idle", imageCount: 5, timePerFrame: 0.4)
        } else if characterName == "Musketeer" || characterName == "Wizard" {
            stopAnimation(character, characterName: characterName, imageName: "Idle", imageCount: 4, timePerFrame: 0.4)
        }
    }

    func stopAnimation(_ character: SKSpriteNode, characterName: String, imageName: String, imageCount: Int, timePerFrame: Double) {
        var idleTextures: [SKTexture] = []
        for i in 0...imageCount {
            let textureName = "\(characterName)\(imageName)\(i)"
            let texture = SKTexture(imageNamed: textureName)
            idleTextures.append(texture)
        }
        let idleAnimation = SKAction.animate(with: idleTextures, timePerFrame: timePerFrame)

        let sequence = SKAction.sequence([idleAnimation, SKAction.run {
            self.runRandomAction(for: character, characterName: characterName)
        }])
        character.run(sequence)
    }

    func encodeEmail(_ email: String) -> String {
        return email.replacingOccurrences(of: ".", with: ",")
    }

    func decodeEmail(_ encodedEmail: String) -> String {
        return encodedEmail.replacingOccurrences(of: ",", with: ".")
    }

    func disableCharacter(_ character: SKSpriteNode) {
        character.color = .gray
        character.colorBlendFactor = 1.0

        character.removeAllActions()

        if character.userData == nil {
            character.userData = [:]
        }
        character.userData?["disabled"] = true

        character.alpha = 0.6

    }
}

extension BattleGameScene: QRCodeScannerDelegate {
    func didScanQRCode(with roomID: String) {
        joinRoom(with: roomID)
    }

    func joinRoom(with roomID: String) {
        let ref = Database.database().reference()
        let email = UserDefaults.standard.string(forKey: "email") ?? "unknownEmail"
        let userEmail = email
        let playerName = UserDefaults.standard.string(forKey: "fullName") ?? "Unknown Player"

        ref.child("rooms").child(roomID).child("participants").child(encodeEmail(userEmail)).setValue([
            "name": playerName,
            "accuracy": 0,
            "time": 0
        ]) { [weak self] (error, _) in
            if let error = error {
                print("Error joining room: \(error.localizedDescription)")
                let errorAlert = UIAlertController(title: "错误", message: error.localizedDescription, preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
                self?.viewController?.present(errorAlert, animated: true, completion: nil)
            } else {
                let roomVC = RoomViewController()
                roomVC.roomID = roomID
                roomVC.modalPresentationStyle = .fullScreen
                self?.viewController?.present(roomVC, animated: true, completion: nil)
            }
        }
    }
}
